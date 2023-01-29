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
$ curl -s -XPOST -d '{"alias":"My custom error","status_code":"504","ctype":"text/html","content":"<h1>Sorry, something went wrong :(</h1>"}' -H'Content-Type: application/json' https://cr.iou.re/v1/customresponse | jq .
{
  "id": "cr_1f1e3b994eb04a2a9b465a8d33db9c61",
  "alias": "My custom error",
  "status_code": 504,
  "ctype": "text/html",
  "content": "<h1>Sorry, something went wrong :(</h1>"
}
```

2. Get the data from the custom response:

```
$ curl -s https://cr.iou.re/v1/customresponse/cr_1f1e3b994eb04a2a9b465a8d33db9c61 | jq .
{
  "id": "cr_1f1e3b994eb04a2a9b465a8d33db9c61",
  "alias": "My custom error",
  "status_code": "504",
  "ctype": "text/html",
  "content": "<h1>Sorry, something went wrong :(</h1>"
}
```

3. Get the actual custom response:

```
$ curl -vs https://cr.iou.re/v1/customresponse/cr_1f1e3b994eb04a2a9b465a8d33db9c61/r
*   Trying 127.0.0.1:7678...
* Connected to localhost (127.0.0.1) port 7678 (#0)
> GET /customresponse/cr_1f1e3b994eb04a2a9b465a8d33db9c61/r HTTP/1.1
> Host: https://cr.iou.re
> User-Agent: curl/7.87.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 504 Gateway Timeout
< date: Fri, 27 Jan 2023 21:33:21 GMT
< server: uvicorn
< content-length: 34
< content-type: text/html; charset=utf-8
<
* Connection #0 to host localhost left intact
<h1>Sorry, something went wrong :(</h1>
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
