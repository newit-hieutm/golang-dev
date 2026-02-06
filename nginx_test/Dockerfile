FROM nginx:latest

# Remove default config
RUN rm -f /etc/nginx/conf.d/default.conf

# Copy our config
COPY myapp.conf /etc/nginx/conf.d/myapp.conf

# Hide server tokens (security best practice from the original script)
RUN sed -i 's/# server_tokens/server_tokens/' /etc/nginx/nginx.conf && \
    sed -i 's/server_tokens on;/server_tokens off;/' /etc/nginx/nginx.conf
