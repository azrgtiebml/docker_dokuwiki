FROM ubuntu:14.04

# Set the version you want of Twiki
#ENV DOKUWIKI_VERSION 2017-02-19b
ENV DOKUWIKI_VERSION 4f8e7d4306b067959271cb17b43f2949
#ENV DOKUWIKI_CSUM ea11e4046319710a2bc6fdf58b5cda86
ENV DOKUWIKI_CSUM 1062C8C4A23CF4986307984FFECE0F5C

ENV LAST_REFRESHED 12. August 2016

# Update & install packages & cleanup afterwards
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install mc wget lighttpd php5-cgi php5-gd php5-ldap php5-curl && \
    apt-get clean autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}

# Download & check & deploy dokuwiki & cleanup
RUN wget -q -O /dokuwiki.tgz "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" && \
    if [ "$DOKUWIKI_CSUM" != "$(md5sum /dokuwiki.tgz | awk '{print($1)}')" ];then echo "Wrong md5sum of downloaded file!"; exit 1; fi && \
    mkdir /dokuwiki && \
    tar -zxf dokuwiki.tgz -C /dokuwiki --strip-components 1 && \
    rm dokuwiki.tgz

# Set up ownership
RUN chown -R www-data:www-data /dokuwiki

# Configure lighttpd
ADD dokuwiki.conf /etc/lighttpd/conf-available/20-dokuwiki.conf
RUN lighty-enable-mod dokuwiki fastcgi accesslog
RUN mkdir /var/run/lighttpd && chown www-data.www-data /var/run/lighttpd

EXPOSE 8080
VOLUME ["/dokuwiki/data/","/dokuwiki/lib/plugins/","/dokuwiki/conf/","/dokuwiki/lib/tpl/","/var/log/"]

ENTRYPOINT ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
