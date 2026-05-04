FROM ruby:4.0.3-slim
RUN apt-get update && apt-get install -y build-essential jq && rm -rf /var/lib/apt/lists/*
ENV BUNDLE_GEMFILE=/app/deps/Gemfile
WORKDIR /app/deps
COPY deps/Gemfile deps/Gemfile.lock ./
RUN bundle install
