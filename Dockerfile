FROM nginx
VOLUME /tmp
ENV LANG en_US.UTF-8
ADD ./public/ /usr/share/nginx/html/
EXPOSE 80
EXPOSE 443