FROM linuxserver/ddclient:4.0.0
ARG MY_DOMAIN

WORKDIR /config

COPY ddclient.conf.template postscript.sh ./
RUN sed "s/MY_DOMAIN/${MY_DOMAIN:?}/g" ddclient.conf.template > ddclient.conf
