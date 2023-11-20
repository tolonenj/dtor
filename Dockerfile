FROM nginx:alpine

# support running as arbitrary user which belongs to the root group
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx && \
    chown nginx.root /var/cache/nginx /var/run /var/log/nginx && \
    # users are not allowed to listen on privileged ports
    sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf && \
    # Make some modifications to index file
    sed -i.bak 's/web server/Joona dealer/' /usr/share/nginx/html/index.html && \
    # Make /etc/nginx/html/ available to use
    mkdir -p /etc/nginx/html/ && chmod 777 /etc/nginx/html/ && \
    # comment user directive as master process is run as user in OpenShift anyhow
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

WORKDIR /usr/share/nginx/html/
EXPOSE 8081

USER nginx:root
