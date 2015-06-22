FROM centos:centos6
MAINTAINER SHS 


RUN yum distribution-synchronization -y

RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm

RUN yum makecache

RUN yum -y update

RUN yum -y -q install net-snmp-devel net-snmp-libs net-snmp net-snmp-perl net-snmp-python net-snmp-utils mysql httpd php php-mysql php-snmp php-ldap install perl-JSON pwgen zabbix-agent zabbix-get zabbix-sender zabbix-server zabbix-server-mysql zabbix-web zabbix-web-mysql zabbix22-dbfiles-mysql monit mc lsof htop wget freetds unixODBC unixODBC-devel 

RUN yum clean all

RUN sed -i 's/^DocumentRoot "\/var\/www\/html"$/DocumentRoot "\/usr\/share\/zabbix"/' /etc/httpd/conf/httpd.conf

ADD /run.sh /
#RUN chmod 755 /run.sh

EXPOSE 80 10001 10051 
EXPOSE 162/udp

CMD ["/run.sh"]
