# Linux Docker 部署（CPU）

适用：Ubuntu 22.04 x86_64、无 GPU 的 ECS。4 核 8GB 为轻量演示的起步配置；一次提交一个算法任务，先用比赛准备的缩小图片验证速度和内存。当前配置不限制多个用户同时提交任务，不能据此保证大图、批量或并发任务在 8GB 下稳定运行。

## 本轮准备与验证范围

提供前端 Nginx、业务后端、算法平台、PostgreSQL 16、Redis 7 共五个服务。前端使用生产构建，`/prod-api/` 由 Nginx 转发到业务后端。只有前端默认映射宿主机 80 端口；数据库、Redis、9099 和算法 8000 端口仅供容器网络使用。

算法镜像使用 Python 3.10、PyTorch 2.5.1 CPU / torchvision 0.20.1 CPU、项目自带 ultralytics 8.3.9 及已有 DCNv2/DCNv3 CPU 兼容实现，移除旧 Dockerfile 中不存在的 wheels 与 CUDA 扩展构建。Linux 直接依赖写在算法目录的 `requirements-docker.txt`，构建使用包含传递依赖的 `requirements-docker-lock.txt`，不会覆盖本机 Python 环境。

本机没有可用 Docker Engine 或 WSL Linux。本轮可以验证配置、依赖、数据库初始化和前端构建；Linux 镜像构建、五服务联调、全部算法与实际峰值内存仍需到服务器验收。不得把之前 Windows 下算法通过的结果当成 Docker 验收。

本轮已通过官方 Compose CLI 配置校验、Linux 依赖版本与条件检查、前端干净安装及生产构建、隔离 PostgreSQL 15 初始化与迁移测试、脚本语法和私有配置防覆盖检查。前端构建及数据库测试在 Windows 上执行；PostgreSQL 16 容器尚未实际运行。具体记录见 [Docker 准备检查记录](verification/docker-preparation-2026-10-21.json)。

## 1. 准备服务器

购买页可保留“Docker 社区版”。服务器上确认：

```bash
docker version
docker compose version
```

