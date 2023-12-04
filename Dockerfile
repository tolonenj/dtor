# Use an official Node runtime as a parent image
FROM node:19-alpine as build
# Set the working directory to /app
WORKDIR /app
# Copy the package.json and package-lock.json to the container
COPY markku/package*.json ./
# Install dependencies
RUN npm ci
# Copy the rest of the application code to the container
COPY . .
# Build the React app
RUN npm run build

FROM nginx:alpine

# support running as arbitrary user which belongs to the root group
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx && \
    chown nginx.root /var/cache/nginx /var/run /var/log/nginx && \
    # users are not allowed to listen on privileged ports
    sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf && \
    # Make some modifications to index file
    sed -i.bak 's/web server/Joona dealer/' /usr/share/nginx/html/index.html && \
    sed -i.bak 's/nginx/nGInX/' /usr/share/nginx/html/index.html && \
    # Make /etc/nginx/html/ available to use
    mkdir -p /etc/nginx/html/ && chmod 777 /etc/nginx/html/ && \
    # comment user directive as master process is run as user in OpenShift anyhow
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

COPY --from=build /app/build /usr/share/nginx/html/
WORKDIR /usr/share/nginx/html/
EXPOSE 8081

USER nginx:root
