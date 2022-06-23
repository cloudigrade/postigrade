FROM registry.access.redhat.com/ubi8/ubi-minimal:8.6

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    && rpm -ivh https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    && microdnf update \
    && microdnf install pgbouncer procps postgresql14 postgresql14-server nmap-ncat jq \
    && microdnf clean all \
    && pip3 install -U pip \
    && pip install flatten-dict==0.4.2 \
    && rm -rf /etc/pgbouncer/{pgbouncer.ini,userlist.txt,rdsca.cert} \
    && touch /etc/pgbouncer/{pgbouncer.ini,userlist.txt,rdsca.cert} \
    && chmod 777 /etc/pgbouncer/{pgbouncer.ini,userlist.txt,rdsca.cert} \
    && chmod 777 /var/{run,log}/pgbouncer

ADD json_to_env.py /json_to_env.py
ADD entrypoint.sh /entrypoint.sh
ADD clowder_init.sh /clowder_init.sh
ADD probe-liveness.sh /probe-liveness.sh
ADD probe-readiness.sh /probe-readiness.sh

# Default is 5432, For Clowder it is 8000
EXPOSE 5432 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
