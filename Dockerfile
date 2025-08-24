# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM ghcr.io/cirruslabs/flutter:3.27.2 AS build
WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --web-renderer canvaskit --pwa-strategy=offline-first

# ===== 2) Runtime Stage: Nginx로 정적 서빙 =====
FROM nginx:alpine

#nginx.conf 포함
COPY nginx.conf /etc/nginx/conf.d/default.conf   
COPY --from=build /app/build/web/ /usr/share/nginx/html/

EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=3s --retries=10 \
  CMD wget -qO- http://localhost:3000/ || exit 1