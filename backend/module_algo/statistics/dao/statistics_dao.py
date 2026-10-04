from collections import Counter
from datetime import datetime, timedelta
import asyncio
import httpx
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from module_algo.task.entity.do.task_do import Task
from module_algo.file.entity.do.file_do import File
from module_algo.container.entity.do.container_do import Container
from module_algo.node.entity.do.node_do import NodeInfo


class StatisticsDao:
    """按数据库实际记录统计；平台运行状态通过算法服务探测。"""

    @staticmethod
    async def get_task_statistics(db: AsyncSession) -> dict:
        total = (await db.execute(select(func.count(Task.id)))).scalar() or 0
        statuses = (await db.execute(select(Task.state, func.count(Task.id)).group_by(Task.state))).all()
        today = datetime.now().date()
        dates = (await db.execute(
            select(func.date(Task.init_time), func.count(Task.id))
            .where(Task.init_time >= datetime.combine(today - timedelta(days=6), datetime.min.time()))
            .group_by(func.date(Task.init_time))
        )).all()
        counts = {str(day): count for day, count in dates}
        return {'total': total,
                'by_status': [{'status': status or 'pending', 'count': count} for status, count in statuses],
                'by_date': [{'date': str(today - timedelta(days=i)), 'count': counts.get(str(today - timedelta(days=i)), 0)} for i in range(6, -1, -1)]}

    @staticmethod
    async def get_file_statistics(db: AsyncSession) -> dict:
        types = (await db.execute(select(File.type, func.count(File.id)).group_by(File.type))).all()
        roots = (await db.execute(select(File.root, func.count(File.id)).group_by(File.root))).all()
        normalized = Counter()
        for file_type, count in types:
            normalized[str(file_type or 'unknown').lower().lstrip('.')] += count
        return {'total': sum(normalized.values()),
                'image_total': sum(normalized[key] for key in ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'tif', 'tiff']),
                'by_type': [{'type': key, 'count': count} for key, count in normalized.items()],
                'by_root': [{'root': str(root), 'count': count} for root, count in roots]}

    @staticmethod
    async def get_container_statistics(db: AsyncSession) -> dict:
        platforms = (await db.execute(select(Container))).scalars().all()
        async def check(client, platform):
            try:
                response = await client.get(f'{platform.url.rstrip("/")}/list')
                response.raise_for_status()
                return 'running'
            except (httpx.HTTPError, AttributeError):
                return 'stopped'
        async with httpx.AsyncClient(timeout=1.5, trust_env=False) as client:
            statuses = Counter(await asyncio.gather(*(check(client, item) for item in platforms)))
        types = Counter(str(item.type or 'unknown') for item in platforms)
        return {'total': len(platforms),
                'by_status': [{'status': key, 'count': count} for key, count in statuses.items()],
                'by_type': [{'type': key, 'count': count} for key, count in types.items()]}

    @staticmethod
    async def get_node_statistics(db: AsyncSession) -> dict:
        nodes = (await db.execute(select(NodeInfo))).scalars().all()
        def normalize(status):
            return 'online' if str(status).lower() in {'0', '健康', '正常', 'online', 'active', 'normal'} else 'offline'
        statuses = Counter(normalize(item.status) for item in nodes)
        return {'total': len(nodes),
                'by_status': [{'status': key, 'count': count} for key, count in statuses.items()],
                'locations': [{'id': item.id, 'name': item.name, 'longitude': item.longitude,
                               'latitude': item.latitude, 'status': normalize(item.status)} for item in nodes]}

    @staticmethod
    async def get_all_statistics(db: AsyncSession) -> dict:
        return {'tasks': await StatisticsDao.get_task_statistics(db),
                'files': await StatisticsDao.get_file_statistics(db),
                'containers': await StatisticsDao.get_container_statistics(db),
                'nodes': await StatisticsDao.get_node_statistics(db)}
