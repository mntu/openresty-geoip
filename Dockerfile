FROM openresty/openresty:alpine-fat

RUN apk add --no-cache curl bash libmaxminddb-dev build-base tar tzdata

RUN luarocks install lua-resty-maxminddb \
    && luarocks install lua-cjson

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

COPY update-geoip.sh /usr/local/bin/update-geoip.sh
RUN chmod +x /usr/local/bin/update-geoip.sh

RUN mkdir -p /data

RUN echo "0 0 1 * * /usr/local/bin/update-geoip.sh >> /var/log/geoip_update.log 2>&1" >> /etc/crontabs/root

CMD ["/bin/sh", "-c", "crond && openresty -g 'daemon off;'"]
