FROM alpine
RUN apk --no-cache add bash composer jq
RUN apk --no-cache add php`php -r 'echo preg_replace("/^(\d+)\.(\d+).+/", "$1$2",PHP_VERSION);'`-dom
WORKDIR /app