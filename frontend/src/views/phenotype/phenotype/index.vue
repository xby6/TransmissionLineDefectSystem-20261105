<template>
  <div class="app-container phenotype-page">
    <el-alert
      class="page-tip"
      title="玉米表型数据管理：支持表型数据新增、修改、查询、删除、图片上传、Excel/CSV批量导入和数据导出，实现样本编号、玉米品种、所属地块、生育时期、株高、穗位高、茎粗、叶片数、叶长、叶宽、穗部性状、表型图片路径、采集时间、采集人员等核心字段的统一管理。"
      type="success"
      :closable="false"
      show-icon
    />

    <el-form
      :model="queryParams"
      ref="queryRef"
      :inline="true"
      v-show="showSearch"
      label-width="82px"
    >
      <el-form-item label="样本编号" prop="sampleCode">
        <el-input
          v-model="queryParams.sampleCode"
          placeholder="请输入样本编号"
          clearable
          style="width: 220px"
          @keyup.enter="handleQuery"
        />
      </el-form-item>

      <el-form-item label="玉米品种" prop="maizeVariety">
        <el-input
          v-model="queryParams.maizeVariety"
          placeholder="请输入玉米品种"
          clearable
          style="width: 220px"
          @keyup.enter="handleQuery"
        />
      </el-form-item>

      <el-form-item label="生育时期" prop="growthStage">
        <el-input
          v-model="queryParams.growthStage"
          placeholder="如：拔节期、抽雄期"
          clearable
          style="width: 220px"
          @keyup.enter="handleQuery"
        />
      </el-form-item>

      <el-form-item label="所属地块" prop="plotId">
        <el-select
          v-model="queryParams.plotId"
          placeholder="请选择所属地块"
          clearable
          filterable
          style="width: 220px"
        >
          <el-option
            v-for="item in plotOptions"
            :key="item.id"
            :label="item.name + '（ID：' + item.id + '）'"
            :value="item.id"
          />
        </el-select>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleAdd"
          v-hasPermi="['phenotype:phenotype:add']"
        >
          新增表型数据
        </el-button>
      </el-col>

      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['phenotype:phenotype:edit']"
        >
          修改
        </el-button>
      </el-col>

      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['phenotype:phenotype:remove']"
        >
          删除
        </el-button>
      </el-col>

      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Upload"
          @click="upload.open = true"
          v-hasPermi="['phenotype:phenotype:import']"
        >
          批量导入表型数据
        </el-button>
      </el-col>

      <el-col :span="1.5">
        <el-button
          type="info"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['phenotype:phenotype:export']"
        >
          导出
        </el-button>
      </el-col>

      <right-toolbar
        v-model:showSearch="showSearch"
        @queryTable="getList"
      />
    </el-row>

    <el-table
      v-loading="loading"
      :data="phenotypeList"
      @selection-change="handleSelectionChange"
      border
    >
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="表型ID" align="center" prop="phenotypeId" width="90" />
      <el-table-column label="样本编号" align="center" prop="sampleCode" width="130" show-overflow-tooltip />
      <el-table-column label="玉米品种" align="center" prop="maizeVariety" width="140" show-overflow-tooltip />

      <el-table-column label="所属地块" align="center" prop="plotId" width="150" show-overflow-tooltip>
        <template #default="scope">
          <span>{{ getPlotLabel(scope.row.plotId) }}</span>
        </template>
      </el-table-column>

      <el-table-column label="生育时期" align="center" prop="growthStage" width="110" />
      <el-table-column label="株高/cm" align="center" prop="plantHeight" width="95" />
      <el-table-column label="穗位高/cm" align="center" prop="earHeight" width="105" />
      <el-table-column label="茎粗/mm" align="center" prop="stemDiameter" width="95" />
      <el-table-column label="叶片数" align="center" prop="leafCount" width="85" />
      <el-table-column label="叶长/cm" align="center" prop="leafLength" width="95" />
      <el-table-column label="叶宽/cm" align="center" prop="leafWidth" width="95" />
      <el-table-column label="穗长/cm" align="center" prop="earLength" width="95" />
      <el-table-column label="穗粗/mm" align="center" prop="earDiameter" width="95" />
      <el-table-column label="行粒数" align="center" prop="kernelsPerRow" width="85" />
      <el-table-column label="百粒重/g" align="center" prop="hundredKernelWeight" width="100" />
      <el-table-column label="采集时间" align="center" prop="collectTime" width="165" />
      <el-table-column label="采集人员" align="center" prop="collector" width="100" />

      <el-table-column label="图片" align="center" prop="imagePath" width="90">
        <template #default="scope">
          <el-image
            v-if="scope.row.imagePath"
            class="table-image"
            :src="getImageUrl(scope.row.imagePath)"
            fit="cover"
            :preview-src-list="[getImageUrl(scope.row.imagePath)]"
            preview-teleported
          >
            <template #error>
              <span class="table-image-error">无图</span>
            </template>
          </el-image>
          <span v-else class="empty-text">未上传</span>
        </template>
      </el-table-column>

      <el-table-column label="图片路径" align="center" prop="imagePath" min-width="180" show-overflow-tooltip />
      <el-table-column label="备注" align="center" prop="remark" min-width="140" show-overflow-tooltip />

      <el-table-column
        label="操作"
        align="center"
        class-name="small-padding fixed-width"
        fixed="right"
        width="150"
      >
        <template #default="scope">
          <el-button
            link
            type="primary"
            icon="Edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['phenotype:phenotype:edit']"
          >
            修改
          </el-button>
          <el-button
            link
            type="primary"
            icon="Delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['phenotype:phenotype:remove']"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <el-dialog :title="title" v-model="open" width="980px" append-to-body>
      <el-form ref="phenotypeRef" :model="form" :rules="rules" label-width="104px">
        <el-divider content-position="left">基础信息</el-divider>

        <el-row :gutter="18">
          <el-col :span="8">
            <el-form-item label="样本编号" prop="sampleCode">
              <el-input v-model="form.sampleCode" placeholder="请输入样本编号" />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="玉米品种" prop="maizeVariety">
              <el-input v-model="form.maizeVariety" placeholder="请输入玉米品种" />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="所属地块" prop="plotId">
              <el-select
                v-model="form.plotId"
                placeholder="请选择所属地块"
                filterable
                clearable
                style="width: 100%"
              >
                <el-option
                  v-for="item in plotOptions"
                  :key="item.id"
                  :label="item.name + '（ID：' + item.id + '）'"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="生育时期" prop="growthStage">
              <el-input v-model="form.growthStage" placeholder="如：拔节期、抽雄期" />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="采集时间" prop="collectTime">
              <el-date-picker
                v-model="form.collectTime"
                type="datetime"
                value-format="YYYY-MM-DD HH:mm:ss"
                placeholder="请选择采集时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="采集人员" prop="collector">
              <el-input v-model="form.collector" placeholder="请输入采集人员" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">植株形态指标</el-divider>

        <el-row :gutter="18">
          <el-col :span="8">
            <el-form-item label="株高/cm" prop="plantHeight">
              <el-input-number
                v-model="form.plantHeight"
                :min="0"
                :precision="2"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="穗位高/cm" prop="earHeight">
              <el-input-number
                v-model="form.earHeight"
                :min="0"
                :precision="2"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="茎粗/mm" prop="stemDiameter">
              <el-input-number
                v-model="form.stemDiameter"
                :min="0"
                :precision="2"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="叶片数" prop="leafCount">
              <el-input-number
                v-model="form.leafCount"
                :min="0"
                :precision="0"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="叶长/cm" prop="leafLength">
              <el-input-number
                v-model="form.leafLength"
                :min="0"
                :precision="2"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="叶宽/cm" prop="leafWidth">
              <el-input-number
                v-model="form.leafWidth"
                :min="0"
                :precision="2"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">穗部性状与图片</el-divider>

        <el-row :gutter="18">
          <el-col :span="8">
            <el-form-item label="穗长/cm" prop="earLength">
              <el-input-number
                v-model="form.earLength"
                :min="0"
                :precision="2"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="穗粗/mm" prop="earDiameter">
              <el-input-number
                v-model="form.earDiameter"
                :min="0"
                :precision="2"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="行粒数" prop="kernelsPerRow">
              <el-input-number
                v-model="form.kernelsPerRow"
                :min="0"
                :precision="0"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <el-form-item label="百粒重/g" prop="hundredKernelWeight">
              <el-input-number
                v-model="form.hundredKernelWeight"
                :min="0"
                :precision="2"
                controls-position="right"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <el-col :span="16">
            <el-form-item label="图片路径" prop="imagePath">
              <div class="image-upload-row">
                <el-input
                  v-model="form.imagePath"
                  placeholder="可手动输入图片路径，也可点击右侧按钮上传本地图片"
                  clearable
                />

                <el-upload
                  class="phenotype-image-upload"
                  :action="imageUploadUrl"
                  :headers="imageUploadHeaders"
                  :show-file-list="false"
                  :before-upload="beforeImageUpload"
                  :on-success="handleImageUploadSuccess"
                  :on-error="handleImageUploadError"
                  accept=".jpg,.jpeg,.png,.bmp,.webp"
                >
                  <el-button type="primary" icon="Upload">上传图片</el-button>
                </el-upload>
              </div>

              <div class="form-tip">
                支持 jpg、jpeg、png、bmp、webp 格式，上传成功后系统会自动回填图片路径。
              </div>

              <div v-if="form.imagePath" class="image-preview-box">
                <el-image
                  :src="getImageUrl(form.imagePath)"
                  fit="cover"
                  :preview-src-list="[getImageUrl(form.imagePath)]"
                  preview-teleported
                >
                  <template #error>
                    <div class="image-error">图片无法预览</div>
                  </template>
                </el-image>
              </div>
            </el-form-item>
          </el-col>

          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input
                v-model="form.remark"
                type="textarea"
                :rows="3"
                placeholder="请输入备注"
              />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <el-dialog title="表型数据批量导入" v-model="upload.open" width="460px" append-to-body>
      <el-upload
        ref="uploadRef"
        :limit="1"
        accept=".xlsx,.xls,.csv"
        :headers="upload.headers"
        :action="upload.url"
        :disabled="upload.isUploading"
        :on-progress="handleFileUploadProgress"
        :on-success="handleFileSuccess"
        :auto-upload="false"
        drag
      >
        <el-icon class="el-icon--upload">
          <upload-filled />
        </el-icon>

        <div class="el-upload__text">
          将Excel/CSV文件拖到此处，或<em>点击上传</em>
        </div>

        <template #tip>
          <div class="el-upload__tip text-center">
            建议字段包含：样本编号、玉米品种、所属地块ID、生育时期、株高、穗位高、茎粗、叶片数、叶长、叶宽、穗长、穗粗、行粒数、百粒重、图片路径、采集时间、采集人员、备注。
          </div>
        </template>
      </el-upload>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitFileForm">确 定</el-button>
          <el-button @click="upload.open = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Phenotype">
