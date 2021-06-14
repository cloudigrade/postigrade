FROM registry.access.redhat.com/ubi8/ubi-minimal:8.3

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    && rpm -ivh https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    && microdnf update \
    && microdnf install pgbouncer procps postgresql13 postgresql13-server \
    && rm -rf /etc/pgbouncer/{pgbouncer.ini,userlist.txt} \
    && touch /etc/pgbouncer/{pgbouncer.ini,userlist.txt} \
    && chmod 777 /etc/pgbouncer/{pgbouncer.ini,userlist.txt} \
    && chmod 777 /var/{run,log}/pgbouncer

ADD entrypoint.sh /entrypoint.sh
ADD probe-readiness.sh /probe-readiness.sh

EXPOSE 5432

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
