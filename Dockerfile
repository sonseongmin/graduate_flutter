# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM debian:bullseye AS build

# --- Flutter 및 빌드 도구 설치 ---
RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# --- Flutter SDK 설치 (3.27.1 강제 고정) ---
RUN rm -rf /usr/local/flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
WORKDIR /usr/local/flutter

# ✅ 전체 태그 fetch
RUN git fetch origin --tags

# ✅ 태그 존재 여부 로그로 출력
RUN git tag -l | grep 3.27.1

# ✅ 정확한 태그로 checkout
RUN git checkout refs/tags/3.27.1

# ✅ 환경 변수 설정
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# ✅ 채널을 stable로 강제 전환 (Dart 3.7 포함 버전)
RUN flutter channel stable
RUN flutter upgrade
RUN flutter doctor -v
RUN flutter precache --universal
RUN flutter --version
RUN dart --version

# --- 앱 디렉토리 이동 ---
WORKDIR /app

# --- Flutter Web 활성화 ---
RUN flutter config --enable-web

# --- pubspec 의존성 설치 ---
COPY pubspec.* ./
RUN flutter pub get

# --- 나머지 앱 복사 ---
COPY . .

# --- 정리 및 빌드 ---
RUN flutter clean
RUN flutter build web --release --no-tree-shake-icons -v


# ===== 2) Runtime Stage: Nginx =====
FROM nginx:alpine

# --- Flutter 빌드 결과 복사 ---
COPY --from=build /app/build/web /usr/share/nginx/html

# --- 사용자 정의 nginx.conf 복사 ---
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
