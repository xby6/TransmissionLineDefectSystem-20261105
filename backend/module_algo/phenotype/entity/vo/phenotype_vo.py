from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel
from module_admin.annotation.pydantic_annotation import as_query


class PhenotypeModel(BaseModel):
    """
    玉米表型信息表对应pydantic模型
    """
    model_config = ConfigDict(alias_generator=to_camel, from_attributes=True, populate_by_name=True)

    phenotype_id: Optional[int] = Field(default=None, description='表型数据ID')
    sample_code: Optional[str] = Field(default=None, description='样本编号')
    maize_variety: Optional[str] = Field(default=None, description='玉米品种')
    plot_id: Optional[int] = Field(default=None, description='所属地块ID')
    growth_stage: Optional[str] = Field(default=None, description='生育时期')
    plant_height: Optional[float] = Field(default=None, description='株高')
    ear_height: Optional[float] = Field(default=None, description='穗位高')
    stem_diameter: Optional[float] = Field(default=None, description='茎粗')
    leaf_count: Optional[int] = Field(default=None, description='叶片数')
    leaf_length: Optional[float] = Field(default=None, description='叶长')
    leaf_width: Optional[float] = Field(default=None, description='叶宽')
    ear_length: Optional[float] = Field(default=None, description='穗长')
    ear_diameter: Optional[float] = Field(default=None, description='穗粗')
    kernels_per_row: Optional[int] = Field(default=None, description='行粒数')
    hundred_kernel_weight: Optional[float] = Field(default=None, description='百粒重')
    image_path: Optional[str] = Field(default=None, description='表型图片路径')
    collect_time: Optional[datetime] = Field(default=None, description='采集时间')
    collector: Optional[str] = Field(default=None, description='采集人员')
    remark: Optional[str] = Field(default=None, description='备注')


class PhenotypeQueryModel(BaseModel):
    """
    玉米表型不分页查询模型
    """
    model_config = ConfigDict(alias_generator=to_camel, from_attributes=True, populate_by_name=True)

    phenotype_id: Optional[int] = Field(default=None, description='表型数据ID')
    sample_code: Optional[str] = Field(default=None, description='样本编号')
    maize_variety: Optional[str] = Field(default=None, description='玉米品种')
    plot_id: Optional[int] = Field(default=None, description='所属地块ID')
    growth_stage: Optional[str] = Field(default=None, description='生育时期')


@as_query
class PhenotypePageQueryModel(PhenotypeQueryModel):
    """
    玉米表型分页查询模型
    """

    page_num: int = Field(default=1, description='当前页码')
    page_size: int = Field(default=10, description='每页记录数')


class DeletePhenotypeModel(BaseModel):
    """
    删除玉米表型数据模型
    """
    model_config = ConfigDict(alias_generator=to_camel)

    ids: str = Field(description='需要删除的ID')
