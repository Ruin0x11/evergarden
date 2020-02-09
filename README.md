# evergarden
Proxies the szurubooru API as a Danbooru 2 API so that a szurubooru instance can be accessed through existing Danbooru 2 mobile apps.

## Usage
As part of a `docker-compose` setup:

```yaml
version: '2'

services:
  #
  # ...szurubooru services...
  #
  # api:
  # client:
  # sql:
  # elasticsearch:

  evergarden:
    image: localhost:5000/evergarden
    depends_on:
      - api # szurubooru api service
    restart: always
    expose:
        - "5000"
    environment:
      # internal docker hostname of szurubooru client service
      SZURUBOORU_HOST: http://client
      # external DNS name of szurubooru frontend
      EXTERNAL_SZURUBOORU_HOST: http://bijutsu.nori.daikon
      # for nginx-proxy
      VIRTUAL_HOST: evergarden.nori.daikon
      VIRTUAL_PORT: 5000
    networks:
      # make sure the container has access to the network szurubooru uses.
      - szuru

networks:
  szuru:
    driver: bridge
```

# TODO
- favorite support
- pool support
