from fastapi import APIRouter, Depends, Form, Request, BackgroundTasks
from pydantic_validation_decorator import ValidateFields
from sqlalchemy.ext.asyncio import AsyncSession
from config.enums import BusinessType
from config.get_db import get_db
from config.database import AsyncSessionLocal
from module_admin.annotation.log_annotation import Log
from module_admin.aspect.interface_auth import CheckUserInterfaceAuth
from module_admin.entity.vo.user_vo import CurrentUserModel
from module_admin.service.login_service import LoginService
from module_algo.task.service.task_service import TaskService
from module_algo.container.service.container_service import ContainerService
from module_algo.task.entity.vo.task_vo import DeleteTaskModel, TaskModel, TaskPageQueryModel
from utils.common_util import bytes2file_response
from utils.log_util import logger
from utils.page_util import PageResponseModel
from utils.response_util import ResponseUtil
import httpx
import json
import io
import uuid
import zipfile
from pathlib import Path
from typing import List, Dict, Union
from datetime import datetime
from module_algo.file.entity.do.file_do import File
from module_algo.file.service.file_service import FileService
from module_algo.task.entity.do.task_do import Task
from sqlalchemy import select



taskController = APIRouter(prefix='/task/task', dependencies=[Depends(LoginService.get_current_user)])


@taskController.get(
    '/list', response_model=PageResponseModel, dependencies=[Depends(CheckUserInterfaceAuth('task:task:list'))]
)
async def get_task_task_list(
    request: Request,
    task_page_query: TaskPageQueryModel = Depends(TaskPageQueryModel.as_query),
    query_db: AsyncSession = Depends(get_db),
    current_user: CurrentUserModel = Depends(LoginService.get_current_user),
):
    dept_id = current_user.user.dept_id
    task_page_query.dept = dept_id
    # 获取分页数据
    task_page_query_result = await TaskService.get_task_list_services(query_db, task_page_query, is_page=True, dept_id=dept_id)
    logger.info('获取成功')

    return ResponseUtil.success(model_content=task_page_query_result)


@taskController.post('', dependencies=[Depends(CheckUserInterfaceAuth('task:task:add'))])
@ValidateFields(validate_model='add_task')
@Log(title='任务', business_type=BusinessType.INSERT)
async def add_task_task(
    request: Request,
    add_task: TaskModel,
    query_db: AsyncSession = Depends(get_db),
    current_user: CurrentUserModel = Depends(LoginService.get_current_user),
):
    dept_id = current_user.user.dept_id
    add_task.dept = dept_id
    add_task_result = await TaskService.add_task_services(query_db, add_task)
    logger.info(add_task_result.message)

    return ResponseUtil.success(msg=add_task_result.message)


@taskController.put('', dependencies=[Depends(CheckUserInterfaceAuth('task:task:edit'))])
@ValidateFields(validate_model='edit_task')
@Log(title='任务', business_type=BusinessType.UPDATE)
async def edit_task_task(
    request: Request,
    edit_task: TaskModel,
    query_db: AsyncSession = Depends(get_db),
    current_user: CurrentUserModel = Depends(LoginService.get_current_user),
):
    dept_id = current_user.user.dept_id
    edit_task.dept = dept_id
    edit_task_result = await TaskService.edit_task_services(query_db, edit_task)
    logger.info(edit_task_result.message)

    return ResponseUtil.success(msg=edit_task_result.message)


@taskController.delete('/{ids}', dependencies=[Depends(CheckUserInterfaceAuth('task:task:remove'))])
@Log(title='任务', business_type=BusinessType.DELETE)
async def delete_task_task(request: Request, ids: str, query_db: AsyncSession = Depends(get_db),
current_user: CurrentUserModel = Depends(LoginService.get_current_user)):
    dept_id = current_user.user.dept_id
    delete_task = DeleteTaskModel(ids=ids)
    delete_task_result = await TaskService.delete_task_services(query_db, delete_task, dept_id)
    logger.info(delete_task_result.message)

    return ResponseUtil.success(msg=delete_task_result.message)


@taskController.get(
    '/{id}', response_model=TaskModel, dependencies=[Depends(CheckUserInterfaceAuth('task:task:query'))]
)
async def query_detail_task_task(request: Request, id: int, query_db: AsyncSession = Depends(get_db)):
    task_detail_result = await TaskService.task_detail_services(query_db, id)
    logger.info(f'获取id为{id}的信息成功')

    return ResponseUtil.success(data=task_detail_result)


@taskController.post(
    "/stop",
    dependencies=[Depends(CheckUserInterfaceAuth('task:task:remove'))]
    )
