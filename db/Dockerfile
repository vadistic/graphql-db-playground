FROM postgres:alpine
COPY ./schema/ /docker-entrypoint-initdb.d/
COPY ./data/ /docker-entrypoint-initdb.d/
