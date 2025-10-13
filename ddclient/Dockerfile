FROM linuxserver/ddclient:4.0.0
ARG MY_DOMAIN

WORKDIR /config

COPY ddclient.conf.template .
RUN sed "s/MY_DOMAIN/${MY_DOMAIN:?}/g" ddclient.conf.template > ddclient.conf \
    && rm ddclient.conf.template

RUN chown -R 194:194 /config

COPY postscript.sh /
