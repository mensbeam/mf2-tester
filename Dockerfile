# This defines a base "mftester" image from which other containers may inherit
FROM alpine:3.23
RUN apk --no-cache add bash jq parallel
ENV HOME=/home
WORKDIR /app