FROM mftester
RUN apk --no-cache add composer
RUN apk --no-cache add php`php -r 'echo preg_replace("/^(\d+)\.(\d+).+/", "$1$2",PHP_VERSION);'`-dom