import { getToken } from '@/utils/auth'
import { listNode } from '@/api/node/node'
import {
  listPhenotype,
  getPhenotype,
  delPhenotype,
  addPhenotype,
  updatePhenotype
} from '@/api/phenotype/phenotype'

const { proxy } = getCurrentInstance()

const phenotypeList = ref([])
const plotOptions = ref([])
const open = ref(false)
const loading = ref(true)
const showSearch = ref(true)
const ids = ref([])
const single = ref(true)
const multiple = ref(true)
const total = ref(0)
const title = ref('')

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    sampleCode: null,
    maizeVariety: null,
    growthStage: null,
    plotId: null
  },
  rules: {
    sampleCode: [
      { required: true, message: '样本编号不能为空', trigger: 'blur' }
    ],
    maizeVariety: [
      { required: true, message: '玉米品种不能为空', trigger: 'blur' }
    ],
    plotId: [
      { required: true, message: '请选择所属地块', trigger: 'change' }
    ],
    growthStage: [
      { required: true, message: '生育时期不能为空', trigger: 'blur' }
    ],
    collectTime: [
      { required: true, message: '采集时间不能为空', trigger: 'change' }
    ]
  }
})

const { queryParams, form, rules } = toRefs(data)

const upload = reactive({
  open: false,
  isUploading: false,
  headers: {
    Authorization: 'Bearer ' + getToken()
  },
  url: import.meta.env.VITE_APP_BASE_API + '/phenotype/phenotype/importData'
})

