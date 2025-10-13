# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM debian:bullseye AS build

RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Flutter SDK 설치 (3.22.2 고정)
RUN rm -rf /usr/local/flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter 
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter --version
RUN dart --version

WORKDIR /app

# Flutter Web 활성화
RUN flutter config --enable-web

# 의존성 파일 복사 후 pub get
COPY pubspec.* ./
RUN flutter pub get

# 나머지 앱 복사
COPY . .

# flutter analyze는 실패해도 통과
RUN flutter analyze || true
# flutter 캐시 초기화 및 환경확인
RUN flutter doctor -v
# 깨끗하게 정리하고 빌드
RUN flutter clean
RUN flutter build web --release --no-tree-shake-icons --no-wasm-dry-run --web-renderer canvaskit -v

# ===== 2) Runtime Stage: Nginx =====
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
