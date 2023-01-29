# Custom Responses

A simple PoC that creates and serves custom responses.

Components:

* Fastapi
* pydantic
* Redis as the only DB
* Some JS

## Demo

A demo instance is up (for the moment) here: [https://cr.iou.re/](https://cr.iou.re/)  
the content resets periodically.  

## Basic API usage

1. Create a new custom response:  

```
$ curl -s -XPOST -d '{"alias":"My custom response - created OK","status_code":"201","ctype":"text/html","content":"<h2>Created OK =)</h2>"}' -H'Content-Type: application/json' https://cr.iou.re/v1/customresponse | jq .
{
  "id": "cr_9534ae413a074697881977734fc5a3b4",
  "alias": "My custom response - created OK",
  "status_code": 201,
  "ctype": "text/html",
  "content": "<h2>Created OK =)</h2>"
}
```

2. Get the data from the custom response:  

```
$ curl -s 'https://cr.iou.re/v1/customresponse/cr_9534ae413a074697881977734fc5a3b4' | jq .
{
  "id": "cr_9534ae413a074697881977734fc5a3b4",
  "alias": "My custom response - created OK",
  "status_code": "201",
  "ctype": "text/html",
  "content": "<h2>Created OK =)</h2>"
}
```

3. Get the actual custom response:  

```
$ curl -vs 'https://cr.iou.re/v1/customresponse/cr_9534ae413a074697881977734fc5a3b4/r'
*   Trying 143.47.51.89:443...
* Connected to cr.iou.re (143.47.51.89) port 443 (#0)
* ALPN: offers h2
* ALPN: offers http/1.1
* [CONN-0-0][CF-SSL] TLSv1.3 (OUT), TLS handshake, Client hello (1):
* [CONN-0-0][CF-SSL] TLSv1.3 (IN), TLS handshake, Server hello (2):
* [CONN-0-0][CF-SSL] TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* [CONN-0-0][CF-SSL] TLSv1.3 (IN), TLS handshake, Certificate (11):
* [CONN-0-0][CF-SSL] TLSv1.3 (IN), TLS handshake, CERT verify (15):
* [CONN-0-0][CF-SSL] TLSv1.3 (IN), TLS handshake, Finished (20):
* [CONN-0-0][CF-SSL] TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* [CONN-0-0][CF-SSL] TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256
* ALPN: server accepted h2
* Server certificate:
*  subject: CN=cr.iou.re
*  start date: Jan 29 10:57:06 2023 GMT
*  expire date: Apr 29 10:57:05 2023 GMT
*  subjectAltName: host "cr.iou.re" matched cert's "cr.iou.re"
*  issuer: C=US; O=Let's Encrypt; CN=R3
*  SSL certificate verify ok.
* Using HTTP2, server supports multiplexing
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* h2h3 [:method: GET]
* h2h3 [:path: /v1/customresponse/cr_9534ae413a074697881977734fc5a3b4/r]
* h2h3 [:scheme: https]
* h2h3 [:authority: cr.iou.re]
* h2h3 [user-agent: curl/7.87.0]
* h2h3 [accept: */*]
* Using Stream ID: 1 (easy handle 0x121814a00)
> GET /v1/customresponse/cr_9534ae413a074697881977734fc5a3b4/r HTTP/2
> Host: cr.iou.re
> user-agent: curl/7.87.0
> accept: */*
>
* [CONN-0-0][CF-SSL] TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* Connection state changed (MAX_CONCURRENT_STREAMS == 250)!
< HTTP/2 201
< alt-svc: h3=":443"; ma=2592000
< content-type: text/html; charset=utf-8
< date: Sun, 29 Jan 2023 12:43:54 GMT
< server: Caddy
< server: uvicorn
< strict-transport-security: max-age=31536000;
< content-length: 22
<
* Connection #0 to host cr.iou.re left intact
<h2>Created OK =)</h2>
```

4. Edit the custom response:  

```
$ curl -s -XPUT -d '{"alias":"My custom response - created OK","status_code":"201","ctype":"text/html","content":"<h2>Created OK!! =)</h2>"}' -H'Content-Type: application/json' https://cr.iou.re/v1/customresponse/cr_9534ae413a074697881977734fc5a3b4 | jq .
{
  "id": "cr_2754c17810314805a7fd1d30ba87f6a1",
  "alias": "My custom response - created OK",
  "status_code": 201,
  "ctype": "text/html",
  "content": "<h2>Created OK!! =)</h2>"
}
```

## Deployment example with Caddy and docker compose

docker-compose.yaml:  

```yaml
---
volumes:
  caddy_data: {}
  caddy_config: {}
  redisdb: {}

x-logging: &default-logging
  driver: json-file
  options:
    max-size: "16m"
    max-file: "2"
    compress: "true"

services:
  caddy:
    restart: unless-stopped
    image: caddy:latest
    container_name: caddy
    logging: *default-logging
    ports:
      - "0.0.0.0:80:80"
      - "0.0.0.0:443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config

  customresponses:
    restart: unless-stopped
    container_name: customresponses
    hostname: customresponses
    logging: *default-logging
    image: aorith/customresponses:latest
    command: python -m uvicorn customresponses.main:app --host 0.0.0.0 --port 7678
    ports:
      - 127.0.0.1:7678:7678
    depends_on:
      redis:
        condition: service_healthy

  redis:
    restart: on-failure
    container_name: redis
    hostname: redis
    image: redis:7-alpine
    entrypoint: /usr/bin/env
    command: redis-server --save 60 1 --loglevel warning
    logging: *default-logging
    volumes:
      - redisdb:/data
    healthcheck:
      test: ["CMD", "/usr/local/bin/redis-cli", "ping"]
      interval: 30s
      timeout: 3s
    deploy:
      resources:
        limits:
          memory: 375M
        reservations:
          memory: 250M
```

Caddyfile:  

```
YOUR.DOMAIN {
  tls YOUR.EMAIL.ADDRESS

  reverse_proxy customresponses:7678 {
    header_down Strict-Transport-Security max-age=31536000;
  }
}
```