// 单张表型图片上传接口，优先使用系统通用上传接口
const imageUploadUrl = import.meta.env.VITE_APP_BASE_API + '/common/upload'

const imageUploadHeaders = ref({
  Authorization: 'Bearer ' + getToken()
})

/** 查询表型数据列表 */
function getList() {
  loading.value = true
  listPhenotype(queryParams.value).then(response => {
    phenotypeList.value = response.rows || []
    total.value = response.total || 0
    loading.value = false
  }).catch(error => {
    console.error('获取玉米表型数据列表失败：', error)
    loading.value = false
  })
}

/** 获取地块选项，用于表型数据选择所属地块 */
function getPlotOptions() {
  listNode({
    pageNum: 1,
    pageSize: 9999
  }).then(response => {
    plotOptions.value = response.rows || []
  }).catch(error => {
    console.error('获取地块选项失败：', error)
  })
}

/** 根据地块ID显示地块名称 */
function getPlotLabel(plotId) {
  if (!plotId) {
    return '未绑定'
  }

  const item = plotOptions.value.find(plot => String(plot.id) === String(plotId))

  if (item) {
    return item.name + '（ID：' + item.id + '）'
  }

  return '地块ID：' + plotId
}

function cancel() {
  open.value = false
  reset()
}

function reset() {
  form.value = {
    phenotypeId: null,
    sampleCode: null,
    maizeVariety: null,
    plotId: null,
    growthStage: null,
    plantHeight: null,
    earHeight: null,
    stemDiameter: null,
    leafCount: null,
    leafLength: null,
    leafWidth: null,
    earLength: null,
    earDiameter: null,
    kernelsPerRow: null,
    hundredKernelWeight: null,
    imagePath: null,
    collectTime: null,
    collector: null,
    remark: null
  }
  proxy.resetForm('phenotypeRef')
}

