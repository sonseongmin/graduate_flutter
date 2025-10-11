# ===== 1) Build Stage: Flutter Web 빌드 =====
FROM debian:bullseye AS build

RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa wget && \
    rm -rf /var/lib/apt/lists/*

# Flutter SDK 3.7.2 버전 고정
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
WORKDIR /usr/local/flutter
RUN git checkout 3.7.2

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter config --enable-web
RUN flutter pub get --no-precompile

COPY . ./
RUN flutter doctor -v
RUN flutter precache --force --web
RUN flutter build web --release --no-tree-shake-icons --no-sound-null-safety

FROM nginx:alpine
COPY --from=build /app/build/web/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --retries=10 \
  CMD wget -qO- http://localhost:80/ || exit 1
