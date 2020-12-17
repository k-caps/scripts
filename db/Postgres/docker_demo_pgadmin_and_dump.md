This is a demo, part of a presentation, in which I show how postgres and pgadmin can be installed and used very quickly.

# Preconfiguration
`docker pull ubuntu ; docker pull postgres`

# Install postgres on fresh ubuntu:
```
docker run -it --hostname pg-host-1 --name pg-host-1 -p 5432:5432 ubuntu bash
apt update
apt install -y postgresql postgresql-contrib
pg_ctlcluster 12 main start
```
# Remove ubuntu postgres
`docker rm -f pg-host-1`

# Installing 2 postgres instances with official postgres image:
```
docker run -d --hostname pg-host-1 --name pg-host-1 -p 5432:5432 -e POSTGRES_PASSWORD=admin postgres
docker run -d --hostname pg-host-2 --name pg-host-2 --link pg-host-1 -p 54321:5432 -e POSTGRES_PASSWORD=admin postgres
```

# Launch pgAdmin
```
docker run -d --name pgadmin --link pg-host-1 --link pg-host-2 -e "PGADMIN_DEFAULT_PASSWORD=qwe123" -e "PGADMIN_DEFAULT_EMAIL=postgres@pgadmin.com" -p 8080:80 dpage/pgadmin4
```
pgAdmin can now be accessed at `localhost:8080`

# SQL script:
```
CREATE TABLE public.demo_table
(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    occupation TEXT
);

INSERT INTO demo_table (name,occupation)
VALUES ('Zeus','King of the Gods'),
('Poseidon','Lord of the sea'),
('Hades','Master of the Underworld');
--COMMIT;
```
# dump data as file and copy to the host machine
```
docker exec -it -u postgres pg-host-1 bash
pg_dump postgres > ~/postgres_dmp.sql
docker cp pg-host-1:/var/lib/postgresql/postgres_dmp.sql ./
```

# Demonstrate how you can use linux to make the import process simpler
```
docker cp ./postgres_dmp.sql pg-host-2:/var/lib/postgresql/ && docker exec -it -u postgres pg-host-2 bash -c "psql < /var/lib/postgresql/postgres_dmp.sql"
```

# Clean up my environment
```
docker rm -f pg-host-1
docker rm -f pg-host-2
docker rm -f pgadmin
```
