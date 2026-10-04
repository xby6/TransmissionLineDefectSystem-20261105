from sqlalchemy import BigInteger, Integer, String, DateTime, Float, Column
from config.database import Base


class PhenotypeInfo(Base):
    """
    玉米表型信息表
    """

    __tablename__ = 'phenotype_info'

    phenotype_id = Column(BigInteger, primary_key=True, autoincrement=True, comment='表型数据ID')
    sample_code = Column(String(50), nullable=False, comment='样本编号')
    maize_variety = Column(String(100), nullable=False, comment='玉米品种')
    plot_id = Column(BigInteger, nullable=False, comment='所属地块ID')
    growth_stage = Column(String(50), nullable=False, comment='生育时期')
    plant_height = Column(Float, nullable=True, comment='株高')
    ear_height = Column(Float, nullable=True, comment='穗位高')
    stem_diameter = Column(Float, nullable=True, comment='茎粗')
    leaf_count = Column(Integer, nullable=True, comment='叶片数')
    leaf_length = Column(Float, nullable=True, comment='叶长')
    leaf_width = Column(Float, nullable=True, comment='叶宽')
    ear_length = Column(Float, nullable=True, comment='穗长')
    ear_diameter = Column(Float, nullable=True, comment='穗粗')
    kernels_per_row = Column(Integer, nullable=True, comment='行粒数')
    hundred_kernel_weight = Column(Float, nullable=True, comment='百粒重')
    image_path = Column(String(255), nullable=True, comment='表型图片路径')
    collect_time = Column(DateTime, nullable=True, comment='采集时间')
    collector = Column(String(50), nullable=True, comment='采集人员')
    remark = Column(String(500), nullable=True, comment='备注')
