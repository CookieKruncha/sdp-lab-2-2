# --- Stage 1: Build ---
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files and install all dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the application and build it
COPY . .
RUN npm run build

# Prune development dependencies so only production deps remain
RUN npm prune --omit=dev


# --- Stage 2: Production ---
FROM node:22-alpine

WORKDIR /app

# Copy ONLY the necessary files from the builder stage
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Run as non-root user
USER node

# Set default environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "build"]
