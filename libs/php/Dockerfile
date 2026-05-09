FROM alpine
RUN apk --no-cache add bash composer jq
RUN export PHP_VERSION=`php -r 'echo preg_replace("/^(\d+)\.(\d+).+/", "$1$2",PHP_VERSION);'`
RUN apk --no-cache add php$PHP_VERSION-dom php$PHP_VERSION-mbstring
WORKDIR /app