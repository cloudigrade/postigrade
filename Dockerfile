FROM registry.access.redhat.com/ubi9:9.7-1764163501 as base

RUN dnf install -y \
    nmap-ncat \
    python3 \
    python3-pip \
    procps \
    && dnf module install --assumeyes postgresql:16/server postgresql:16/client \
    && pip3 install -U pip \
    && pip install flatten-dict==0.4.2

FROM base as build

RUN dnf install -y\
      gcc \
      gcc-c++ \
      kernel-headers \
      make \
      zlib-devel \
      pcre-devel \
      openssl-devel \
      libxml2-devel \
      libxslt-devel \
      libevent-devel \
      gd-devel \
      perl

WORKDIR /tmp/src

COPY src .

RUN ./configure --prefix=/usr/local \
    && make \
    && make install \
    && dnf clean all \
    && mkdir /etc/pgbouncer \
    && mkdir /var/{run,log}/pgbouncer \
    && rm -rf /etc/pgbouncer/{pgbouncer.ini,userlist.txt,rdsca.cert} \
    && touch /etc/pgbouncer/{pgbouncer.ini,userlist.txt,rdsca.cert} \
    && chmod 777 /etc/pgbouncer/{pgbouncer.ini,userlist.txt,rdsca.cert} \
    && chmod 777 /var/{run,log}/pgbouncer

RUN rm -rf /tmp/src

ADD json_to_env.py /json_to_env.py
ADD entrypoint.sh /entrypoint.sh
ADD clowder_init.sh /clowder_init.sh
ADD probe-liveness.sh /probe-liveness.sh
ADD probe-readiness.sh /probe-readiness.sh

# Default is 5432, For Clowder it is 8000
EXPOSE 5432 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
