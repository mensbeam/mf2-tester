FROM ghcr.io/astral-sh/uv:0.11.8-python3.14-trixie-slim
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*
WORKDIR /app/deps
COPY deps/pyproject.toml deps/uv.lock ./
RUN uv sync --locked
