-- add database roles for an app
-- TODO: Use dotenv variables somehow

drop role postgraphile;
drop role app_anonymous;
drop role app_authenticated;

create role postgraphile login password 'password123';
create role app_anonymous;
create role app_authenticated;

grant app_anonymous to postgraphile;
grant app_authenticated to postgraphile;