from fastapi import APIRouter, Depends, File, Form, Request, UploadFile
from pydantic_validation_decorator import ValidateFields
from sqlalchemy.ext.asyncio import AsyncSession
from config.enums import BusinessType
from config.get_db import get_db
from module_admin.annotation.log_annotation import Log
from module_admin.aspect.interface_auth import CheckUserInterfaceAuth
from module_admin.service.login_service import LoginService
from module_algo.phenotype.entity.vo.phenotype_vo import DeletePhenotypeModel, PhenotypeModel, PhenotypePageQueryModel
from module_algo.phenotype.service.phenotype_service import PhenotypeService
from utils.common_util import bytes2file_response
from utils.log_util import logger
from utils.page_util import PageResponseModel
from utils.response_util import ResponseUtil


phenotypeController = APIRouter(prefix='/phenotype/phenotype', dependencies=[Depends(LoginService.get_current_user)])


@phenotypeController.get('/list', response_model=PageResponseModel, dependencies=[Depends(CheckUserInterfaceAuth('phenotype:phenotype:list'))])
async def get_phenotype_list(
    request: Request,
    phenotype_page_query: PhenotypePageQueryModel = Depends(PhenotypePageQueryModel.as_query),
    query_db: AsyncSession = Depends(get_db),
):
    phenotype_page_query_result = await PhenotypeService.get_phenotype_list_services(query_db, phenotype_page_query, is_page=True)
    logger.info('获取玉米表型数据列表成功')
    return ResponseUtil.success(model_content=phenotype_page_query_result)


@phenotypeController.post('', dependencies=[Depends(CheckUserInterfaceAuth('phenotype:phenotype:add'))])
@ValidateFields(validate_model='add_phenotype')
@Log(title='玉米表型数据', business_type=BusinessType.INSERT)
async def add_phenotype(
    request: Request,
    add_phenotype: PhenotypeModel,
    query_db: AsyncSession = Depends(get_db),
):
    add_phenotype_result = await PhenotypeService.add_phenotype_services(query_db, add_phenotype)
    logger.info(add_phenotype_result.message)
    return ResponseUtil.success(msg=add_phenotype_result.message)


@phenotypeController.put('', dependencies=[Depends(CheckUserInterfaceAuth('phenotype:phenotype:edit'))])
@ValidateFields(validate_model='edit_phenotype')
@Log(title='玉米表型数据', business_type=BusinessType.UPDATE)
async def edit_phenotype(
    request: Request,
    edit_phenotype: PhenotypeModel,
    query_db: AsyncSession = Depends(get_db),
):
    edit_phenotype_result = await PhenotypeService.edit_phenotype_services(query_db, edit_phenotype)
    logger.info(edit_phenotype_result.message)
    return ResponseUtil.success(msg=edit_phenotype_result.message)


@phenotypeController.delete('/{ids}', dependencies=[Depends(CheckUserInterfaceAuth('phenotype:phenotype:remove'))])
@Log(title='玉米表型数据', business_type=BusinessType.DELETE)
async def delete_phenotype(request: Request, ids: str, query_db: AsyncSession = Depends(get_db)):
    delete_phenotype_result = await PhenotypeService.delete_phenotype_services(query_db, DeletePhenotypeModel(ids=ids))
    logger.info(delete_phenotype_result.message)
    return ResponseUtil.success(msg=delete_phenotype_result.message)


@phenotypeController.get('/{phenotype_id}', response_model=PhenotypeModel, dependencies=[Depends(CheckUserInterfaceAuth('phenotype:phenotype:query'))])
async def query_detail_phenotype(request: Request, phenotype_id: int, query_db: AsyncSession = Depends(get_db)):
    phenotype_detail_result = await PhenotypeService.phenotype_detail_services(query_db, phenotype_id)
    logger.info(f'获取id为{phenotype_id}的玉米表型数据成功')
    return ResponseUtil.success(data=phenotype_detail_result)


@phenotypeController.post('/export', dependencies=[Depends(CheckUserInterfaceAuth('phenotype:phenotype:export'))])
@Log(title='玉米表型数据', business_type=BusinessType.EXPORT)
async def export_phenotype_list(
    request: Request,
    phenotype_page_query: PhenotypePageQueryModel = Form(),
    query_db: AsyncSession = Depends(get_db),
):
    phenotype_query_result = await PhenotypeService.get_phenotype_list_services(query_db, phenotype_page_query, is_page=False)
    phenotype_export_result = await PhenotypeService.export_phenotype_list_services(phenotype_query_result)
    logger.info('导出玉米表型数据成功')
    return ResponseUtil.streaming(data=bytes2file_response(phenotype_export_result))


@phenotypeController.post('/importData', dependencies=[Depends(CheckUserInterfaceAuth('phenotype:phenotype:import'))])
@Log(title='玉米表型数据', business_type=BusinessType.IMPORT)
async def import_phenotype_data(
    request: Request,
    file: UploadFile = File(...),
    query_db: AsyncSession = Depends(get_db),
):
    import_result = await PhenotypeService.import_phenotype_services(query_db, file)
    logger.info(import_result.message)
    return ResponseUtil.success(msg=import_result.message)
