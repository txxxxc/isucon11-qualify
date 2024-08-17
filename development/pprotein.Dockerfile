# --------------------------------------------------
FROM alpine AS pprotein

WORKDIR /home/pprotein

RUN apk add --no-cache wget 

RUN wget https://github.com/kaz/pprotein/releases/download/v1.2.3/pprotein_1.2.3_linux_amd64.tar.gz

RUN tar -xvf pprotein_1.2.3_linux_amd64.tar.gz

# --------------------------------------------------

FROM golang:alpine AS alp

RUN go install github.com/tkuchiki/alp/cmd/alp@latest

# --------------------------------------------------

FROM golang:alpine AS slp

RUN apk add gcc musl-dev
RUN go install github.com/tkuchiki/slp/cmd/slp@latest

# --------------------------------------------------

FROM alpine AS server

RUN apk add --no-cache graphviz

COPY --from=alp /go/bin/alp /usr/local/bin/
COPY --from=slp /go/bin/slp /usr/local/bin/
COPY --from=pprotein /home/pprotein/pprotein /usr/local/bin/

RUN mkdir -p /opt/pprotein
WORKDIR /opt/pprotein

CMD [ "pprotein" ]

# # --------------------------------------------------
#
# FROM alpine AS pprotein-agent
#
#
# COPY --from=pprotein /home/pprotein/pprotein-agent /usr/local/bin/
#
# WORKDIR /opt/pprotein-agent
#
# CMD [ "pprotein-agent" ]
