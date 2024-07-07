FROM golang:1.16.5-buster AS runner
RUN apt-get update && apt-get install -y gcc g++

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

WORKDIR /workdir
COPY extra/initial-data /extra/initial-data

# certificates
COPY webapp/certificates/tls-cert.pem /usr/lib/ssl/certs/tls-cert.pem
COPY webapp/certificates ./
RUN update-ca-certificates

COPY bench/go.mod bench/go.sum ./
COPY bench/random ./random
RUN go mod download

