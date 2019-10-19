CREATE OR REPLACE FUNCTION temp__get_account_id (skip int)
    RETURNS uuid AS $$
        SELECT (id)
            FROM app_public.account
            OFFSET skip
            LIMIT 1;
    $$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION temp__hash_password (password text)
    RETURNS text AS $$
    BEGIN
        RETURN crypt(password, gen_salt('bf'));
    END
    $$ LANGUAGE PLPGSQL IMMUTABLE;


INSERT INTO app_public.account
    (first_name,                    last_name,      description           )
    VALUES
    ('Jakub',                       'Wadas',        'My description'      ),
    ('Adam',                        'Kowalski',     'My other description');


INSERT INTO app_private.account
    (account_id,                    email,                  password_hash,                           timezone)
    VALUES
    (temp__get_account_id (0),      'vadistic@gmail.com',   temp__hash_password('password'),        'Europe/Warsaw'),
    (temp__get_account_id (1),      'adam@gmail.com',       temp__hash_password('password123'),     'Europe/Warsaw');