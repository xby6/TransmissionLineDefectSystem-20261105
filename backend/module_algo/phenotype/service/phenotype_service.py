from typing import List
import pandas as pd
from sqlalchemy.ext.asyncio import AsyncSession
from exceptions.exception import ServiceException
from module_admin.entity.vo.common_vo import CrudResponseModel
from module_algo.phenotype.dao.phenotype_dao import PhenotypeDao
from module_algo.phenotype.entity.vo.phenotype_vo import DeletePhenotypeModel, PhenotypeModel, PhenotypePageQueryModel
from utils.common_util import CamelCaseUtil
from utils.excel_util import ExcelUtil


class PhenotypeService:
    """
    玉米表型模块服务层
    """

    @classmethod
    async def get_phenotype_list_services(cls, query_db: AsyncSession, query_object: PhenotypePageQueryModel, is_page: bool = False):
        return await PhenotypeDao.get_phenotype_list(query_db, query_object, is_page)

    @classmethod
    async def add_phenotype_services(cls, query_db: AsyncSession, page_object: PhenotypeModel):
        if not page_object.sample_code:
            raise ServiceException(message='样本编号不能为空')
        if not page_object.maize_variety:
            raise ServiceException(message='玉米品种不能为空')
        if not page_object.plot_id:
            raise ServiceException(message='所属地块ID不能为空')
        try:
            await PhenotypeDao.add_phenotype_dao(query_db, page_object)
            await query_db.commit()
            return CrudResponseModel(is_success=True, message='新增成功')
        except Exception as e:
            await query_db.rollback()
            raise e

    @classmethod
    async def edit_phenotype_services(cls, query_db: AsyncSession, page_object: PhenotypeModel):
        edit_phenotype = page_object.model_dump(by_alias=False, exclude_unset=True, exclude_none=True)
        phenotype_info = await cls.phenotype_detail_services(query_db, page_object.phenotype_id)
        if phenotype_info is not None:
            try:
                await PhenotypeDao.edit_phenotype_dao(query_db, edit_phenotype)
                await query_db.commit()
                return CrudResponseModel(is_success=True, message='更新成功')
            except Exception as e:
                await query_db.rollback()
                raise e
        raise ServiceException(message='表型数据不存在')

    @classmethod
    async def delete_phenotype_services(cls, query_db: AsyncSession, page_object: DeletePhenotypeModel):
        if page_object.ids:
            id_list = page_object.ids.split(',')
            try:
                for phenotype_id in id_list:
                    await PhenotypeDao.delete_phenotype_dao(query_db, PhenotypeModel(phenotype_id=phenotype_id))
                await query_db.commit()
                return CrudResponseModel(is_success=True, message='删除成功')
            except Exception as e:
                await query_db.rollback()
                raise e
        raise ServiceException(message='传入ID为空')

    @classmethod
    async def phenotype_detail_services(cls, query_db: AsyncSession, phenotype_id: int):
        phenotype = await PhenotypeDao.get_phenotype_detail_by_id(query_db, phenotype_id=phenotype_id)
        if phenotype:
            return PhenotypeModel(**CamelCaseUtil.transform_result(phenotype))
        return None

    @staticmethod
    async def export_phenotype_list_services(phenotype_list: List):
        mapping_dict = {
            'phenotypeId': '表型数据ID',
            'sampleCode': '样本编号',
            'maizeVariety': '玉米品种',
            'plotId': '所属地块ID',
            'growthStage': '生育时期',
            'plantHeight': '株高',
            'earHeight': '穗位高',
            'stemDiameter': '茎粗',
            'leafCount': '叶片数',
            'leafLength': '叶长',
            'leafWidth': '叶宽',
            'earLength': '穗长',
            'earDiameter': '穗粗',
            'kernelsPerRow': '行粒数',
            'hundredKernelWeight': '百粒重',
            'imagePath': '表型图片路径',
            'collectTime': '采集时间',
            'collector': '采集人员',
            'remark': '备注',
        }
        return ExcelUtil.export_list2excel(phenotype_list, mapping_dict)

    @classmethod
    async def import_phenotype_services(cls, query_db: AsyncSession, file):
        """支持Excel/CSV批量导入。字段名可使用中文列名。"""
        try:
            filename = file.filename.lower()
            content = await file.read()
            import io
            if filename.endswith('.csv'):
                df = pd.read_csv(io.BytesIO(content))
            else:
                df = pd.read_excel(io.BytesIO(content))

            column_map = {
                '样本编号': 'sample_code', '玉米品种': 'maize_variety', '所属地块ID': 'plot_id', '所属地块': 'plot_id',
                '生育时期': 'growth_stage', '株高': 'plant_height', '穗位高': 'ear_height', '茎粗': 'stem_diameter',
                '叶片数': 'leaf_count', '叶长': 'leaf_length', '叶宽': 'leaf_width', '穗长': 'ear_length',
                '穗粗': 'ear_diameter', '行粒数': 'kernels_per_row', '百粒重': 'hundred_kernel_weight',
                '图片路径': 'image_path', '表型图片路径': 'image_path', '采集时间': 'collect_time', '采集人员': 'collector', '备注': 'remark',
            }
            df = df.rename(columns=column_map)
            count = 0
            for _, row in df.iterrows():
                data = {k: (None if pd.isna(v) else v) for k, v in row.to_dict().items() if k in PhenotypeModel.model_fields}
                if data.get('sample_code') and data.get('maize_variety') and data.get('plot_id'):
                    await PhenotypeDao.add_phenotype_dao(query_db, PhenotypeModel(**data))
                    count += 1
            await query_db.commit()
            return CrudResponseModel(is_success=True, message=f'导入成功，共导入{count}条表型数据')
        except Exception as e:
            await query_db.rollback()
            raise ServiceException(message=f'导入失败：{str(e)}')
