# Stage 1: Build
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install --frozen-lockfile

# Copy source code and build
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install only production dependencies
COPY package.json package-lock.json ./
RUN npm install --production --frozen-lockfile

# Copy the built application from the builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.js ./next.config.js

# Expose port and set environment variables
EXPOSE 3000
CMD ["npm", "start"]
