FROM caddy:2.11.3-builder-alpine AS builder

RUN xcaddy build --with github.com/fvbommel/caddy-dns-ip-range

FROM caddy:2.11.3-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
