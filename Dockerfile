# Stage 1: Build
FROM node:18-alpine AS builder

# Set working directory inside the container
WORKDIR /app

# Copy only package.json and package-lock.json to install dependencies
COPY package.json package-lock.json ./

# Install dependencies (use --legacy-peer-deps for conflicting dependencies)
RUN npm ci --only=production --legacy-peer-deps

# Copy all project files
COPY . .

# Build the Next.js application
RUN npm run build

# Stage 2: Production
FROM node:18-alpine

# Set environment to production
ENV NODE_ENV=production

# Set working directory inside the container
WORKDIR /app

# Copy only essential files from the builder stage
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Expose the default Next.js port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
