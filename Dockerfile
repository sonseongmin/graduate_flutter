# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM debian:bullseye AS build

RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa wget && \
    rm -rf /var/lib/apt/lists/*

# Flutter SDK 설치 (stable 채널)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app

# 의존성 다운로드
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# 나머지 복사 및 빌드
COPY . .
RUN flutter doctor -v
RUN flutter precache --force --web
RUN flutter build web --release --no-tree-shake-icons --no-sound-null-safety
# ===== 2) Runtime Stage: Nginx =====
FROM nginx:alpine
COPY --from=build /app/build/web/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --retries=10 \
  CMD wget -qO- http://localhost:80/ || exit 1
