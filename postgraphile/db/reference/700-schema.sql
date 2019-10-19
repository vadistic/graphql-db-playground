BEGIN;
--
CREATE SCHEMA forum_public;
CREATE SCHEMA forum_private;
ALTER DEFAULT privileges REVOKE EXECUTE ON functions FROM public;
--
--
--

CREATE TABLE forum_public.person (
    id serial PRIMARY KEY,
    first_name text NOT NULL CHECK (char_length(first_name) < 80),
    last_name text CHECK (char_length(last_name) < 80),
    about text,
    created_at timestamp DEFAULT now()
);
COMMENT ON TABLE forum_public.person IS 'A user of the forum.';
COMMENT ON COLUMN forum_public.person.id IS 'The primary unique identifier for the person.';
COMMENT ON COLUMN forum_public.person.first_name IS 'The person’s first name.';
COMMENT ON COLUMN forum_public.person.last_name IS 'The person’s last name.';
COMMENT ON COLUMN forum_public.person.about IS 'A short description about the user, written by the user.';
COMMENT ON COLUMN forum_public.person.created_at IS 'The time this person was created.';
--
-- POST TOPIC
--

CREATE TYPE forum_public.post_topic AS enum (
    'discussion',
    'inspiration',
    'help',
    'showcase',
);
--
-- POST
--

CREATE TABLE forum_public.post (
    id serial PRIMARY KEY,
    created_at timestamp DEFAULT now(),
    author_id integer NOT NULL REFERENCES forum_public.person (id),
    headline text NOT NULL CHECK (char_length(headline) < 280),
    body text,
    topic forum_public.post_topic,
);
COMMENT ON TABLE forum_public.post IS 'A forum post written by a user.';
COMMENT ON COLUMN forum_public.post.id IS 'The primary key for the post.';
COMMENT ON COLUMN forum_public.post.created_at IS 'The time this post was created.';
COMMENT ON COLUMN forum_public.post.headline IS 'The title written by the user.';
COMMENT ON COLUMN forum_public.post.author_id IS 'The id of the author user.';
COMMENT ON COLUMN forum_public.post.topic IS 'The topic this has been posted in.';
COMMENT ON COLUMN forum_public.post.body IS 'The main body text of our post.';
--
--
--

CREATE FUNCTION forum_public.person_full_name (person forum_public.person)
    RETURNS text
    AS $$
    SELECT
        person.first_name || ' ' || person.last_name
$$
LANGUAGE sql
STABLE;
COMMENT ON FUNCTION forum_public.person_full_name (forum_public.person) IS 'A person’s full name which is a concatenation of their first and last name.';
--
--
--

CREATE FUNCTION forum_public.post_summary (post forum_public.post, length int DEFAULT 50, omission text DEFAULT '…')
    RETURNS text
    AS $$
    SELECT
        CASE WHEN post.body IS NULL THEN
            NULL
        ELSE
            substr(post.body, 0, length) || omission
        END
$$
LANGUAGE sql
STABLE;
COMMENT ON FUNCTION forum_public.post_summary (forum_public.post, int, text) IS 'A truncated version of the body for summaries.';
--
--
--

CREATE FUNCTION forum_public.person_latest_post (person forum_public.person)
    RETURNS forum_public.post
    AS $$
    SELECT
        post.*
    FROM
        forum_public.post AS post
    WHERE
        post.author_id = person.id
    ORDER BY
        created_at DESC
    LIMIT 1
$$
LANGUAGE sql
STABLE;
COMMENT ON FUNCTION forum_public.person_latest_post (forum_public.person) IS 'Gets the latest post written by the person.';
--
--
--

CREATE FUNCTION forum_public.search_posts (search text)
    RETURNS SETOF forum_public.post
    AS $$
    SELECT
        post.*
    FROM
        forum_public.post AS post
    WHERE
        post.headline ILIKE ('%' || search || '%')
        OR post.body ILIKE ('%' || search || '%')
$$
LANGUAGE sql
STABLE;
COMMENT ON FUNCTION forum_public.search_posts (text) IS 'Returns posts containing a given search term.';
--
--
--

ALTER TABLE forum_public.person
    ADD COLUMN updated_at timestamp DEFAULT now();
ALTER TABLE forum_public.post
    ADD COLUMN updated_at timestamp DEFAULT now();
--
--
--

CREATE FUNCTION forum_private.set_updated_at ()
    RETURNS TRIGGER
    AS $$
BEGIN
    new.updated_at : = CURRENT_TIMESTAMP;
    RETURN new;
END;
$$
LANGUAGE plpgsql;
--
CREATE TRIGGER person_updated_at
    BEFORE UPDATE ON forum_public.person
    FOR EACH ROW
    EXECUTE PROCEDURE forum_private.set_updated_at ();
--
CREATE TRIGGER post_updated_at
    BEFORE UPDATE ON forum_public.post
    FOR EACH ROW
    EXECUTE PROCEDURE forum_private.set_updated_at ();
--
CREATE TABLE forum_private.person_account (
    person_id integer PRIMARY KEY REFERENCES forum_public.person (id) ON DELETE CASCADE, email text NOT NULL UNIQUE CHECK (email ~* '^.+@.+\..+$'),
    password_hash text NOT NULL
);
COMMENT ON TABLE forum_private.person_account IS 'Private information about a person’s account.';
COMMENT ON COLUMN forum_private.person_account.person_id IS 'The id of the person associated with this account.';
COMMENT ON COLUMN forum_private.person_account.email IS 'The email address of the person.';
COMMENT ON COLUMN forum_private.person_account.password_hash IS 'An opaque hash of the person’s password.';
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE FUNCTION forum_public.register_person (first_name text, last_name text, email text, PASSWORD text)
    RETURNS forum_public.person
    AS $$
