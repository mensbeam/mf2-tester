FROM golang:1.26.2
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY deps/go.mod deps/go.sum deps/
COPY languages/go/test-one.go languages/go/
WORKDIR /app/deps
RUN go build -mod=mod -o /usr/local/bin/test-one ../languages/go/test-one.go
