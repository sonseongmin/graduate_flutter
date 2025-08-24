name: Frontend CI (Flutter Web → Docker Hub)

on:
  push:
    branches: ["main", "master"]
    paths:
      - "Dockerfile"
      - "nginx.conf"
      - "pubspec.yaml"
      - ".github/workflows/deploy.yml"
  workflow_dispatch:

env:
  DOCKER_IMAGE: sonseongmin/bodylog_frontend   # Docker Hub 리포 이름

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build & Push
        uses: docker/build-push-action@v6
        with:
          context: .               # 🔥 레포 루트 기준
          file: ./Dockerfile       # 🔥 루트에 있는 Dockerfile
          push: true
          tags: |
            ${{ env.DOCKER_IMAGE }}:latest
            ${{ env.DOCKER_IMAGE }}:${{ github.sha }}
          cache-from: type=registry,ref=${{ env.DOCKER_IMAGE }}:buildcache
          cache-to: type=registry,ref=${{ env.DOCKER_IMAGE }}:buildcache,mode=max
