# ---- Build stage ----
FROM golang:1.21-alpine AS builder

# Install Git (needed if modules reference VCS)
RUN apk add --no-cache git

# Set working directory
WORKDIR /build

# Copy go.mod/go.sum first (for caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source
COPY . .

# Build the binary
RUN go build -o ratio-spoof .

# ---- Final stage ----
FROM alpine:latest

# Add CA certs (optional; needed if HTTPS tracker access is ever used)
RUN apk add --no-cache ca-certificates

# Copy the compiled binary
COPY --from=builder /build/ratio-spoof /usr/local/bin/ratio-spoof

# Default entrypoint (so you can do `docker run ratio-spoof`)
ENTRYPOINT ["ratio-spoof"]
