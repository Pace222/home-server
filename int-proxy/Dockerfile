FROM caddy:2.10.0-builder-alpine AS builder

RUN xcaddy build --with github.com/caddy-dns/infomaniak

FROM caddy:2.10.0

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
