FROM ghcr.io/kdpuvvadi/alpine:latest
LABEL maintainer="KD Puvvadi"

WORKDIR  /app
COPY ./app .

ENV CF_API=https://api.cloudflare.com/client/v4

RUN chmod +x ./ddns.sh ./entry.sh
RUN /usr/bin/crontab ./crontab

ENTRYPOINT ["./entry.sh"]
