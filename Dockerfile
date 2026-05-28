# ============================================
# TeleDoc Frontend — Multi-Stage Production Build
# ============================================
# Stage 1: Build React app
# Stage 2: Serve with NGINX (production-optimized)
# ============================================

# --- Stage 1: Build ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first (Docker layer caching)
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci --legacy-peer-deps

# Copy source code
COPY . .

# Build production bundle
RUN npm run build

# --- Stage 2: Production ---
FROM nginx:1.25-alpine AS production

# Copy custom NGINX config
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy built React app from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost/health || exit 1

# Expose port 80
EXPOSE 80

# NGINX runs in foreground
CMD ["nginx", "-g", "daemon off;"]
