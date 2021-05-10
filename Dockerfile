FROM registry.access.redhat.com/ubi8/ubi-minimal:8.3

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
	&& microdnf update \
	&& microdnf install pgbouncer \
	&& rm -rf /etc/pgbouncer/{pgbouncer.ini,userlist.txt} \
	&& touch /etc/pgbouncer/{pgbouncer.ini,userlist.txt} \
	&& chmod 777 /etc/pgbouncer/{pgbouncer.ini,userlist.txt} \
	&& chmod 777 /var/{run,log}/pgbouncer

ADD entrypoint.sh /entrypoint.sh

EXPOSE 5432

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
