# =============================================================================
# naqoda/centos-apache-php
#
# CentOS-7, Apache 2.2, PHP 5.5, Ioncube, MYSQL, DB2
#
# =============================================================================
FROM centos:centos6

# update system
RUN yum -y update

# Install HTTPD
RUN yum install httpd -y

# Install repo
RUN rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm

# -----------------------------------------------------------------------------
# UTC Timezone & Networking
# -----------------------------------------------------------------------------
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
    && echo "NETWORKING=yes" > /etc/sysconfig/network

# -----------------------------------------------------------------------------
# Purge - this removes localedef
# -----------------------------------------------------------------------------
RUN rm -rf /etc/ld.so.cache \ 
    ; rm -rf /sbin/sln \
    ; rm -rf /usr/{{lib,share}/locale,share/{man,doc,info,gnome/help,cracklib,il8n},{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive} \
    ; rm -rf /{root,tmp,var/cache/{ldconfig,yum}}/* \
    ; > /etc/sysconfig/i18n

# -----------------------------------------------------------------------------
# Apache
# -----------------------------------------------------------------------------
RUN yum --setopt=tsflags=nodocs -y install \
    unzip \
    mod_ssl \
    && rm -rf /var/cache/yum/* \
    && yum clean all

# -----------------------------------------------------------------------------
# PHP
# -----------------------------------------------------------------------------

RUN yum --setopt=tsflags=nodocs -y install \
    php56w-opcache \
    php56w-devel \
    php56w \
    php56w-cli \
    php56w-mysql \
    php56w-pdo \
    php56w-mbstring \
    php56w-soap \
    php56w-gd \
    php56w-xml \
    php56w-pecl-apcu \
    && rm -rf /var/cache/yum/* \
    && yum clean all

# -----------------------------------------------------------------------------
# Set locale
# -----------------------------------------------------------------------------
# RUN rpm -qf /usr/bin/localedef
# RUN yum provides '*/localedef'
# RUN localedef -i pt_BR -c -f UTF-8 -A /usr/share/locale/locale.alias pt_BR.UTF-8
# ENV LANG pt_BR.utf8

# -----------------------------------------------------------------------------
# Set ports
# -----------------------------------------------------------------------------
EXPOSE 80 443

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
ADD index.php /var/www/html/index.php

CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
