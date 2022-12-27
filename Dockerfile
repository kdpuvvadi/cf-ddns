FROM alpine:latest
LABEL maintainer="KD Puvvadi"

RUN apk add --no-cache jq curl
WORKDIR  /app
COPY ./app .

ENV CF_API=https://api.cloudflare.com/client/v4

RUN chmod +x ./ddns.sh ./entry.sh
RUN /usr/bin/crontab ./crontab

ENTRYPOINT ["./entry.sh"]
