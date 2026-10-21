# 输电线路缺陷智能检测系统 V1.2.0

这是按使用说明恢复并整理后的独立项目。后续开发请使用本目录。

页面已完成统一美化，更新记录见 `docs/界面美化说明.md`。每次完成修改并验证后提交 Git，再运行 `scripts/backup-git.ps1` 保存项目外的完整 Git 备份；协作规则见 `AGENTS.md`。

## 本机启动

```powershell
cd D:\Work_space\project\TransmissionLineDefectSystem
powershell -ExecutionPolicy Bypass -File .\start-system.ps1
```

访问 http://127.0.0.1:8088/index ，账号 `admin`，密码 `admin123`。

停止由本目录启动脚本管理的服务：

```powershell
powershell -ExecutionPolicy Bypass -File .\stop-system.ps1
```

PostgreSQL 15 数据库 `init` 和 Redis 使用本机已有服务。启动器将算法、业务后端、前端分别运行于 8000、9099、8088 端口；不要同时启动旧目录和新目录。后端配置在 `backend/.env.dev`，启动日志在 `tmp/runtime/`。

## 目录

- `frontend/`：Vue 前端，使用 npm 和 package-lock.json。
- `backend/`：FastAPI 业务服务、系统管理、SQL 初始结构。
- `Intelligent Detection System for Transmission Line Defects-server/`：算法平台、自定义模型实现、原模型与新增分割权重。
- `scripts/`：数据库迁移与验收脚本，日常启动不需要执行数据库迁移。
- `docs/verification/`：恢复阶段的验收记录和截图。
- `系统恢复说明.md`：恢复内容、已验证功能及 PDF 差异。
- `Git备份与恢复说明.md`：版本标签、误删文件恢复、整套代码恢复和配套数据备份位置。

## 算法接入

2026-10-14 已按说明文档核对可辨认的八个算法入口，并接入提供的 DeepLab 权重、语义增强和遮挡补全流程。创建任务时选择“本地输电线路算法平台”，新增入口和默认参数会自动加载。

来源、接口、结果格式、验收记录及材料缺口见 [算法接入说明](docs/算法接入说明.md)。七类别 Xception 权重缺少类别名称表，当前按类别 ID 输出结果。

## 重新安装依赖

本机整理版已准备好后端虚拟环境和前端依赖。若从 Git 重新克隆，先从配套 ZIP 恢复本机配置和业务文件，再重建依赖：

```powershell
D:\tool\Python\Python311\python.exe -m venv backend\venv
.\backend\venv\Scripts\python.exe -m pip install -r backend\requirements-local-lock.txt
cd frontend
npm ci
cd ..
```

算法服务使用 `D:\tool\Python310\python.exe` 中已验收的 PyTorch 2.5.1 CPU 环境。算法依赖见算法目录的 requirements.txt；必须加载项目内自定义 ultralytics，不能替换为普通 PyPI 包。Node 和 Redis 路径可通过启动脚本参数设置。

数据库和上传数据不由 Git 管理。不要在当前已有数据的数据库上直接运行 init.sql；恢复数据时优先新建空数据库，具体说明见 Git 恢复文档。

## Linux Docker 部署

2026-10-21 按 Linux + Docker 方案整理五服务 Compose、生产前端 Nginx、CPU 算法镜像、私有配置生成、初始化与数据备份流程。服务器上运行 `bash scripts/deploy-docker.sh`；完整步骤、现有数据迁移及验收边界见 [Linux Docker 部署说明](docs/Linux-Docker部署说明.md)。本机没有 Docker Engine，容器构建和云端算法运行仍需服务器实测。
