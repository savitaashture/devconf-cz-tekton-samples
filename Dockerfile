FROM golang AS builder

WORKDIR /go/src/firstApp
COPY . /go/src/firstApp
RUN CGO_ENABLED=0 go build -o /bin/firstApp .

FROM gcr.io/distroless/base
EXPOSE 8080
COPY --from=builder /bin/firstApp /app
ENTRYPOINT ["/app"]
