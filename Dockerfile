FROM php:apache

RUN apt-get update && apt-get install -y cron \
    unzip \
    libaio-dev \
    php5-dev \
    supervisor \
    wget \
    python-pip && \
    pip install supervisor-stdout

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

RUN service apache2 restart

# Add crontab file in the cron directory
ADD config/crontab /etc/cron.d/importador

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/importador

# add to crontab
RUN crontab /etc/cron.d/importador

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Copy files over
ADD ./ /var/www/html

WORKDIR /var/www/html

# Change mod
RUN chmod 777 -R /var/www/html

CMD /usr/bin/supervisord -c config/supervisord.conf

EXPOSE 80