function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm('queryRef')
  handleQuery()
}

function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.phenotypeId)
  single.value = selection.length !== 1
  multiple.value = !selection.length
}

function handleAdd() {
  reset()
  getPlotOptions()
  open.value = true
  title.value = '新增玉米表型数据'
}

function handleUpdate(row) {
  reset()
  getPlotOptions()
  const _phenotypeId = row.phenotypeId || ids.value

  getPhenotype(_phenotypeId).then(response => {
    form.value = response.data
    open.value = true
    title.value = '修改玉米表型数据'
  }).catch(error => {
    console.error('获取玉米表型数据详情失败：', error)
  })
}

function submitForm() {
  proxy.$refs['phenotypeRef'].validate(valid => {
    if (valid) {
      if (form.value.phenotypeId != null) {
        updatePhenotype(form.value).then(() => {
          proxy.$modal.msgSuccess('修改成功')
          open.value = false
          getList()
        })
      } else {
        addPhenotype(form.value).then(() => {
          proxy.$modal.msgSuccess('新增成功')
          open.value = false
          getList()
        })
      }
    }
  })
}

function handleDelete(row) {
  const _phenotypeIds = row.phenotypeId || ids.value

  proxy.$modal.confirm('是否确认删除表型数据编号为"' + _phenotypeIds + '"的数据项？').then(() => {
    return delPhenotype(_phenotypeIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess('删除成功')
  }).catch(() => {})
}

function handleExport() {
  proxy.download(
    'phenotype/phenotype/export',
    { ...queryParams.value },
    `phenotype_${new Date().getTime()}.xlsx`
  )
}

function handleFileUploadProgress() {
  upload.isUploading = true
}

function handleFileSuccess(response) {
  upload.open = false
  upload.isUploading = false
  proxy.$refs['uploadRef'].handleRemove()
  proxy.$modal.alert(response.msg || '导入完成', '导入结果', {
    dangerouslyUseHTMLString: true
  })
  getList()
}

function submitFileForm() {
  proxy.$refs['uploadRef'].submit()
}

/** 上传前校验表型图片 */
function beforeImageUpload(file) {
  const allowTypes = [
    'image/jpeg',
    'image/png',
    'image/bmp',
    'image/webp'
  ]

  const isImage = allowTypes.includes(file.type)
  const isLt10M = file.size / 1024 / 1024 < 10

  if (!isImage) {
    proxy.$modal.msgError('只能上传 jpg、jpeg、png、bmp、webp 格式的图片！')
    return false
  }

  if (!isLt10M) {
    proxy.$modal.msgError('图片大小不能超过 10MB！')
    return false
  }

  return true
}

/** 表型图片上传成功后自动回填图片路径 */
function handleImageUploadSuccess(response) {
  console.log('图片上传成功返回：', response)

  if (response.code === 200 || response.code === 0) {
    // 重点：优先保存相对路径 fileName，不优先保存完整 url
    // 因为完整 url 里可能带 /dev-api，导致图片无法直接访问
    const fileUrl =
      response.fileName ||
      response.data?.fileName ||
      response.data?.path ||
      response.data?.fileUrl ||
      response.url ||
      response.data?.url

    if (fileUrl) {
      form.value.imagePath = normalizeImagePath(fileUrl)
      proxy.$modal.msgSuccess('图片上传成功')
    } else {
      proxy.$modal.msgError('上传成功，但未获取到图片路径，请检查后端返回字段')
    }
  } else {
    proxy.$modal.msgError(response.msg || '图片上传失败')
  }
}

/** 规范化图片保存路径：保存时尽量保存 /profile/upload/... 这种相对路径 */
function normalizeImagePath(path) {
  if (!path) {
    return ''
  }

  let url = String(path).trim()

  // 把反斜杠替换成正斜杠
  url = url.replace(/\\/g, '/')

  // 如果后端返回了完整地址，截取 /profile/upload/... 之后的部分
  const profileIndex = url.indexOf('/profile/')
  if (profileIndex !== -1) {
    return url.substring(profileIndex)
  }

  // 如果返回的是 profile/upload/...，补一个 /
  if (url.startsWith('profile/')) {
    return '/' + url
  }

  return url
}

/** 表型图片上传失败 */
function handleImageUploadError(error) {
  console.error('图片上传失败：', error)
  proxy.$modal.msgError('图片上传失败，请检查后端上传接口是否正常')
}

/** 图片预览路径处理 */
function getImageUrl(path) {
  if (!path) {
    return ''
  }

  let url = String(path).trim().replace(/\\/g, '/')

  // 先处理中文、空格等特殊字符
  const encodePath = value => {
    try {
      return encodeURI(value)
    } catch (e) {
      return value
    }
  }

  // 如果是完整 http 地址，但里面包含 /dev-api/profile/，说明可能是前端代理地址
  // 统一截取成 /profile/... 后再走代理
  const profileIndex = url.indexOf('/profile/')
  if (profileIndex !== -1) {
    url = url.substring(profileIndex)
  }

  // 如果已经是 http 完整地址，并且不是 /profile 资源，直接返回
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return encodePath(url)
  }

  // 如果是 /profile/upload/...，走前端代理 /dev-api/profile/...
  if (url.startsWith('/')) {
    return encodePath(import.meta.env.VITE_APP_BASE_API + url)
  }

  return encodePath(import.meta.env.VITE_APP_BASE_API + '/' + url)
}

