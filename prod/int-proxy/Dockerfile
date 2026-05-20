FROM caddy:2.11.3-builder-alpine AS builder

RUN xcaddy build --with github.com/caddy-dns/infomaniak

FROM caddy:2.11.3-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
