# Stage 1: Build React app
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]

# Note: React apps are static; this build them and serves with "nginx". The app will be exposed at port 3000 (mapped via k8s Service).