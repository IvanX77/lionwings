# Stage 1 (Build)
FROM golang:1.23.7-alpine AS builder

ARG VERSION
RUN apk add --update --no-cache git make
WORKDIR /app/
COPY go.mod go.sum /app/
RUN go mod download
COPY . /app/
RUN CGO_ENABLED=0 go build \
    -ldflags="-s -w -X github.com/IvanX77/lionwings/system.Version=$VERSION" \
    -v \
    -trimpath \
    -o lionwings \
    lionwings.go
RUN echo "ID=\"distroless\"" > /etc/os-release

# Stage 2 (Final)
FROM gcr.io/distroless/static:latest
COPY --from=builder /etc/os-release /etc/os-release

COPY --from=builder /app/lionwings /usr/bin/
CMD [ "/usr/bin/lionwings", "--config", "/etc/lionpanel/config.yml" ]

EXPOSE 8080
