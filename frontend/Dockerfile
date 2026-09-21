# ==============================================================================
# Multi-Stage Dockerfile for React + Vite + Tailwind CSS (Node 24 LTS)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. DEVELOPMENT STAGE
# ------------------------------------------------------------------------------
# Used for local development with hot module reloading (HMR).
FROM node:24-alpine AS development

WORKDIR /app

# Copy dependency definitions first to leverage Docker layer caching
COPY package*.json ./

# Install development dependencies
RUN npm install

# Install gosu for seamless permission and UID/GID stepping down
RUN apk add --no-cache gosu

# Copy application source code into the image
COPY . .

# Copy entrypoint and make scripts executable
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    if [ -f /app/scripts/init_project.sh ]; then chmod +x /app/scripts/init_project.sh; fi

# Expose Vite development server port
EXPOSE 5173

# Entrypoint manages user UID/GID matching and runtime npm checks
ENTRYPOINT ["entrypoint.sh"]

# Default development command
CMD ["npm", "run", "dev"]


# ------------------------------------------------------------------------------
# 2. BUILD STAGE
# ------------------------------------------------------------------------------
# Compiles TypeScript and builds optimized static assets for production.
FROM node:24-alpine AS build

WORKDIR /app

# Copy dependency definition files
COPY package*.json ./

# Install clean dependencies required for the build process
RUN npm ci

# Copy full application source code
COPY . .

# Build production distribution bundle in /app/dist
RUN npm run build


# ------------------------------------------------------------------------------
# 3. PRODUCTION STAGE
# ------------------------------------------------------------------------------
# Serves static assets using a hardened, lightweight Nginx web server.
FROM nginx:1.27-alpine AS production

# Install curl utility for Docker container health check
RUN apk add --no-cache curl

# Copy custom Nginx configuration optimized for SPA fallback and Django reverse proxy
COPY nginx/nginx.prod.conf /etc/nginx/conf.d/default.conf

# Remove default Nginx welcome pages
RUN rm -rf /usr/share/nginx/html/*

# Copy built production assets from the build stage into Nginx web root
COPY --from=build /app/dist /usr/share/nginx/html

# Expose standard HTTP web port
EXPOSE 80

# Health check to ensure Nginx server is actively responding
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost/ || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
