FROM rust:1.95.0-slim
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY deps/Cargo.toml deps/Cargo.lock deps/
COPY languages/rust/test-one.rs languages/rust/
WORKDIR /app/deps
RUN cargo build --locked --release
