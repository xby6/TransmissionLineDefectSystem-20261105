# Git 备份与恢复说明

## 后续修改与界面版本

2026-10-04 完成界面美化，标签为 `ui-polished-v1.2.0`；`pdf-restored-v1.2.0-clean` 保留作为 PDF 原外观的恢复点。以下固定日期备份记录指最初整理版本。

从本次起，每轮修改完成并验证后进行 Git 提交，并运行 `scripts/backup-git.ps1`。新的完整历史备份位于 `TransmissionLineDefectSystem-backups/git-时间戳-提交短哈希/project.git.bundle`。恢复最新版本时，请使用对应的新 bundle；恢复命令中的标签也可替换为需要的提交或版本标签。

项目目录：`D:\Work_space\project\TransmissionLineDefectSystem`。

独立备份目录：`D:\Work_space\project\TransmissionLineDefectSystem-backups\20261004-200859`。这个目录在项目外，即使整个项目目录被误删，备份仍可用。请同时保留该目录；如需防止磁盘损坏，应再复制到其他磁盘。

## 已保存的版本

- `pdf-restored-v1.2.0`：PDF 恢复完成、清理前的代码。
- `pdf-restored-v1.2.0-clean`：清理后的独立项目，建议后续以此版本为恢复基准。
- `restored-system.git.bundle`：完整 Git 历史和以上标签，可离线重新克隆，不依赖原桌面目录或远程服务器。
- `original-restored.git.bundle`：另存的清理前版本。

代码、前端资源、两个原模型权重、依赖清单及文档都已纳入 Git。Python 虚拟环境、node_modules、日志、缓存、构建产物和运行数据不纳入 Git；可重装的本机运行依赖已在新目录准备好。

后端 `.env.dev` / `.env.prod` 包含本机连接配置，未提交到 Git；已复制到新项目，并单独保存在 `local-config.zip`。Git 中提供相应 `.example` 配置模板。

## 恢复误删的一个文件

先进入项目目录，再执行：

```powershell
cd D:\Work_space\project\TransmissionLineDefectSystem
git restore --source=pdf-restored-v1.2.0-clean -- backend/server.py
```

将 `backend/server.py` 换成需要恢复的相对路径。若误删已经提交到暂存区，可增加 `--staged --worktree`。恢复会覆盖指定文件当前的未提交修改，请先另存需要保留的修改。

## 在新目录恢复整套代码，保留当前改动

```powershell
cd D:\Work_space\project\TransmissionLineDefectSystem
git worktree add --detach D:\Work_space\project\TransmissionLineDefectSystem-Recovered pdf-restored-v1.2.0-clean
```

选择一个尚不存在的目标目录。该方式保留当前目录的后续修改，恢复出指定版本的完整受管文件；依赖、本机配置和业务数据需要另外准备。

## 整个项目及 .git 都被误删后的恢复

在目标目录不存在的情况下执行：

```powershell
git clone -c core.autocrlf=false D:\Work_space\project\TransmissionLineDefectSystem-backups\20261004-200859\restored-system.git.bundle D:\Work_space\project\TransmissionLineDefectSystem
git -C D:\Work_space\project\TransmissionLineDefectSystem checkout pdf-restored-v1.2.0-clean
```

仅删除 `.git` 不影响外部 bundle 中的历史。尚未提交过、被忽略的文件或备份之后产生的数据，不能通过这个版本的 Git 找回。

## 配套数据及环境

- `database.dump`：整理时 PostgreSQL `init` 数据库快照。
- `local-data.zip`：`backend/upload_file/` 及 `backend/vf_admin/`，含上传数据和结果文件。数据库文件路径已确认使用相对路径。
- `local-config.zip`：实际本机后端配置。
- `manifest.json`：备份范围、版本与整理信息。
- `migration-verification.json`：新目录启动、构建和 Git 误删恢复验收结果。

从备份恢复数据时，先将两个 ZIP 解压到项目根目录。数据库快照建议先导入一个新建的空数据库，再修改 `.env.dev` 指向它，避免覆盖后续新增业务数据。例如：

```powershell
createdb -h 127.0.0.1 -p 5432 -U postgres transmission_restored
pg_restore -h 127.0.0.1 -p 5432 -U postgres -d transmission_restored --no-owner --no-privileges D:\Work_space\project\TransmissionLineDefectSystem-backups\20261004-200859\database.dump
```

用户和权限需采用实际 PostgreSQL 管理账号，密码由终端提示输入；上述数据库操作没有在本次整理中执行，当前数据库仍保留。

依赖重建方式见 README。当前新目录已经可以直接使用 `start-system.ps1`，算法 Python、Node、PostgreSQL 和 Redis 仍采用这台电脑上的运行环境路径。

## 清理范围

新目录已删除停用且无运行引用的玉米表型前后端代码，以及算法重复 Dockerfile / 模型配置、Yarn 锁文件与配置；统一使用已验收的 npm 锁文件。前端副本、算法源码压缩包、旧备份、旧日志、IDE 配置、缓存、编译产物和旧测试输出未复制到新目录。

自定义 Ultralytics、模型结构、DCNv3、MMCV 等第三方源代码及许可文件保留，避免误删模型加载或后续编译依赖。新运行环境产生的缓存、日志、构建产物继续由 Git 忽略。

原桌面目录及此前恢复备份保留作迁移对照；后续开发请使用新目录。Git 仓库为本地备份，本次没有上传到远程网站。
