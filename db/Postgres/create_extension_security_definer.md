## Postgres self service function creation
First, as susperuser, prepare the schema "dbaas" on each client database (and template1)
```sql
CREATE SCHEMA dbaas AUTHORIZATION postgres;
--drop table dbaas.allowed_extensions;
--drop table dbaas.allowed_extensions;
create table dbaas.allowed_extensions (id serial, name text);
insert into dbaas.allowed_extensions (name) values ('pgcrypto'); --You can check more in pg_available_extensions.
```
The table `dbaas.allowed_extensions` will contain a list of the extensions we allow our clients to install on thier own.

The following function will scan the list of allowed extensions and if the requested extension is present, will create it.


```sql
-- drop function dbaas.create_extension(p_extname TEXT,p_dbname TEXT);
CREATE OR REPLACE FUNCTION dbaas.create_extension(variadic p_extnames TEXT[])
RETURNS TEXT AS $$
DECLARE
 l_extension text;
 l_successful text := '';
 l_forbidden text:= '';
BEGIN
	FOREACH l_extension IN ARRAY p_extnames
	LOOP
		IF EXISTS (SELECT l_extension FROM allowed_extensions a WHERE a.name = l_extension)
		THEN
			EXECUTE '
			  CREATE EXTENSION '|| quote_ident(l_extension) || ';'
			USING l_extension;
			l_successful := l_successful || l_extension||', ';
		ELSE
			l_forbidden := l_forbidden || l_extension||', ';
		END IF;
	END LOOP;
	RETURN 'Extension(s) '|| SUBSTR(l_successful, 0, LENGTH(l_successful) - 1)||' created successfully.'||chr(10)||
	'You are not allowed to install the extension(s) '||SUBSTR(l_forbidden, 0, LENGTH(l_forbidden) - 1)||'. Please contact DBaaS team.';
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER
-- Set a secure search_path: trusted schema(s), then 'pg_temp' to prevent schema abuse.
SET search_path = dbaas, pg_temp;
REVOKE ALL ON FUNCTION dbaas.create_extension(p_extname TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION dbaas.create_extension(p_extname TEXT) TO <client username>;
GRANT USAGE ON schema dbaas to <client username>;
```

Then to create an extension as a non superuser, you will be able to run the following:

`select dbaas.create_extension('pgcrypto','hstore','jsquery');`

It will notify you which extensions have been installed successfully and which we do not allow.
An example of output:
```
Extensions pgcrypto, hstore created successfully.
You are not allowed to install the extensions jsquery. Please contact DBaaS team.
```
