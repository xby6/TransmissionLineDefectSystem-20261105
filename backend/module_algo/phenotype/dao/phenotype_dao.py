from sqlalchemy import delete, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from module_algo.phenotype.entity.do.phenotype_do import PhenotypeInfo
from module_algo.phenotype.entity.vo.phenotype_vo import PhenotypeModel, PhenotypePageQueryModel
from utils.page_util import PageUtil


class PhenotypeDao:
    """
    玉米表型模块数据库操作层
    """

    @classmethod
    async def get_phenotype_detail_by_id(cls, db: AsyncSession, phenotype_id: int):
        phenotype_info = (
            (await db.execute(select(PhenotypeInfo).where(PhenotypeInfo.phenotype_id == phenotype_id)))
            .scalars()
            .first()
        )
        return phenotype_info

    @classmethod
    async def get_phenotype_detail_by_sample_code(cls, db: AsyncSession, sample_code: str):
        if not sample_code:
            return None
        phenotype_info = (
            (await db.execute(select(PhenotypeInfo).where(PhenotypeInfo.sample_code == sample_code)))
            .scalars()
            .first()
        )
        return phenotype_info

    @classmethod
    async def get_phenotype_list(cls, db: AsyncSession, query_object: PhenotypePageQueryModel, is_page: bool = False):
        query = (
            select(PhenotypeInfo)
            .where(
                PhenotypeInfo.sample_code.like(f'%{query_object.sample_code}%') if query_object.sample_code else True,
                PhenotypeInfo.maize_variety.like(f'%{query_object.maize_variety}%') if query_object.maize_variety else True,
                PhenotypeInfo.growth_stage.like(f'%{query_object.growth_stage}%') if query_object.growth_stage else True,
                PhenotypeInfo.plot_id == query_object.plot_id if query_object.plot_id else True,
            )
            .order_by(PhenotypeInfo.phenotype_id.desc())
            .distinct()
        )
        phenotype_list = await PageUtil.paginate(db, query, query_object.page_num, query_object.page_size, is_page)
        return phenotype_list

    @classmethod
    async def add_phenotype_dao(cls, db: AsyncSession, phenotype: PhenotypeModel):
        db_phenotype = PhenotypeInfo(**phenotype.model_dump(by_alias=False, exclude_unset=True, exclude_none=True))
        db.add(db_phenotype)
        await db.flush()
        return db_phenotype

    @classmethod
    async def edit_phenotype_dao(cls, db: AsyncSession, phenotype: dict):
        await db.execute(update(PhenotypeInfo), [phenotype])

    @classmethod
    async def delete_phenotype_dao(cls, db: AsyncSession, phenotype: PhenotypeModel):
        await db.execute(delete(PhenotypeInfo).where(PhenotypeInfo.phenotype_id.in_([phenotype.phenotype_id])))