async def stop_task(
    task_id: int,
    query_db: AsyncSession = Depends(get_db),
    current_user: CurrentUserModel = Depends(LoginService.get_current_user)
):
    """
    停止指定任务
    """
    dept_id = current_user.user.dept_id
    # 获取容器信息
    task = await query_db.get(Task, task_id)
    if task is None or task.dept != dept_id:
        logger.warning(f'任务不存在: {task_id}')
        return ResponseUtil.failure(msg="任务不存在")


    if task.state not in {'queued', 'running'}:
        return ResponseUtil.failure(msg='任务当前未在执行')
    if task.state == 'queued':
        task.state = 'stop'
        task.end_time = datetime.now()
        await query_db.commit()
        return ResponseUtil.success(msg='任务已取消')
    container = await ContainerService.container_detail_services(query_db, task.container)
    if container.dept != dept_id:
        logger.warning(f'容器不存在: {container.id}')
        return ResponseUtil.failure(msg="容器不存在")
    # Commit cancellation first: there may be no remote process between two
    # invocations, and the background worker must not launch the next one.
    task.state = 'stop'
    task.end_time = datetime.now()
    await query_db.commit()
    # 转发请求到容器服务
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                        f"{container.url}/stop", 
                        data={"task_id": task_id},
                        headers={"Content-Type": "application/x-www-form-urlencoded"}
                    )
            if response.status_code in {200, 404}:
                return ResponseUtil.success(msg='任务已停止')
            response.raise_for_status()
    except Exception as e: # 假设服务器错误或其他httpx错误不会导致404，因此直接捕获Exception
        logger.error(f'任务停止失败: {str(e)}')
        return ResponseUtil.failure(msg='任务已取消，但暂时无法确认算法平台进程已停止，请检查平台连接')




async def process_invocation(
        db: AsyncSession, # 这个 db 是从 background_processor 传递过来的会话
        client: httpx.AsyncClient,
        root: int,
        name: str,
        args: Dict[str, Union[List[int], float, str]],
        dept_id: int):
    """
    处理单个算法调用的核心逻辑
    参数：
    - db: 数据库会话对象
    - client: 复用HTTP客户端实例
    - args: 单个调用的参数字典
    - dept_id: 发起请求的用户部门
    """
    file_ids = args["file_ids"]
    del args["file_ids"]

    # 注意：这里返回 ResponseUtil.failure 不太合适，因为这是后台任务，不是HTTP响应。
    # 应该抛出异常让上层捕获处理。
    file_records = await db.execute(select(File).where(File.id.in_(file_ids), File.dept == dept_id))
    file_records = file_records.scalars().all()
    if len(file_records) != len(file_ids):
        logger.warning(f'部分文件不存在: {file_ids}')
        raise ValueError("部分文件不存在，无法进行算法处理") # 抛出异常

    # 创建临时压缩文件
    zip_buffer = io.BytesIO()
    with zipfile.ZipFile(zip_buffer, "w") as zip_file:
        for file_record in file_records:
            # 添加文件到压缩包
            # 注意：这里直接打开文件可能存在路径问题或并发问题，
            # 确保 Path(file_record.path) 是可访问且文件存在的。
            try:
                with open(Path(file_record.path), "rb") as f:
                    file_data = f.read()
                zip_file.writestr(file_record.name, file_data)
            except FileNotFoundError:
                logger.error(f"文件未找到：{file_record.path}")
                raise FileNotFoundError(f"无法找到文件：{file_record.name}")


    task_id = args["task_id"]
    del args["task_id"]

    # 重新获取 task 对象以便在当前会话中确保其最新状态
    task = await db.get(Task, task_id)
    if not task or task.dept != dept_id:
        logger.warning(f'Task with id {task_id} not found')
        raise ValueError(f"任务 {task_id} 不存在或无权访问") # 抛出异常

    container = await ContainerService.container_detail_services(db, task.container)
    if not container or container.dept != dept_id:
        logger.warning(f'Container with id {task.container} not found')
        raise ValueError(f"容器 {task.container} 不存在、无效或无权访问") # 抛出异常
    url = container.url
    algo = task.algo

    zip_buffer.seek(0)

    try:
        # 发送压缩文件请求，设置超时时间为 60 秒
        response = await client.post(
            f'{url}/process',
            files={"file": ("input_files.zip", zip_buffer, "application/zip")},
            data={"task_id": str(task_id), "algo_name": algo, "args_json": json.dumps(args)},
            timeout=86400
        )
        response.raise_for_status()
        # 创建结果目录
        result_dir = Path("./upload_file/results") / str(uuid.uuid4())
        result_dir.mkdir(parents=True, exist_ok=True)

        # 保存返回文件到目录（假设返回的是zip）
        with zipfile.ZipFile(io.BytesIO(response.content)) as response_zip:
            response_zip.extractall(result_dir)

        # 创建目录记录
        new_result_dir_record = File( # 修改变量名以区分
            name=name,
            root=root,
            type="dir",
            upload_time=datetime.now(),
            dept = dept_id
        )

        db.add(new_result_dir_record)
        await db.flush() # 使用 flush() 来获取 new_result_dir_record 的 ID
        await db.refresh(new_result_dir_record)

        # 创建文件记录（如果需要记录单个文件）
        # 这里所有的 db.add 操作都发生在一个事务中，最终由 background_processor 提交
        for file_path in result_dir.iterdir():
                file_record = File(
                    name=file_path.name,
                    path=str(file_path),
                    root=new_result_dir_record.id,
                    type=file_path.suffix.lower() if file_path.suffix else "unknown",
                    upload_time=datetime.now(),
                    dept = dept_id,
                    size=file_path.stat().st_size,
                )
                db.add(file_record)
        # REMOVE: await db.commit() # <<< 移除这一行！
        # REMOVE: await db.refresh(new_result_dir_record) # <<< 移除，因为它已经在 flush 后刷新过

        return new_result_dir_record.id

    except Exception as e:
        # 在这里不需要 db.rollback()，因为整个事务的回滚由 background_processor 负责
        # REMOVE: await db.rollback() # <<< 移除这一行！
        logger.error(f"处理调用 {name} 时发生错误: {e}")
        raise e # 重新抛出异常，让 background_processor 的 except 块捕获处理



