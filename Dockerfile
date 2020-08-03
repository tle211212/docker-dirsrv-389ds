FROM trunglt/centos7

LABEL maintainer "Trung Le <tle211212@gmail.com>" \
      name="389ds" \
      license="ASL v2" \
      description="Environment parameters: \
      DIRSRV_HOSTNAME : the hostname to be used with Directory Server, defaults to hostname --fqdn \
      DIRSRV_ADMIN_USERNAME : the admin user name, defaults to admin \
      DIRSRV_ADMIN_PASSWORD : the admin user password, defaults to admin@123 \
      DIRSRV_MANAGER_PASSWORD : the diretory manager password, defaults to admin@123 \
      DIRSRV_SUFFIX : the directory suffix, defaults to example.com"

COPY confd /etc/confd

COPY scripts/install-and-run-389ds.sh /install-and-run-389ds.sh

#     curl -qL https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 -o /usr/local/bin/confd && \

RUN  yum update -y && \
     yum -y install curl hostname httpd authconfig nss-tools && \
     yum -y install java-1.8.0-openjdk-headless  openssl procps-pg coreutils && \
     yum -y install 389-ds-base.x86_64 openldap-clients && \ 
     cp /etc/confd/confd /usr/local/bin/ && \
     chmod +x /usr/local/bin/confd && \
     chmod +x /install-and-run-389ds.sh && \
     sed -i 's/checkHostname {/checkHostname {\nreturn();/g' /usr/lib64/dirsrv/perl/DSUtil.pm  && \
     rm -fr /usr/lib/systemd/system && \
     sed -i 's/updateSelinuxPolicy($inf);//g' /usr/lib64/dirsrv/perl/* && \
     sed -i '/if (@errs = startServer($inf))/,/}/d' /usr/lib64/dirsrv/perl/* && \
     mkdir /etc/dirsrv-tmpl && mv /etc/dirsrv/* /etc/dirsrv-tmpl && \
     yum -y clean all && rm -rf /var/cache/yum/*

VOLUME ["/etc/dirsrv","/var/lib/dirsrv","/var/log/dirsrv"]

EXPOSE 389 9830

CMD ["/install-and-run-389ds.sh"]