getList()
getPlotOptions()
</script>

<style scoped>
.phenotype-page {
  min-height: calc(100vh - 84px);
  padding: 18px;
  background: linear-gradient(180deg, #f8f5ec 0%, #eef4e7 100%);
  border-radius: 20px;
}

.page-tip {
  margin-bottom: 14px;
  border-radius: 12px;
}

.mb8 {
  margin-bottom: 14px;
}

:deep(.el-table) {
  border-radius: 16px;
  overflow: hidden;
  background: rgba(255, 252, 245, 0.9);
}

:deep(.el-table th.el-table__cell) {
  background: #f7f4ea !important;
  color: #5f6f4e;
  font-weight: 700;
}

:deep(.el-dialog) {
  border-radius: 18px;
  overflow: hidden;
}

:deep(.el-divider__text) {
  color: #4f6f3c;
  font-weight: 700;
  background: #fffaf2;
}

.image-upload-row {
  display: flex;
  align-items: center;
  width: 100%;
  gap: 10px;
}

.image-upload-row .el-input {
  flex: 1;
}

.phenotype-image-upload {
  flex-shrink: 0;
}

.form-tip {
  font-size: 12px;
  color: #8c977d;
  margin-top: 4px;
  line-height: 1.5;
}

.image-preview-box {
  margin-top: 10px;
  width: 140px;
  height: 100px;
  border: 1px solid #e4ebd8;
  border-radius: 10px;
  overflow: hidden;
  background: #fafafa;
}

.image-preview-box :deep(.el-image) {
  width: 100%;
  height: 100%;
}

.image-error {
  width: 100%;
  height: 100%;
  color: #999;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.table-image {
  width: 48px;
  height: 36px;
  border-radius: 6px;
  border: 1px solid #e4ebd8;
  background: #fafafa;
  cursor: pointer;
}

.table-image-error {
  display: inline-flex;
  width: 48px;
  height: 36px;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 12px;
  background: #f7f7f7;
  border-radius: 6px;
}

.empty-text {
  color: #999;
  font-size: 12px;
}
</style>