DECLARE
    person forum_public.person;
BEGIN
    INSERT INTO forum_public.person (first_name, last_name)
    VALUES (first_name, last_name)
RETURNING
    * INTO person;
    INSERT INTO forum_private.person_account (person_id, email, password_hash)
    VALUES (person.id, email, crypt(PASSWORD, gen_salt('bf')));
    RETURN person;
END;
$$
LANGUAGE plpgsql
STRICT
SECURITY DEFINER;
--
--
--

COMMENT ON FUNCTION forum_public.register_person (text, text, text, text) IS 'Registers a single user and creates an account in our forum.';
CREATE ROLE forum_public_postgraphile LOGIN PASSWORD 'xyz';
CREATE ROLE forum_public_anonymous;
GRANT forum_public_anonymous TO forum_public_postgraphile;
CREATE ROLE forum_public_person;
GRANT forum_public_person TO forum_public_postgraphile;
CREATE TYPE forum_public.jwt_token AS (
    ROLE text,
    person_id integer
);
CREATE FUNCTION forum_public.authenticate (email text, PASSWORD text)
    RETURNS forum_public.jwt_token
    AS $$
    SELECT
        ('forum_public_person',
            person_id)::forum_public.jwt_token
    FROM
        forum_private.person_account
    WHERE
        person_account.email = $1
        AND person_account.password_hash = crypt($2, person_account.password_hash);
$$
LANGUAGE sql
STRICT
SECURITY DEFINER;
COMMENT ON FUNCTION forum_public.authenticate (text, text) IS 'Creates a JWT token that will securely identify a person and give them certain permissions.';
--
--
--

CREATE FUNCTION forum_public.current_person ()
    RETURNS forum_public.person
    AS $$
    SELECT
        *
    FROM
        forum_public.person
    WHERE
        id = current_setting('jwt.claims.person_id', TRUE)::integer
$$
LANGUAGE sql
STABLE;
COMMENT ON FUNCTION forum_public.current_person () IS 'Gets the person who was identified by our JWT.';
--
--
--

CREATE FUNCTION forum_public.change_password (current_password text, new_password text)
    RETURNS boolean
    AS $$
DECLARE
    current_person forum_public.person;
BEGIN
    current_person : = forum_public.current_person ();
    IF EXISTS (
        SELECT
            1
        FROM
            forum_private.person_account
        WHERE
            person_account.person_id = current_person.id
            AND person_account.password_hash = crypt($1, person_account.password_hash)) THEN
    UPDATE
        forum_private.person_account
    SET
        password_hash = crypt($2, gen_salt('bf'))
    WHERE
        person_account.person_id = current_person.id;
    RETURN TRUE;
ELSE
    RETURN FALSE;
END IF;
END;
$$
LANGUAGE plpgsql
STRICT
SECURITY DEFINER;

GRANT usage ON SCHEMA forum_public TO forum_public_anonymous, forum_public_person;
GRANT SELECT ON TABLE forum_public.person TO forum_public_anonymous, forum_public_person;
GRANT UPDATE, DELETE ON TABLE forum_public.person TO forum_public_person;
GRANT SELECT ON TABLE forum_public.post TO forum_public_anonymous, forum_public_person;
GRANT INSERT, UPDATE, DELETE ON TABLE forum_public.post TO forum_public_person;
GRANT usage ON SEQUENCE forum_public.post_id_seq TO forum_public_person;

GRANT EXECUTE ON FUNCTION forum_public.person_full_name (forum_public.person) TO forum_public_anonymous, forum_public_person;
GRANT EXECUTE ON FUNCTION forum_public.post_summary (forum_public.post, integer, text) TO forum_public_anonymous, forum_public_person;
GRANT EXECUTE ON FUNCTION forum_public.person_latest_post (forum_public.person) TO forum_public_anonymous, forum_public_person;
GRANT EXECUTE ON FUNCTION forum_public.search_posts (text) TO forum_public_anonymous, forum_public_person;
GRANT EXECUTE ON FUNCTION forum_public.authenticate (text, text) TO forum_public_anonymous, forum_public_person;
GRANT EXECUTE ON FUNCTION forum_public.current_person () TO forum_public_anonymous, forum_public_person;
GRANT EXECUTE ON FUNCTION forum_public.change_password (text, text) TO forum_public_person;
GRANT EXECUTE ON FUNCTION forum_public.register_person (text, text, text, text) TO forum_public_anonymous;

ALTER TABLE forum_public.person enable ROW level SECURITY;
ALTER TABLE forum_public.post enable ROW level SECURITY;

CREATE POLICY select_person ON forum_public.person FOR SELECT USING (TRUE);
CREATE POLICY select_post ON forum_public.post FOR SELECT USING (TRUE);
CREATE POLICY update_person ON forum_public.person FOR UPDATE TO forum_public_person USING (id = current_setting('jwt.claims.person_id', TRUE)::integer);
CREATE POLICY delete_person ON forum_public.person FOR DELETE TO forum_public_person USING (id = current_setting('jwt.claims.person_id', TRUE)::integer);
CREATE POLICY insert_post ON forum_public.post FOR INSERT TO forum_public_person WITH CHECK (author_id = current_setting('jwt.claims.person_id', TRUE)::integer);
CREATE POLICY update_post ON forum_public.post FOR UPDATE TO forum_public_person USING (author_id = current_setting('jwt.claims.person_id', TRUE)::integer);
CREATE POLICY delete_post ON forum_public.post FOR DELETE TO forum_public_person USING (author_id = current_setting('jwt.claims.person_id', TRUE)::integer);

COMMIT;

