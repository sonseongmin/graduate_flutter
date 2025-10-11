# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM debian:bullseye AS build

RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa wget && \
    rm -rf /var/lib/apt/lists/*

# Flutter SDK 최신 stable 버전 설치
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Flutter 환경 준비
RUN flutter upgrade
RUN flutter doctor -v
RUN flutter config --enable-web
RUN flutter precache --force --web

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . ./
RUN flutter build web --release --no-tree-shake-icons -v || true

# ===== 2) Runtime Stage: Nginx =====
FROM nginx:alpine
COPY --from=build /app/build/web/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --retries=10 \
  CMD wget -qO- http://localhost:80/ || exit 1
