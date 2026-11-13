FROM golang:1.25-alpine AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o app ./cmd/api

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /build/app .
EXPOSE 8081
CMD ["./app"]