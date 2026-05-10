FROM composer:latest AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev -q

FROM php:8.5-cli
WORKDIR /app
COPY --from=vendor /app/vendor ./vendor
COPY run-tests.php ./
ENV TESTS_DIR=/var/lib/mf2-tester/tests
ENV RESULTS_DIR=/var/lib/mf2-tester/results
ENV VERSION_FILE=/var/lib/mf2-tester/results/version
ENTRYPOINT ["php", "/app/run-tests.php"]
