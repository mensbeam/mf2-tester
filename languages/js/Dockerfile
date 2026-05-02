FROM node:24.15.0-slim
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*
WORKDIR /app/deps
COPY deps/package.json deps/package-lock.json ./
RUN npm ci --silent
