# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM debian:bullseye AS build

RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa wget && \
    rm -rf /var/lib/apt/lists/*

# Flutter SDK 고정 (3.19.6 버전이 Dart 3.7.x와 호환)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b 3.19.6
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app

# 의존성 사전 준비
COPY pubspec.yaml pubspec.lock* ./
RUN flutter config --enable-web
RUN flutter pub get || true
RUN flutter doctor -v

# 앱 복사
COPY . .

# 빌드 전 코드 분석 (에러 출력용)
RUN flutter analyze || true

# 캐시 미사용 강제 빌드 (문제 추적용)
RUN flutter build web --release --no-tree-shake-icons -v --no-pub || (cat /app/.dart_tool/flutter_build/* 2>/dev/null || true)

# ===== 2) Runtime Stage: Nginx =====
FROM nginx:alpine
COPY --from=build /app/build/web/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --retries=10 \
  CMD wget -qO- http://localhost:80/ || exit 1
