# Docker Cloudflare DDNS

DDNS service for cloudflare

## Creating a Cloudflare API token

To create a CloudFlare API token for your DNS zone go to [https://dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens) and follow these steps:

* Click Create Token
* Provide the token a name, for example, cloudflare-ddns
* Grant the token the following permissions:
* `Zone` - `Zone Settings` - `Read`
* `Zone` - `Zone` - `Read`
* `Zone` - `DNS` - `Edit`
* Set the zone resources to:
* Include - All zones

## Deployment

```shell
docker run -d --name ddns \
  --restart=always \
  -e TOKEN=token \
  -e DOMAIN=example.com \
  -e CNAME=test \
  kdpuvvadi/cf-dddns:latest
```

With `docker-compose`

```yaml
version: "3"

services:
  ddns:
    container_name: ddns
    image: ddns
    environment:
      TOKEN: 'Token Here'
      DOMAIN: 'example.com'
      CNAME: 'cname'
    restart: unless-stopped
```

## LICENSE

Licensed under [MIT](/LICENSE)
