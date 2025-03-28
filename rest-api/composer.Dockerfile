FROM hhvm/hhvm:4.172.0

RUN apt-get autoremove -y; \
    apt-get update -y; \
    apt-get install php curl -y;

RUN curl -sS https://getcomposer.org/installer | php;\
    mv composer.phar /usr/local/bin/composer;\
    chmod +x /usr/local/bin/composer
RUN apt autoremove -y

WORKDIR /app
CMD ["composer"]
