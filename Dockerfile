# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM cirrusci/flutter:stable AS build
WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --web-renderer canvaskit --pwa-strategy=offline-first

# ===== 2) Runtime Stage: Nginx로 정적 서빙 =====
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf   # 🔥 nginx.conf 포함
COPY --from=build /app/build/web/ /usr/share/nginx/html/

EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=3s --retries=10 \
  CMD wget -qO- http://localhost:3000/ || exit 1