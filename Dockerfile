# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG NODE_VERSION=22.14.0

FROM node:${NODE_VERSION}-alpine

    
# Set working directory to the NestJS project root
WORKDIR /services/api/gawa

# Copy package files and install dependencies
COPY services/api/gawa/package*.json ./
RUN npm install

# Copy the rest of the source filesj
COPY services/api/gawa .

# Build the NestJS application
RUN npm run build

# Use production node environment by default.
ENV NODE_ENV=production

# Expose the port that the application listens on.
EXPOSE 8000

# Run the application as a non-root user.
USER node

# Run the compiled app
CMD ["node", "dist/main"]
