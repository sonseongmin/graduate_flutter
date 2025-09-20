# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM debian:bullseye AS build

# 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa wget && \
    rm -rf /var/lib/apt/lists/*

# Flutter SDK 설치 (stable 채널)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Flutter SDK 확인
RUN flutter --version && dart --version

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# ===== 2) Runtime Stage: Nginx =====
FROM nginx:alpine

# 👉 심플 default.conf로 교체 (SSL 없음, 정적 파일만)
COPY app.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/build/web/ /usr/share/nginx/html/

EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --retries=10 \
  CMD wget -qO- http://localhost:80/ || exit 1
