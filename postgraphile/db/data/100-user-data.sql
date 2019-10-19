create or replace function temp__get_account_id (skip int)
    returns uuid as $$
        SELECT (id)
            FROM app_public.account
            OFFSET skip
            LIMIT 1;
    $$ language sql stable;

create or replace function temp__hash_password (password text)
    returns text as $$
    BEGIN
        RETURN crypt(password, gen_salt('bf'));
    END
    $$ language plpgsql immutable;


insert into app_public.account
    (first_name,                    last_name,        email,                description,              timezone      )
    values
    ('Jakub',                       'Wadas',         'vadistic@gmail.com',  'My description',         'Europe/Warsaw'),
    ('Adam',                        'Kowalski',      'adam@gmail.com',      'My other description',   'Europe/Warsaw');


insert into app_private.account
    (account_id,                    password_hash                           )
    values
    (temp__get_account_id (0),      temp__hash_password('password')         ),
    (temp__get_account_id (1),      temp__hash_password('password123')      );