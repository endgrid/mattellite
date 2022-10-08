
FROM docker.io/alpine:latest

RUN apk add --update nmap

COPY mattellite.sh /app/mattellite.sh
COPY sendmail.mc /etc/mail/sendmail.mc

ENV CIDR
ENV EMAIL

WORKDIR /app
USER 1000:1000

ENTRYPOINT [ "./mattellite.sh" ]
