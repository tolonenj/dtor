# Use an official Node runtime as a parent image
FROM node:19-alpine as build
# Set the working directory to /app
WORKDIR /app
# Copy the package.json and package-lock.json to the container
COPY package*.json ./
# Install dependencies
RUN npm ci
# Copy the rest of the application code to the container
COPY . .
# Build the React app
RUN npm run build

# Use default Nginx image
FROM nginx
# Copy the nginx.conf to the container
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx && \
    chown nginx.root /var/cache/nginx /var/run /var/log/nginx && \
    # Make /etc/nginx/html/ available to use
    mkdir -p /etc/nginx/html/ && chmod 777 /etc/nginx/html/ && \
    # comment user directive as master process is run as user in OpenShift anyhow
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

# Copy the React app build files to the container
COPY --from=build /app/build /usr/share/nginx/html/
# Expose port 8081 for Nginx
WORKDIR /usr/share/nginx/html/
EXPOSE 8081

USER nginx:root

# Start Nginx when the container starts
#CMD ["nginx", "-g", "daemon off;"]
