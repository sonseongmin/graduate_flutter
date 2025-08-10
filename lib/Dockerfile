# 1️⃣ Build stage - Flutter Web 빌드
FROM cirrusci/flutter:3.22.0 AS build
WORKDIR /app

# Flutter SDK 환경 설정
RUN flutter config --enable-web

# pubspec 파일만 복사 후 패키지 다운로드 (캐시 활용)
COPY pubspec.* ./
RUN flutter pub get

# 소스 복사 및 웹 빌드
COPY . .
RUN flutter build web --release

# 2️⃣ Serve stage - Nginx로 정적 파일 서빙
FROM nginx:1.25-alpine
COPY --from=build /app/build/web /usr/share/nginx/html

# Nginx 설정(SPA 라우팅 대응)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
