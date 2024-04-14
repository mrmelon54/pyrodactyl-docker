FROM node:latest AS builder

WORKDIR /src
COPY panel .

RUN npm install -g pnpm turbo
RUN npm install
RUN pnpm ship
RUN rm -rf /src/.git

FROM ghcr.io/pterodactyl/panel:v1.11.5
WORKDIR /app
COPY --from=builder /src/ /app/
RUN cp .env.example .env \
    && mkdir -p bootstrap/cache/ storage/logs storage/framework/sessions storage/framework/views storage/framework/cache \
    && chmod 777 -R bootstrap storage \
    && composer install --no-dev --optimize-autoloader \
    && rm -rf .env bootstrap/cache/*.php \
    && mkdir -p /app/storage/logs/ \
    && chown -R nginx:nginx .

COPY panel/.github/docker/default.conf /etc/nginx/http.d/default.conf
COPY panel/.github/docker/www.conf /usr/local/etc/php-fpm.conf
COPY panel/.github/docker/supervisord.conf /etc/supervisord.conf

EXPOSE 80 443
ENTRYPOINT [ "/bin/ash", ".github/docker/entrypoint.sh" ]
CMD [ "supervisord", "-n", "-c", "/etc/supervisord.conf" ]
