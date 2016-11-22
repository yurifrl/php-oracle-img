FROM php:apache

RUN apt-get update && apt-get install -y unzip \
    libaio-dev \
    php5-dev

ENV ALLOW_OVERRIDE=true
ENV APACHE_LOG_DIR=/var/log/apache2/

# install oracle conector
ADD oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/
ADD oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_12_1 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so

RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8

# Copy php ini with extension oci8
COPY config/php.ini /usr/local/etc/php/

# Restart apache
RUN a2enmod rewrite

RUN service apache2 stop

WORKDIR /var/www/html

# Copy files over
ONBUILD ADD ./ /var/www/html

# Change mod
ONBUILD RUN chmod 777 -R /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]
