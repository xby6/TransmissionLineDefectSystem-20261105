from sqlalchemy.ext.asyncio import AsyncSession
from module_algo.statistics.dao.statistics_dao import StatisticsDao
from utils.log_util import logger


class StatisticsService:
    """统计服务类，负责处理统计相关的业务逻辑"""
    
    @staticmethod
    async def get_all_statistics_services(db: AsyncSession):
        """获取所有模块的统计数据"""
        try:
            logger.info("开始获取所有模块的统计数据")
            statistics = await StatisticsDao.get_all_statistics(db)
            logger.info("成功获取所有模块的统计数据")
            return statistics
        except Exception as e:
            logger.error(f"获取统计数据失败: {str(e)}")
            raise e