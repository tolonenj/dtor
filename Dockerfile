# Use an official Node runtime as a parent image
FROM node:19-alpine as build
# Set the working directory to /app
WORKDIR /app
# Copy the package.json and package-lock.json to the container
COPY reactapp/package*.json ./
# Install dependencies
RUN npm ci
# Copy the rest of the application code to the container
COPY reactapp/ .
# Build the React app
RUN npm run build

# FROM nginx:alpine
FROM nginxinc/nginx-unprivileged:1.15.12

# support running as arbitrary user which belongs to the root group
# RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx && \
#    chown nginx.root /var/cache/nginx /var/run /var/log/nginx && \
#    # users are not allowed to listen on privileged ports
#    sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf && \
#    # Make /etc/nginx/html/ available to use
#    mkdir -p /etc/nginx/html/ && chmod 777 /etc/nginx/html/ && \
#    # comment user directive as master process is run as user in OpenShift anyhow
#    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

COPY --from=build /app/build /usr/share/nginx/html
WORKDIR /usr/share/nginx/html/
EXPOSE 8080

#USER nginx:root
