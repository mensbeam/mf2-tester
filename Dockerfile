# This defines a base "mftester" image from which other containers may inherit
FROM alpine
RUN apk --no-cache add bash jq
ENV HOME=/home
WORKDIR /app