<template>
  <div class="app-container">
    <PageHeader title="输电节点管理" description="维护输电塔位置、运行状态与关联巡检图像。" eyebrow="TRANSMISSION NODES" />
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="节点名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入节点名称"
          clearable
          style="width: 240px"
          @keyup.enter="handleQuery"
        />
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
          v-hasPermi="['node:node:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['node:node:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['node:node:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['node:node:export']"
        >导出</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="info" plain icon="Upload" @click="upload.open = true" v-hasPermi="['node:node:import']">导入</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="nodeList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="节点号" align="center" prop="id" />
      <el-table-column label="节点名称" align="center" prop="name" />
      <el-table-column label="经度" align="center" prop="longitude" />
      <el-table-column label="纬度" align="center" prop="latitude" />
      <el-table-column label="文件夹号" align="center" prop="dir">
        <template #default="scope">
          <span v-if="scope.row.dir">{{ scope.row.dir }}</span>
          <span v-else style="color: #999;">未关联</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <dict-tag :options="statusOptions" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['node:node:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['node:node:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total>0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 添加或修改节点对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="nodeRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item v-if="renderField(true, true)" label="节点名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入节点名称" />
        </el-form-item>
        <el-form-item v-if="renderField(true, true)" label="经度" prop="longitude">
          <el-input v-model="form.longitude" placeholder="请输入经度" />
          <div class="form-tip">例如：124.3947</div>
        </el-form-item>
        <el-form-item v-if="renderField(true, true)" label="纬度" prop="latitude">
          <el-input v-model="form.latitude" placeholder="请输入纬度" />
          <div class="form-tip">例如：40.1291</div>
        </el-form-item>
        <el-form-item v-if="renderField(true, true)" label="文件夹号" prop="dir">
          <el-input 
            v-model="form.dir" 
            placeholder="请输入关联的文件夹号" 
            @input="handleDirInput"
          />
          <div class="form-tip">关联文件夹ID后，地图上可查看该文件夹下的JPG图片</div>
        </el-form-item>
        <el-form-item v-if="renderField(false, true)" label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态" clearable>
            <el-option
              v-for="dict in statusOptions"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
    <el-dialog title="节点导入" v-model="upload.open" width="400px" append-to-body>
      <el-upload ref="uploadRef" :limit="1" accept=".xlsx,.xls" :headers="upload.headers"
        :action="upload.url" :disabled="upload.isUploading" :auto-upload="false" drag
        :before-upload="beforeImport" :on-progress="() => upload.isUploading = true"
        :on-success="handleImportSuccess" :on-error="handleImportError">
        <el-icon class="el-icon--upload"><upload-filled /></el-icon>
        <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
        <template #tip><div class="el-upload__tip text-center">仅允许导入 xls、xlsx 文件，大小不超过 10MB。
          <el-link type="primary" @click="importTemplate">下载模板</el-link>
        </div></template>
      </el-upload>
      <template #footer>
        <el-button type="primary" :loading="upload.isUploading" @click="proxy.$refs.uploadRef.submit()">开始导入</el-button>
        <el-button @click="upload.open = false">取消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Node">
import PageHeader from '@/components/PageHeader/index.vue'
import { listNode, getNode, delNode, addNode, updateNode } from "@/api/node/node";

import { getToken } from '@/utils/auth';
const { proxy } = getCurrentInstance();
const upload = reactive({ open: false, isUploading: false,
  headers: { Authorization: 'Bearer ' + getToken() },
  url: import.meta.env.VITE_APP_BASE_API + '/node/node/importData' });
function importTemplate() { proxy.download('node/node/importTemplate', {}, '节点导入模板.xlsx'); }
function beforeImport(file) {
  if (file.size > 10 * 1024 * 1024) { proxy.$modal.msgError('文件大小不能超过 10MB'); return false; }
  return true;
}
function handleImportSuccess(response) {
  upload.isUploading = false;
  if (response.code !== 200) { proxy.$modal.msgError(response.msg || '导入失败'); return; }
  upload.open = false;
  proxy.$refs.uploadRef.clearFiles();
  proxy.$modal.msgSuccess(response.msg);
  getList();
}
function handleImportError() { upload.isUploading = false; proxy.$modal.msgError('节点导入失败，请检查文件格式'); }


const nodeList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const title = ref("");

// 状态选项
const statusOptions = ref([
  { value: '0', label: '正常' },
  { value: '1', label: '停用' }
]);

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    name: null,
    status: null,
  },
  rules: {
    name: [
      { required: true, message: "节点名称不能为空", trigger: "blur" }
    ],
    longitude: [
      { required: true, message: "经度不能为空", trigger: "blur" },
      { pattern: /^-?\d+(\.\d+)?$/, message: "请输入正确的经度格式", trigger: "blur" }
    ],
    latitude: [
      { required: true, message: "纬度不能为空", trigger: "blur" },
      { pattern: /^-?\d+(\.\d+)?$/, message: "请输入正确的纬度格式", trigger: "blur" }
    ],
    dir: [
      { pattern: /^\d*$/, message: "文件夹号必须是数字", trigger: "blur" }
    ],
    status: [
      { required: true, message: "状态不能为空", trigger: "change" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询节点列表 */
function getList() {
  loading.value = true;
  listNode(queryParams.value).then(response => {
    console.log('节点列表返回数据:', response);
    console.log('第一个节点的数据:', response.rows?.[0]);
    
    nodeList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  }).catch(error => {
    console.error('获取节点列表失败:', error);
    loading.value = false;
  });
}

/** 取消按钮 */
function cancel() {
  open.value = false;
  reset();
}

/** 表单重置 */
function reset() {
  form.value = {
    id: null,
    name: null,
    longitude: null,
    latitude: null,
    dir: null, // 使用 dir 字段
    status: '0' // 默认正常状态
  };
  proxy.resetForm("nodeRef");
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1;
  getList();
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef");
  handleQuery();
}

/** 多选框选中数据  */
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.id);
  single.value = selection.length != 1;
  multiple.value = !selection.length;
}

/** 处理文件夹ID输入 */
function handleDirInput(value) {
  // 清理输入，确保是数字
  form.value.dir = value.replace(/[^\d]/g, '');
}

/** 新增按钮操作 */
function handleAdd() {
  reset();
  open.value = true;
  title.value = "添加节点";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const _id = row.id || ids.value;
  getNode(_id).then(response => {
    console.log('获取节点详情响应:', response);
    
    const safeData = {
      id: response.data.id,
      name: response.data.name,
      longitude: response.data.longitude,
      latitude: response.data.latitude,
      dir: response.data.dir || null, // 使用 dir 字段
      status: response.data.status || '0'
    };
    
    console.log('处理后的表单数据:', safeData);
    
    form.value = safeData;
    open.value = true;
    title.value = "修改节点";
  }).catch(error => {
    console.error("获取节点详情失败:", error);
  });
}

/** 清理表单数据，移除后端不支持的字段 */
function cleanFormData(formData) {
  // 只保留后端支持的字段
  const allowedFields = ['id', 'name', 'longitude', 'latitude', 'dir', 'status'];
  const cleanedData = {};
  
  allowedFields.forEach(field => {
    if (formData[field] !== undefined) {
      // 特殊处理dir，确保发送正确的值
      if (field === 'dir') {
        // 如果是空字符串，发送null
        cleanedData[field] = formData[field] === '' ? null : formData[field];
      } else {
        cleanedData[field] = formData[field];
      }
    }
  });
  
  return cleanedData;
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["nodeRef"].validate(valid => {
    if (valid) {
      // 清理表单数据，确保只提交后端支持的字段
      const cleanedData = cleanFormData(form.value);
      
      console.log('准备提交的数据:', cleanedData);
      
      if (cleanedData.id != null) {
        // 修改操作
        updateNode(cleanedData).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        }).catch(error => {
          console.error("更新失败:", error);
          console.error("请求数据:", cleanedData);
          console.error("错误详情:", error.response?.data || error.message);
        });
      } else {
        // 新增操作 - 确保没有id字段
        delete cleanedData.id;
        addNode(cleanedData).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          open.value = false;
          getList();
        }).catch(error => {
          console.error("新增失败:", error);
          console.error("请求数据:", cleanedData);
          console.error("错误详情:", error.response?.data || error.message);
        });
      }
    }
  });
}

/** 删除按钮操作 */
function handleDelete(row) {
  const _ids = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除节点编号为"' + _ids + '"的数据项？').then(function() {
    return delNode(_ids);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('node/node/export', {
    ...queryParams.value
  }, `node_${new Date().getTime()}.xlsx`);
}

/** 是否渲染字段 */
function renderField(insert, edit) {
  return form.value.id == null ? insert : edit;
}

getList();
</script>

<style scoped>
.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}
</style>