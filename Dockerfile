# Use a lightweight web server as the base image
FROM nginx:alpine

# Copy your HTML files into the default Nginx web root directory
COPY ./ /usr/share/nginx/html

# Expose port 80, which is the default HTTP port
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