需要 Docker Engine 和 Compose v2.24+；若扩展程序只安装了 Engine，按 [Docker 官方 Ubuntu 安装说明](https://docs.docker.com/engine/install/ubuntu/)补齐 Compose 插件。使用 root 或具有 Docker 权限的用户执行。不要重复覆盖已运行的 Docker 安装。

安全组允许管理用的 SSH 22 和网站 HTTP 80。当前文件只配置 HTTP；HTTPS 443 需要域名、证书与 Nginx TLS 配置后再使用。不要将 PostgreSQL、Redis 和算法管理接口开放到公网。

将整个项目上传到服务器，例如 `/opt/TransmissionLineDefectSystem`。包含中文、空格的算法目录保持原名。不要上传 Windows 的 `venv`、`node_modules`、`tmp`、`.git`、日志、实际 `.env.dev/.env.prod`；从 Git 恢复时保留全部模型权重。若已有本地业务记录，先看下文“迁移现有数据”。

## 2. 首次部署

```bash
cd /opt/TransmissionLineDefectSystem
bash scripts/deploy-docker.sh
```

脚本首次生成私有 `.env.docker`，随后依次构建镜像以降低同时构建的内存压力，等待数据库、Redis、算法服务与后端健康检查通过后启动网站。首次构建要联网下载系统包、PyTorch 与 npm 依赖，耗时取决于网络；下载失败时保留完整错误再重试。

部署后访问 `http://服务器公网IP/index`。初始账号 `admin`，随机密码位于 `.env.docker` 的 `ADMIN_PASSWORD`。这是全新数据库的初始密码，不是旧 Windows 系统的 `admin123`。可部署前编辑该值（8～72 个 UTF-8 字节，使用无空格的字母、数字、下划线或连字符最简单）。初始密码只设置一次；以后修改 `.env.docker` 不会重置已有账户。

`.env.docker` 同时保存数据库密码和 JWT 密钥，已从 Git 排除。不要删除后重新生成来“重置配置”，否则原数据库密码不会同步变化。配置脚本检测到已有文件会拒绝覆盖。

若宿主机 80 已被其他程序占用，可先运行 `python3 scripts/configure_docker.py --http-port 8088`，再启动部署脚本，并在安全组开放选定的端口。

若旧部署包在安装 PyTorch 时出现 `typing-extensions` 的 `inconsistent Name`，随后提示找不到 `flit_core`，请同步更新算法目录的 `Dockerfile`。修正版先安装 `pip==25.3`、`setuptools==79.0.1`、`wheel==0.45.1`，再以 `--no-deps` 从官方 CPU 源安装两个 PyTorch wheel，其余依赖按 `requirements-docker-lock.txt` 从 PyPI 安装。固定 wheel 版本也避免新 wheel 对 `packaging>=24.0` 的要求与项目锁定的 `packaging==23.2` 冲突。更新后重新运行 `bash scripts/deploy-docker.sh` 即可利用已有构建缓存继续；保留已经生成的 `.env.docker` 和迁移数据。

## 3. 验收

```bash
docker compose --env-file .env.docker ps
docker compose --env-file .env.docker logs --tail=100 backend algo-server
curl -f http://127.0.0.1/healthz
curl -f http://127.0.0.1/prod-api/captchaImage
docker stats --no-stream
```

登录后检查首页、算力平台、数据管理、任务、节点、监测地图和系统管理。算法平台地址应为 `http://algo-server:8000`，不填服务器公网 IP 或 `127.0.0.1`。逐个验证 11 个已登记入口的默认参数，确认输出文件可下载、任务确实成功；七类别模型仍按 ID 输出，不能编造类别名称。参照 `docs/算法接入说明.md` 测试所有模型及遮挡补全参数，再观察实际内存。

初始数据库使用原始 SQL 中的节点/目录资料及恢复后的菜单，不复制本机历史任务和上传图片。页面中的统计来自该数据库。迁移历史记录时必须同时迁移数据库和业务文件。

## 4. 日常启停与更新

```bash
# 暂停整个应用，保留容器和数据
docker compose --env-file .env.docker stop
# 重新启动，等待服务健康
docker compose --env-file .env.docker up -d --wait
# 更新代码后重建并应用
bash scripts/deploy-docker.sh
```

容器重建保留命名卷内的数据库、Redis、上传文件、头像、缓存及日志。算法源码、模型文件和两个 YAML 登记表挂载项目中的实际文件夹，网页修改算法/模型会写回服务器项目目录；更新代码前备份这些文件。新镜像替换后若后端地址变化，可运行 `docker compose --env-file .env.docker restart frontend` 刷新 Nginx 上游地址。

`docker compose down` 保留命名卷，但不要加 `-v`；`down -v` 会删除数据库和上传文件等数据卷。停止容器不会停止 ECS 的普通按量计费；临时停服务器需在阿里云控制台选择“节省停机模式”。释放服务器会影响其磁盘数据，必须提前导出。

## 5. 业务数据备份

等全部算法任务结束后，停止前端和后端，避免数据库与文件备份时间点不一致：

```bash
docker compose --env-file .env.docker stop frontend backend
bash scripts/backup-docker.sh
docker compose --env-file .env.docker up -d --wait
```

备份位置打印在终端，包含 PostgreSQL custom dump、上传文件与头像压缩包、算法/模型/登记表压缩包、私有环境文件及代码提交号。Redis 登录会话、缓存与日志无需用来恢复业务。脚本遇到已有同名备份文件会停止，未全部成功的目录不能当成完整备份。将备份目录下载到本地或其他独立位置；只存在服务器磁盘上的备份无法抵御实例释放。

Git 仅保护代码和已登记原模型，不保护数据库、上传图片、网站新增模型和私有环境文件。

## 6. 迁移现有 Windows 数据 / 恢复备份

迁移前先停止本机应用写入，使用 `pg_dump -Fc` 导出当前数据库，并复制 `backend/upload_file/`、`backend/vf_admin/`。保留目录内相对路径，不能只上传代码或数据库。不要复制 Windows 数据库数据目录到 Linux，也不要运行原始 `init.sql` 覆盖已有库。

Linux 服务器先执行一次正常部署，确认镜像可构建，再停止前端、后端和算法，导入前备份服务器当前数据。以下命令会替换目标服务器数据库，只用于你确认要恢复的目标环境：

```bash
docker compose --env-file .env.docker stop frontend backend algo-server
docker compose --env-file .env.docker exec -T postgres sh -c \
  'exec psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "DROP TABLE IF EXISTS docker_bootstrap;"'
docker compose --env-file .env.docker exec -T postgres sh -c \
  'exec pg_restore --clean --if-exists --no-owner --no-acl --exit-on-error -U "$POSTGRES_USER" -d "$POSTGRES_DB"' \
  < /path/to/database.dump
```

准备包含顶层 `upload_file/` 和 `vf_admin/` 的 `backend-files.tar.gz`，用挂载业务卷的临时容器恢复：

```bash
docker compose --env-file .env.docker run --rm --no-deps --entrypoint tar backend \
  -C /app -xzf - < /path/to/backend-files.tar.gz
docker compose --env-file .env.docker up -d --wait
```

若恢复本脚本生成的 Linux 备份，还需将 `algorithm-data.tar.gz` 解压到算法目录，按备份记录恢复匹配的代码和私有环境配置；数据库登录密码必须与新建数据库使用的凭据一致，不要盲目覆盖正在使用的 `.env.docker`。

启动入口将旧 `http://127.0.0.1:8000` / `http://localhost:8000` 平台改为容器地址，并把 `upload_file\\...` 相对文件路径规范为 Linux 斜杠；其他远程平台地址不改。若原库保存了 Windows 盘符开头的绝对路径，需核对真实文件后单独映射。导入的数据库保留原账户密码。恢复后重新验收登录、图片预览、结果下载、算法列表和实际执行。

## 参考

- [Docker Compose 健康检查与启动顺序](https://docs.docker.com/compose/how-tos/startup-order/)
- [PyTorch 官方历史 CPU 版本安装](https://pytorch.org/get-started/previous-versions/)
