FROM harbor.itcom888.com/devops/xops-openresty

ADD . /usr/local/openresty/nginx/

EXPOSE 80
CMD ["/usr/bin/openresty", "-g", "daemon off;"]
