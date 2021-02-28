FROM raphaellorencini/laravel_nginx_mysql:latest

WORKDIR /var/www/html

# Nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/conf/* /etc/nginx/conf.d/
RUN rm /etc/nginx/conf.d/example.conf

RUN mkdir /var/www/docker
COPY ./entrypoint.sh /var/www/docker/entrypoint.sh
RUN chmod 775 /var/www/docker/entrypoint.sh

# Supervisor
COPY ./supervisord.conf /etc/supervisord.conf

RUN usermod -u 1000 www-data
RUN usermod -a -G users www-data

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/bin/bash","/var/www/docker/entrypoint.sh"]