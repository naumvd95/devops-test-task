FROM alpine:3.11.5

ENV ERVCP_PORT 8080
COPY ./ /app/
WORKDIR app/

EXPOSE $ERVCP_PORT
ENTRYPOINT  ["./ervcp"]

