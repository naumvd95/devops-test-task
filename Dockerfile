FROM alpine:3.11.5

ENV ERVCP_PORT 8080
ADD ervcp /bin/ervcp

EXPOSE $ERVCP_PORT
ENTRYPOINT  ["ervcp"]

