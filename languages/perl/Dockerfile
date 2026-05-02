FROM perl:5.42.2-slim
RUN apt-get update && apt-get install -y build-essential jq libexpat1-dev && rm -rf /var/lib/apt/lists/*
RUN cpanm --notest Carton
WORKDIR /app/deps
COPY deps/cpanfile deps/cpanfile.snapshot ./
RUN carton install
