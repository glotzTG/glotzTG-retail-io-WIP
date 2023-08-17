cd retail-io/JustEnough.Net 
docker compose --parallel 1 build
docker compose --parallel 1 build --no-cache
--started up SQL
docker compose up -d

docker network connect justenough_default mssql-2022
--log in to JE.

--change in repo:
docker network disconnect justenough_default mssql-2022
docker compose down

--back up!
docker compose --parallel 1 build
docker compose up -d
docker network connect justenough_default mssql-2022