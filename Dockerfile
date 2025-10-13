# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM debian:bullseye AS build

# --- Flutter 및 빌드 도구 설치 ---
RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# --- Flutter SDK 설치 (안정 버전 고정) ---
RUN rm -rf /usr/local/flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
WORKDIR /usr/local/flutter
RUN git checkout 3.27.1   
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter --version
RUN dart --version

WORKDIR /app

# --- Web 활성화 ---
RUN flutter config --enable-web

# --- 의존성 설치 ---
COPY pubspec.* ./
RUN flutter pub get

# --- 앱 복사 ---
COPY . .

# --- 정리 및 빌드 ---
RUN flutter clean
RUN flutter build web --release --no-tree-shake-icons --no-wasm-dry-run --web-renderer canvaskit -v


# ===== 2) Runtime Stage: Nginx =====
FROM nginx:alpine

# --- Flutter 빌드 결과 복사 ---
COPY --from=build /app/build/web /usr/share/nginx/html

# --- 사용자 정의 nginx.conf 복사 ---
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