async def background_processor(task_id: int, dept_id: int, args: List[Dict]):
    try:
        async with AsyncSessionLocal() as db:
            task = await db.get(Task, task_id)
            if task is None or task.dept != dept_id or task.state != 'queued':
                return
            task.state = 'running'
            task.result = None
            task.end_time = None
            await db.commit()
            await db.refresh(task)
            result_folder = File(name=task.name, root=0, type='dir', upload_time=datetime.now(), dept=dept_id)
            db.add(result_folder)
            await db.flush()
            result_ids = []
            async with httpx.AsyncClient() as client:
                for index, invocation in enumerate(args, 1):
                    current = dict(invocation, task_id=task_id)
                    result_ids.append(await process_invocation(db, client, result_folder.id,
                                                              f'{task.name}---{index}', current, dept_id))
                    await db.refresh(task)
                    if task.state == 'stop':
                        await db.rollback()
                        return
            task.state = 'success'
            task.result = result_ids[0] if len(result_ids) == 1 else result_folder.id
            task.end_time = datetime.now()
            await db.commit()
    except Exception as exc:
        logger.exception(f'后台任务 {task_id} 处理失败：{exc}')
        # 原会话已退出，用独立会话可靠记录失败，避免任务永远显示运行中。
        async with AsyncSessionLocal() as failure_db:
            failed_task = await failure_db.get(Task, task_id)
            if failed_task is not None and failed_task.state != 'stop':
                failed_task.state = 'failed'
                failed_task.end_time = datetime.now()
                failed_task.result = None
                await failure_db.commit()


@taskController.post("/process", dependencies=[Depends(CheckUserInterfaceAuth('task:task:remove'))])
@Log(title='任务处理', business_type=BusinessType.OTHER)
async def process_task(
    request: Request,
    task_id: int,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: CurrentUserModel = Depends(LoginService.get_current_user),
    ):
    """
    处理任务端点
    流程：
    1. 校验任务、算法和容器是否存在
    2. 提取用户身份
    3. 提交后台任务处理
    4. 立即返回响应
    """
        # 校验任务是否存在
    dept_id = current_user.user.dept_id
    task = (await db.execute(select(Task).where(Task.id == task_id).with_for_update())).scalars().first()
    if not task or task.dept != dept_id:
        logger.warning(f'任务不存在或无权访问: {task_id}')
        return ResponseUtil.failure(msg="任务不存在或无权访问")
    
    if task.state in {'queued', 'running'}:
        return ResponseUtil.failure(msg='该任务正在执行，请勿重复提交')
    container_id = task.container
    # 校验容器是否存在
    container = await ContainerService.container_detail_services(db, container_id)
    if not container or not container.url or container.dept != dept_id:
        logger.warning(f'容器不存在、无效或无权访问: {container_id}')
        return ResponseUtil.failure(msg="容器不存在、无效或无权访问")

    try:
        # 解析参数JSON
        args: Dict[str, List[Dict[str, Union[List[int], float, str]]]] = json.loads(task.args)
        invocations = args.get('args') if isinstance(args, dict) else None
        if not isinstance(invocations, list) or not invocations or any(
            not isinstance(item, dict) or not isinstance(item.get('file_ids'), list) or not item['file_ids']
            for item in invocations
        ):
            return ResponseUtil.failure(msg='任务参数必须包含非空的 args 和 file_ids 列表')
        task.state = 'queued'
        task.end_time = None
        task.result = None
        await db.commit()
        background_tasks.add_task(background_processor, task_id, dept_id, invocations)
    except json.JSONDecodeError:
        logger.error(f'参数格式无效: {task_id}')
        return ResponseUtil.failure(msg="参数格式无效，必须是JSON字符串")
    except Exception as e:
        logger.error(f'处理任务失败: {str(e)}')
        return ResponseUtil.failure(msg=f'处理任务失败: {str(e)}')

    logger.info(f'任务已提交，正在处理中: {task_id}')
    return ResponseUtil.success(
        msg="任务已提交，正在处理中",
        data={"task_id": task_id}
    )

