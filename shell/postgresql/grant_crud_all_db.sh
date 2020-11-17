#!/bin/bash

user="user_name"

db_list=`psql -t  <<SQL
select datname from pg_database where datname not like '%template%';
SQL`
echo $db_list |grep -v template

for db in $db_list; do
psql <<SQL
\connect $db;
GRANT CONNECT ON DATABASE "$db" TO "$user";
GRANT USAGE ON SCHEMA public TO "$user";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "$user";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "$user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "$user";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO "$user";

\q
SQL
done
