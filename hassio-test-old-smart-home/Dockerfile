# 由 Supervisor 注入正确的架构镜像，例如：
#   - ghcr.io/home-assistant/amd64-base:3.19
#   - ghcr.io/home-assistant/aarch64-base:3.19
#   - ...
ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8
ENV CK_API_ENV=prod

# 如果这个 base 是 Alpine，就用 apk；是 Debian 就用 apt
# 推荐你锁定一种类型的 base（看官方文档），不要混用

# 下面以 Alpine base 为例（常见）：
RUN apk add --no-cache \
    nodejs \
    npm \
    python3 \
    build-base

# 准备工作目录
WORKDIR /workspace
RUN mkdir -p /workspace/node_modules

# 拷贝代码和依赖
COPY ["./dist", "./package.json", "/workspace/"]
RUN npm install --production --save-exact
COPY ["./node_modules", "/workspace/node_modules/"]

# 拷贝入口脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# HA base 有自己的 init/s6，一般不再套一层 tini
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["npm", "start"]