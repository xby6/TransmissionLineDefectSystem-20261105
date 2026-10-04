# 项目协作约定

- 正式项目目录为 `D:\Work_space\project\TransmissionLineDefectSystem`。后续开发、启动、验证和 Git 提交都在这个目录进行。
- 用户要求：每次完成一轮代码修改或项目文件修改，并完成相关验证后，都做一次 Git 提交备份。只有查询或说明、没有文件修改时，不制造空提交。
- 提交前检查 Git 差异；只提交本次任务的改动，不混入用户其他未提交修改。提交说明应描述具体改动及目的，最终回复报告提交短哈希和验证结果。
- 每次提交后，在 `D:\Work_space\project\TransmissionLineDefectSystem-backups` 下另存一份带时间戳的完整 Git bundle，验证 bundle 可读；不覆盖旧备份。本地 `.git` 和外部 bundle 都要保留。
- 提交后可运行 `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\backup-git.ps1` 完成 bundle 导出和校验；该脚本要求工作区已提交干净，不会自动暂存或提交其他人的修改。
- 不将数据库、上传数据、后端实际 `.env`、依赖目录、缓存和日志提交进 Git。业务数据发生修改时另做对应的数据备份。
- 不自动推送远程仓库。保留 `pdf-restored-v1.2.0` 与 `pdf-restored-v1.2.0-clean` 标签，方便恢复原 PDF 版本。
- 保留真实统计、原模型权重和检测流程。界面优化不得添加虚构任务、节点或检测结果。
