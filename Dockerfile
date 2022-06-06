# Stage1
FROM golang:1.16-alpine3.15 as builder

WORKDIR /app

# copy modules manifests files
COPY go.mod go.mod
COPY go.sum go.sum

# cache modules
RUN go mod download

# copy source code
COPY main.go main.go

# build
RUN : \
    && CGO_ENABLED=0 go build \
       -a -o leaderelection main.go \
    && :

# Stage 2
FROM alpine:3.16.0

RUN addgroup -S sharmio && adduser -S sharmio -G sharmio

RUN : \
    && apk --no-cache add ca-certificates \
    && :

USER sharmio

COPY --from=builder --chown=sharmio:sharmio /app/leaderelection .

ENTRYPOINT ["./leaderelection"]
