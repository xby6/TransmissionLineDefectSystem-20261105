<template>
  <div class="app-container">
    <PageHeader title="遥感数据管理" description="整理巡检图像与文件夹，为检测任务准备数据。" eyebrow="INSPECTION DATA" />
    <div class="breadcrumb" v-if="currentFolderId !== '0'">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>
          <a @click="goToRoot">根目录</a>
        </el-breadcrumb-item>
        <el-breadcrumb-item v-for="(folder, index) in breadcrumb" :key="folder.id">
          <a v-if="index < breadcrumb.length - 1" @click="goToFolder(folder)">{{ folder.name }}</a>
          <span v-else>{{ folder.name }}</span>
        </el-breadcrumb-item>
      </el-breadcrumb>
    </div>

    <el-form :model="queryParams" ref="queryParams" :inline="true" @submit. native.prevent>
      <el-form-item label="文件名称">
       <el-input 
    placeholder="输入文件或文件夹名搜索" 
    v-model="searchInputText"
    @keyup.enter="handleSearch"
    clearable
  ></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleSearch">搜索</el-button>
        <el-button icon="Refresh" @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="addFolderWithContent"
          v-hasPermi="['file:file:add']"
        >上传文件夹</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="updateFloder"
          v-hasPermi="['file:file:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="delFloder"
          v-hasPermi="['file:file:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>
    
    <div style="position: absolute;height: 80%;width: 98%" @click="addFolderShow = false;folderShow = false;clearSelection()"
         @contextmenu.prevent.stop="rightClick($event)">
      <el-card class="drawing_card" v-loading="cardLoading">
    
        <template v-if="folderList.length === 0">
          <el-empty description="暂无文件，请右键创建一个文件夹吧" style="height: 600px"></el-empty>
        </template>
        
        <!-- 上传文件夹对话框 -->
        <el-dialog title="上传文件夹" v-model="uploadFolderVisible" width="500px" append-to-body>
          <el-form ref="uploadFolderRef" :model="uploadFolderForm" :rules="uploadFolderRules" label-width="80px">
            <el-form-item label="文件夹名" prop="name">
              <el-input v-model="uploadFolderForm.name" placeholder="请输入文件夹名称" />
            </el-form-item>
            <el-form-item label="选择文件夹" required>
              <input 
                type="file" 
                ref="folderInput"
                webkitdirectory
                multiple
                @change="handleFolderSelect"
                style="margin-top: 8px;"
              />
              <div v-if="selectedFolderFiles.length > 0" style="margin-top: 8px; color: #666;">
                已选择文件夹，包含 {{ selectedFolderFiles.length }} 个文件
              </div>
              <div v-else style="margin-top: 8px; color: #909399; font-size: 12px;">
                请选择一个包含文件的文件夹
              </div>
            </el-form-item>
          </el-form>
          <template #footer>
            <div class="dialog-footer">
              <el-button type="primary" @click="submitUploadFolder">确 定</el-button>
              <el-button @click="uploadFolderVisible = false">取 消</el-button>
            </div>
          </template>
        </el-dialog>

        <!-- 创建空文件夹对话框 -->
        <el-dialog title="创建文件夹" v-model="createFolderVisible" width="400px" append-to-body>
          <el-form ref="createFolderRef" :model="createFolderForm" :rules="createFolderRules" label-width="80px">
            <el-form-item label="文件夹名" prop="name">
              <el-input v-model="createFolderForm.name" placeholder="请输入文件夹名称" />
            </el-form-item>
          </el-form>
          <template #footer>
            <div class="dialog-footer">
              <el-button type="primary" @click="submitCreateFolder">确 定</el-button>
              <el-button @click="createFolderVisible = false">取 消</el-button>
            </div>
          </template>
        </el-dialog>

        <!-- 批量上传进度对话框 -->
        <el-dialog 
          title="上传文件夹" 
          v-model="batchUploadVisible" 
          width="400px"
          :close-on-click-modal="false"
          :show-close="false"
        >
          <div style="text-align: center;">
            <div style="margin-bottom: 20px;">
              <div v-if="batchUploadStatus === 'uploading'">
                <el-progress 
                  :percentage="batchUploadProgress" 
                  :status="batchUploadProgress === 100 ? 'success' : ''"
                />
                <div style="margin-top: 10px; color: #666;">
                  正在上传文件... {{ batchUploadProgress }}%
                </div>
              </div>
              <div v-else-if="batchUploadStatus === 'success'" style="color: #67C23A;">
                <i class="el-icon-success" style="font-size: 48px;"></i>
                <div style="margin-top: 10px;">上传完成！</div>
              </div>
              <div v-else-if="batchUploadStatus === 'exception'" style="color: #F56C6C;">
                <i class="el-icon-error" style="font-size: 48px;"></i>
                <div style="margin-top: 10px;">上传失败，请重试</div>
              </div>
            </div>
          </div>
        </el-dialog>

        <!-- 重命名对话框 -->
        <el-dialog title="重命名" v-model="renameDialogVisible" width="400px" append-to-body>
          <el-form>
            <el-form-item label="新名称">
              <el-input v-model="renameForm.newName" placeholder="请输入新的名称" />
            </el-form-item>
          </el-form>
          <template #footer>
            <div class="dialog-footer">
              <el-button type="primary" @click="confirmRename">确 定</el-button>
              <el-button @click="renameDialogVisible = false">取 消</el-button>
            </div>
          </template>
        </el-dialog>
        
<!-- 修改文件夹显示部分 -->
<div v-for="(item,index) in folderList" :key="item.id || index">
  <div class="folderContainer">
    <!-- 文件夹类型显示文件夹图标 -->
    <div v-if="item.type == 'dir'" 
         class="folderWrapper" 
         :class="{ 'selected': selectedItems.includes(item.id) }"
         @click="handleItemClick(item, $event)"
         @dblclick="enterFolder(item)"
         @contextmenu.prevent.stop="rightClickFolder(index,item,$event)">
      <div class="folder">
        <div class="front"></div>
        <div class="center"></div>
        <div class="back"></div>
      </div>
      <div class="folderName">
        <span>{{ item.name && item.name.length > 10 ? item.name.substring(0, 8) + '...' : item.name }}</span>
      </div>
      <div class="folderTime">
        <span>{{ formatTime(item.uploadTime) }}</span>
      </div>
    </div>
    <!-- 文件类型显示文件图标 - 只在非根目录下显示 -->
    <div v-else 
         class="folderWrapper" 
         :class="{ 'selected': selectedItems.includes(item.id) }"
         @click="handleItemClick(item, $event)"
         @dblclick="downloadFile(item)"
         @contextmenu.prevent.stop="rightClickFolder(index,item,$event)">
      <img v-if="thumbnails[item.id]" :src="thumbnails[item.id]" style="width: 100px;height: 90px;object-fit: contain;"/>
      <img v-else src="@/assets/images/fileImg.png" style="width: 100px;height: 90px;margin-top: -13px"/>
      <div class="folderName">
        <span>{{ item.name && item.name.length > 10 ? item.name.substring(0, 8) + '...' : item.name }}</span>
      </div>
      <div class="folderTime">
        <span>{{ formatTime(item.uploadTime) }}</span>
      </div>
    </div>
  </div>
</div>
      </el-card>
    </div>
  
    <div class="add-folder" :style="addFolderStyle" v-show="addFolderShow">
      <div class="add-folder-1" style="margin-top: 1.5px;margin-bottom: 1.5px">
        <div class="add-folder-2" style="margin-bottom: 5px" @click="createEmptyFolder">
            <i class="el-icon-plus"></i>
          新建文件夹
        </div>
        <div style="border: 2px solid rgba(18,17,42,.07)"></div>
        <div class="add-folder-2" @click="handleAddFileToFolder" style="margin-bottom: 5px">
            <i class="el-icon-upload2"></i>
          上传文件
        </div>
        <div style="border: 2px solid rgba(18,17,42,.07)"></div>
        <div class="add-folder-2" @click="forceRefresh" >
            <i class="el-icon-refresh"></i>
          刷 新
        </div>
      </div>
    </div>

    <div class="add-folder-9" :style="folderStyle" v-show="folderShow">
      <div class="add-folder-1" style="margin-top: 1.5px;margin-bottom: 1.5px">
        <!-- 右键菜单 -->
        <div v-if="currentFolder.type === 'dir'" class="add-folder-2" @click="openFolder(currentFolder)">
            <i class="el-icon-folder-opened"></i>
          文件夹详情
        </div>
        <div v-else class="add-folder-2" @click="downloadFile(currentFolder)">
            <i class="el-icon-download"></i>
          下载文件
        </div>
        <div style="border: 2px solid rgba(18,17,42,.07)"></div>
        <div class="add-folder-2" @click="updateFloder">
            <i class="el-icon-edit-outline"></i>
          重命名
        </div>
        <div style="border: 2px solid rgba(18,17,42,.07)"></div>
        <div class="add-folder-6" @click="delFloder">
            <i class="el-icon-delete"></i>
            删 除
        </div>
      </div>
    </div>
    
  <!-- 文件列表对话框 -->
<el-dialog 
  :title="`文件列表 - ${currentFolderName}`" 
  v-model="dialogVisible" 
  width="800px"
  destroy-on-close
  @close="handleDialogClose"
>
  <div>
    <el-form style="margin-top: 20px" :model="fileQueryParams" ref="dialogQueryForm" size="small" :inline="true" @submit. native.prevent>
      <el-form-item label="文件名称">
        <el-input placeholder="文件名称" v-model="fileQueryParams.name"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="small" @click="handleDialogSearch">搜索</el-button>
        <el-button icon="el-icon-refresh" size="small" @click="resetDialogQuery">重置</el-button>
      </el-form-item>
    </el-form>
    
    <el-table :data="fileListData" border v-loading="loading">
      <template #empty>
        <el-empty description="该文件夹暂无文件"></el-empty>
      </template>
      <el-table-column align="center" prop="name" label="文件名称"/>
      <el-table-column align="center" prop="size" label="文件大小">
        <template #default="scope">
          <div>{{ formatFileSize(scope.row.size) }}</div>
        </template>
      </el-table-column>
      <el-table-column align="center" prop="type" label="文件类型"/>
      <el-table-column align="center" prop="uploadTime" label="创建时间">
        <template #default="scope">
          <div>{{ formatTime(scope.row.uploadTime) }}</div>
        </template>
      </el-table-column>
      <el-table-column align="center" label="操作" width="200">
        <template #default="scope">
          <el-button type="text" @click="renameFile(scope.row)">重命名</el-button>
          <el-button type="text" @click="delFileItem(scope.row.id)">删除</el-button>
          <el-button type="text" @click="downloadFile(scope.row)">下载</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <div class="pagination" v-if="fileTotal > 0">
      <el-pagination
        v-model:current-page="fileQueryParams.pageNum"
        v-model:page-size="fileQueryParams.pageSize"
        :page-sizes="[5, 10, 20, 50]"
        :total="fileTotal"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleFileSizeChange"
        @current-change="handleFileCurrentChange"
      />
    </div>
  </div>
</el-dialog>
    <!-- 上传文件对话框 -->
    <el-dialog title="上传文件" v-model="uploadFileVisible" width="500px" append-to-body>
      <el-form ref="uploadFileRef" :model="uploadFileForm" :rules="uploadFileRules" label-width="80px">
        <el-form-item label="文件名" prop="name">
          <el-input v-model="uploadFileForm.name" placeholder="请输入文件名" />
        </el-form-item>
        <el-form-item label="文件" prop="file">
          <input 
            type="file" multiple
            ref="fileInput"
            @change="handleFileSelect"
            style="margin-top: 8px;"
          />
          <div v-if="selectedFile" style="margin-top: 8px; color: #666;">
            已选择: {{ selectedFile.name }}
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitUploadFile">确 定</el-button>
          <el-button @click="uploadFileVisible = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
   </div>
</template>

<script setup name="File">
import PageHeader from '@/components/PageHeader/index.vue'
import { listFile, addFileFile, updateFile,down,delFile,getFile } from "@/api/file/file";
import { getCurrentInstance, ref, reactive, toRefs, computed, onMounted, watch } from 'vue';

const { proxy } = getCurrentInstance();
const selectedFolderFiles = ref([]);
const folderInput = ref(null);
const batchUploadProgress = ref(0);
const batchUploadVisible = ref(false);
const batchUploadStatus = ref('');
const folderCache = ref({});
const currentFolderId = ref('0'); 
const breadcrumb = ref([]); 
const addFolderShow = ref(false);
const dialogVisible = ref(false); 
const loading = ref(false);
const fileTotal = ref(0);
const folderShow = ref(false);
const cardLoading = ref(false);
const folderName = ref(null);
const folderId = ref(null);
const type = ref(null);
const dataIndex = ref(null);
const single = ref(true);
const multiple = ref(true);
const folderList = ref([]);
const selectedFile = ref(null);
const selectedUploadFiles = ref([]);
const thumbnails = ref({});
async function loadThumbnails(files) {
  for (const file of files) {
    if (/\.(jpg|jpeg|png|gif|bmp)$/i.test(file.name || '') && !thumbnails.value[file.id]) {
      try { thumbnails.value[file.id] = URL.createObjectURL(await down(file.id)); } catch (_) {}
    }
  }
}
const fileInput = ref(null);
const showSearch = ref(true);
const currentFolder = ref({});
const currentFolderName = ref('');
const fileListData = ref([]);
const renameDialogVisible = ref(false);
const uploadFolderVisible = ref(false);
const createFolderVisible = ref(false);
const uploadFileVisible = ref(false);
const uploadingFolderId = ref(null);
const searchText = ref('');
const searchInputText = ref('');
const selectedItems = ref([]);

const renameForm = reactive({
  newName: '',
  item: null,
  type: 'folder' 
});

const uploadFolderForm = reactive({
  name: '',
  folder: null
});

const uploadFolderRules = {
  name: [{ required: true, message: "文件夹名不能为空", trigger: "blur" }]
};

const createFolderForm = reactive({
  name: ''
});

const createFolderRules = {
  name: [{ required: true, message: "文件夹名不能为空", trigger: "blur" }]
};

const uploadFileForm = reactive({
  name: '',
  file: null
});

const uploadFileRules = {
  name: [{ required: true, message: "文件名不能为空", trigger: "blur" }],
  file: [{ required: true, message: "请选择文件", trigger: "change" }]
};

const data = reactive({
  props: {
    containerId: {
      type: Number,
      required: true
    }
  },
  addFolderStyle: {
    left: '0px',
    top: '0px'
  },
  folderStyle: {
    left: '0px',
    top: '0px'
  },
  queryParams: {
    pageNum: 1,
    pageSize: 1000, 
    name: null,
    root: '0'
  },
  fileQueryParams: {
    pageNum: 1,
    pageSize: 10,
    name: null,
    root: '1'
  }
});

const { queryParams, addFolderStyle, folderStyle, fileQueryParams } = toRefs(data);
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));
const fileDataList = computed(() => {
  const start = (fileQueryParams.value.pageNum - 1) * fileQueryParams.value.pageSize;
  const end = start + fileQueryParams.value.pageSize;
  return fileListData.value.slice(start, end);
});

// 监听选中项变化，更新按钮状态
watch(selectedItems, (newVal) => {
  single.value = newVal.length !== 1;
  multiple.value = newVal.length === 0;
}, { deep: true });

function formatTime(timeStr) {
  if (!timeStr) return '';
  try {
    const date = new Date(timeStr);
    return date.toLocaleString();
  } catch (e) {
    return timeStr;
  }
}
function formatFileSize(bytes) {
  if (!bytes || bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}
function getFileType(filename) {
  const ext = filename.split('.').pop().toLowerCase();
  const typeMap = {
    'jpg': 'image',
    'jpeg': 'image', 
    'png': 'image',
    'gif': 'image',
    'pdf': 'document',
    'doc': 'document',
    'docx': 'document',
    'xls': 'document',
    'xlsx': 'document',
    'txt': 'text',
    'zip': 'archive',
    'rar': 'archive',
    '7z': 'archive'
  };
  return typeMap[ext] || 'file';
}
function handleFileSelect(event) {
  selectedUploadFiles.value = Array.from(event.target.files);
  selectedFile.value = selectedUploadFiles.value[0] || null;
  uploadFileForm.file = selectedFile.value;
  uploadFileForm.name = selectedUploadFiles.value.length > 1 ? '使用各文件原始名称' : selectedFile.value?.name || '';
}
function handleFolderSelect(event) {
  const files = Array.from(event.target.files);
  if (files.length > 0) {
    selectedFolderFiles.value = files;
    if (!uploadFolderForm.name) {
      const firstFile = files[0];
      if (firstFile.webkitRelativePath) {
        const pathParts = firstFile.webkitRelativePath.split('/');
        const folderName = pathParts[0];
        uploadFolderForm.name = folderName;
      }
    }
  }
}

// 处理项目单击事件
function handleItemClick(item, event) {
  event.stopPropagation(); 
  
  // 如果按住Ctrl键，则多选
  if (event.ctrlKey || event.metaKey) {
    const index = selectedItems.value.indexOf(item.id);
    if (index > -1) {

      selectedItems.value.splice(index, 1);
    } else {
  
      selectedItems.value.push(item.id);
    }
  } else {

    selectedItems.value = [item.id];
  }

  currentFolder.value = item;
  folderName.value = item.name;
  folderId.value = item.id;
  type.value = item.type;
  
  console.log('选中项:', selectedItems.value);
}

// 清除选中
function clearSelection() {
  selectedItems.value = [];
  currentFolder.value = {};
}

// 上传有内容的文件夹
function addFolderWithContent() {
  addFolderShow.value = false;
  resetUploadFolderForm();
  uploadFolderVisible.value = true;
}

// 创建空文件夹
function createEmptyFolder() {
  addFolderShow.value = false;
  resetCreateFolderForm();
  createFolderVisible.value = true;
}

// 提交上传文件夹
function submitUploadFolder() {
  proxy.$refs["uploadFolderRef"].validate(valid => {
    if (valid) {
      if (selectedFolderFiles.value.length === 0) {
        proxy.$modal.msgError("请选择要上传的文件夹");
        return;
      }
      uploadFolderWithFiles();
    }
  });
}

// 提交创建空文件夹
function submitCreateFolder() {
  proxy.$refs["createFolderRef"].validate(valid => {
    if (valid) {
      createEmptyFolderApi();
    }
  });
}

// 创建空文件夹
function createEmptyFolderApi() {
  const formData = new FormData();
  const emptyFile = new File([], 'empty.txt', { type: 'text/plain' });
  formData.append('file', emptyFile);
  formData.append('name', createFolderForm.name);
  formData.append('type', 'dir');
  formData.append('root', currentFolderId.value); 
  
  addFileFile(formData).then(response => {
    proxy.$modal.msgSuccess("文件夹创建成功");
    createFolderVisible.value = false;
    
    // 刷新列表
    list();
  }).catch(error => {
    console.error("创建文件夹错误:", error);
    proxy.$modal.msgError("操作失败: " + (error.response?.data?.message || error.message));
  });
}

// 重置上传文件夹表单
function resetUploadFolderForm() {
  uploadFolderForm.name = '';
  uploadFolderForm.folder = null;
  selectedFolderFiles.value = [];
  
  if (folderInput.value) {
    folderInput.value.value = '';
  }
  if (proxy.$refs["uploadFolderRef"]) {
    proxy.$refs["uploadFolderRef"].resetFields();
  }
}

// 重置创建文件夹表单
function resetCreateFolderForm() {
  createFolderForm.name = '';
  if (proxy.$refs["createFolderRef"]) {
    proxy.$refs["createFolderRef"].resetFields();
  }
}

// 重置上传文件表单
function resetUploadFileForm() {
  uploadFileForm.name = '';
  uploadFileForm.file = null;
  selectedFile.value = null;
  selectedUploadFiles.value = [];
  
  if (fileInput.value) {
    fileInput.value.value = '';
  }
  if (proxy.$refs["uploadFileRef"]) {
    proxy.$refs["uploadFileRef"].resetFields();
  }
}
// 处理输入事件
function handleSearch() {
  queryParams.value.name = searchInputText.value;
  list();
}
function handleReset() {
  searchInputText.value = '';
  queryParams.value.name = '';
  list();
}


// 查询文件夹列表 
async function list() {
  cardLoading.value = true;
  queryParams.value.root = currentFolderId.value;
  
  console.log('查询文件夹参数:', queryParams.value);
  
  const listParams = {
    ...queryParams.value,
    pageNum: 1,
    pageSize: 1000 
  };
  
  try {
    const res = await listFile(listParams);
    console.log('文件夹列表响应:', res);
    
    let data = [];
    if (res.rows) {
      data = res.rows;
    } else if (res.data) {
      data = res.data;
    }

    // 直接使用从接口获取的数据，不再合并任务结果文件夹
    if (currentFolderId.value === '0') {
      // 获取根目录文件夹
      folderList.value = data.filter(item => {
        return (item.root === '0' || item.root === 0 || item.root === null || item.root === undefined) ;
      });
    } else {
      folderList.value = data.filter(item => {
        return String(item.root) === String(currentFolderId.value);
      });
    }
    
    loadThumbnails(folderList.value);
    cardLoading.value = false;
  } catch (error) {
    console.error('获取项目列表失败:', error);
    cardLoading.value = false;
  }
  addFolderShow.value = false;
}

// 处理任务结果文件夹
function enterFolder(folder) {
  if (folder.type !== 'dir') {
    return; 
  }
  
  currentFolderId.value = folder.id;
  currentFolder.value = folder;
  updateBreadcrumb(folder);
  list();
  folderShow.value = false;
  clearSelection();
}

function openFolder(folder) {
  if (folder.type !== 'dir') {
    return; 
  }
  
  currentFolder.value = folder;
  currentFolderName.value = folder.name;
  folderShow.value = false;
  
  // 重置查询参数
  fileQueryParams.value = {
    pageNum: 1,
    pageSize: 10,
    name: null,
    root: folder.id
  };
  
  getFileList();
  dialogVisible.value = true;
}


onMounted(() => {
  list();
});

onUnmounted(() => {
  Object.values(thumbnails.value).forEach(url => URL.revokeObjectURL(url));
});



function updateBreadcrumb(folder) {
  if (folder.id === '0') {
    breadcrumb.value = [];
    return;
  }
  if (!breadcrumb.value.some(item => item.id === folder.id)) {
    breadcrumb.value.push(folder);
  }
}

// 返回根目录
function goToRoot() {
  currentFolderId.value = '0';
  breadcrumb.value = [];
  list();
  clearSelection();
}

// 跳转到指定文件夹
function goToFolder(folder) {
  const index = breadcrumb.value.findIndex(item => item.id === folder.id);
  if (index !== -1) {
    breadcrumb.value = breadcrumb.value.slice(0, index + 1);
  }
  currentFolderId.value = folder.id;
  currentFolder.value = folder;
  list();
  clearSelection();
}

// 获取文件列表 
function getFileList() {
  loading.value = true;
  
  // 确保传递正确的分页参数
  const params = {
    ...fileQueryParams.value,
    root: currentFolder.value.id || fileQueryParams.value.root
  };
  
  listFile(params).then(response => {
    if (response.code === 200) {
      // 使用后端返回的分页数据
      fileListData.value = response.rows || [];
      fileTotal.value = response.total || 0;
    } else {
      fileListData.value = [];
      fileTotal.value = 0;
      proxy.$modal.msgError("获取文件列表失败");
    }
    loading.value = false;
  }).catch((error) => {
    console.error('获取文件列表失败:', error);
    fileListData.value = [];
    fileTotal.value = 0;
    loading.value = false;
    proxy.$modal.msgError("获取文件列表失败");
  });
}

function handleFileSizeChange(val) {
  fileQueryParams.value.pageSize = val;
  fileQueryParams.value.pageNum = 1; // 重置到第一页
  getFileList(); 
}

function handleFileCurrentChange(val) {
  fileQueryParams.value.pageNum = val;
  getFileList(); 
}
function handleDialogClose() {
  // 重置分页参数
  fileQueryParams.value = {
    pageNum: 1,
    pageSize: 10,
    name: null,
    root: '1'
  };
  fileListData.value = [];
  fileTotal.value = 0;
}
function handleDialogSearch() {
  fileQueryParams.value.pageNum = 1; // 搜索时回到第一页
  getFileList();
}

function resetDialogQuery() {
  fileQueryParams.value = {
    pageNum: 1,
    pageSize: 10,
    name: null,
    root: currentFolder.value.id || fileQueryParams.value.root
  };
  getFileList();
}

function handleAddFileToFolder() {
  addFolderShow.value = false;
  resetUploadFileForm();
  
  if (folderShow.value && currentFolder.value && currentFolder.value.type === 'dir') {
    uploadFileForm.root = currentFolder.value.id;
  } else {
    // 右键在空白处上传，上传到当前文件夹
    uploadFileForm.root = currentFolderId.value;
  }
  
  console.log('上传文件到文件夹:', uploadFileForm.root);
  uploadFileVisible.value = true;
}

function submitUploadFile() {
  proxy.$refs["uploadFileRef"].validate(valid => {
    if (valid) {
      if (!selectedFile.value) {
        proxy.$modal.msgError("请选择要上传的文件");
        return;
      }
      uploadSingleFile();
    }
  });
}

// 上传单个文件
async function uploadSingleFile() {
  try {
    for (const file of selectedUploadFiles.value) {
      const data = new FormData();
      data.append('file', file);
      data.append('name', selectedUploadFiles.value.length === 1 ? uploadFileForm.name : file.name);
      data.append('type', getFileType(file.name));
      data.append('root', uploadFileForm.root);
      await addFileFile(data);
    }
    proxy.$modal.msgSuccess(`成功上传 ${selectedUploadFiles.value.length} 个文件`);
    uploadFileVisible.value = false;
    forceRefresh();
  } catch (error) { proxy.$modal.msgError('上传失败：' + error.message); }
}
// 强制刷新列表
function forceRefresh() {
  // 清空选中状态
  clearSelection();
  list(); 
  // 如果对话框打开，也刷新对话框列表
  if (dialogVisible.value) {
    getFileList();
  }
  
  console.log('强制刷新完成，当前文件夹ID:', currentFolderId.value);
}
// 上传包含文件的文件夹 
function uploadFolderWithFiles() {
  batchUploadProgress.value = 0;
  batchUploadVisible.value = true;
  batchUploadStatus.value = 'uploading';
  
  // 首先创建父文件夹
  const folderFormData = new FormData();
  const emptyFile = new File([], 'empty.txt', { type: 'text/plain' });
  folderFormData.append('file', emptyFile);
  folderFormData.append('name', uploadFolderForm.name);
  folderFormData.append('type', 'dir');
  folderFormData.append('root', currentFolderId.value); 
  addFileFile(folderFormData).then(folderResponse => {
    if (folderResponse.code === 200) {
      const folderName = uploadFolderForm.name;
      const parentId = currentFolderId.value;
      setTimeout(() => {
        queryFolderIdByName(folderName, parentId).then(folderId => {
          if (folderId) {
            uploadingFolderId.value = folderId;
            uploadFolderRecursively(folderId);
          } else {
            throw new Error('无法获取新创建的文件夹ID，请稍后重试');
          }
        }).catch(error => {
          console.error("查询文件夹ID失败:", error);
          batchUploadStatus.value = 'exception';
          proxy.$modal.msgError("查询文件夹失败: " + error.message);
        });
      }, 1500); 
      
    } else {
      throw new Error(folderResponse.msg || '创建文件夹失败');
    }
  }).catch(error => {
    console.error("创建文件夹错误:", error);
    batchUploadStatus.value = 'exception';
    
    let errorMessage = '创建文件夹失败';
    if (error.response && error.response.data && error.response.data.message) {
      errorMessage = error.response.data.message;
    } else if (error.message) {
      errorMessage = error.message;
    }
    
    proxy.$modal.msgError(errorMessage);
  });
}

// 递归上传文件夹及其内容
async function uploadFolderRecursively(parentFolderId) {
  const files = selectedFolderFiles.value;
  const totalFiles = files.length;
  let uploadedCount = 0;
  const folderStructure = buildFolderStructure(files);
  const uploadProgress = { uploadedCount: 0, processedCount: 0, failedFiles: [] };
  try {
    await processFolderStructure(parentFolderId, folderStructure, (progress) => {
      uploadedCount = progress.uploadedCount;
      batchUploadProgress.value = Math.round((progress.processedCount / totalFiles) * 100);
    }, uploadProgress);
    if (uploadProgress.failedFiles.length > 0) {
      throw new Error(`${uploadProgress.failedFiles.length} 个文件上传失败，已成功上传 ${uploadedCount} 个文件`);
    }
    batchUploadProgress.value = 100;
    batchUploadStatus.value = 'success';
    proxy.$modal.msgSuccess(`文件夹上传完成，共上传 ${uploadedCount} 个文件`);
    
    setTimeout(() => {
      batchUploadVisible.value = false;
      uploadFolderVisible.value = false;
      uploadingFolderId.value = null; 
      list();
    }, 1000);
    
  } catch (error) {
    console.error('递归上传失败:', error);
    batchUploadStatus.value = 'exception';
    uploadingFolderId.value = null; 
    proxy.$modal.msgError("文件夹上传失败: " + error.message);
  }
}

// 构建文件夹结构
function buildFolderStructure(files) {
  const structure = {
    files: [],
    folders: {}
  };
  
  files.forEach(file => {
    if (file.webkitRelativePath) {
      const pathParts = file.webkitRelativePath.split('/');
      let currentLevel = structure;

      for (let i = 1; i < pathParts.length - 1; i++) {
        const folderName = pathParts[i];
        if (!currentLevel.folders[folderName]) {
          currentLevel.folders[folderName] = {
            files: [],
            folders: {}
          };
        }
        currentLevel = currentLevel.folders[folderName];
      }
  
      currentLevel.files.push(file);
    } else {

      structure.files.push(file);
    }
  });
  
  return structure;
}

// 递归处理文件夹结构
async function processFolderStructure(parentId, structure, progressCallback, progress) {
  for (const file of structure.files) {
    try {
      await uploadFileToFolder(parentId, file);
      progress.uploadedCount++;
    } catch (error) {
      console.error(`文件 ${file.name} 上传失败:`, error);
      progress.failedFiles.push(file.name);
    }
    progress.processedCount++;
    progressCallback(progress);
    await delay(500);
  }
  
  // 递归处理子文件夹
  for (const [folderName, subStructure] of Object.entries(structure.folders)) {
    const folderId = await ensureFolderExists(parentId, folderName);
    await processFolderStructure(folderId, subStructure, progressCallback, progress);
  }
}

async function ensureFolderExists(parentId, folderName) {
  const cacheKey = `${parentId}-${folderName}`;
 
  if (folderCache.value[cacheKey]) {
    return folderCache.value[cacheKey];
  }

  const existingFolderId = await queryFolderIdByName(folderName, parentId);
  if (existingFolderId) {
    folderCache.value[cacheKey] = existingFolderId;
    return existingFolderId;
  }

  await delay(300);
  
  // 创建新文件夹
  const folderFormData = new FormData();
  const emptyFile = new File([], 'empty.txt', { type: 'text/plain' });
  folderFormData.append('file', emptyFile);
  folderFormData.append('name', folderName);
  folderFormData.append('type', 'dir');
  folderFormData.append('root', parentId);
  
  try {
    await addFileFile(folderFormData);

    await delay(500);

    const newFolderId = await queryFolderIdByNameWithRetry(folderName, parentId);
    folderCache.value[cacheKey] = newFolderId;
    
    return newFolderId;
  } catch (error) {
    console.error(`创建文件夹 ${folderName} 失败:`, error);
    throw error;
  }
}

// 上传文件到指定文件夹 
async function uploadFileToFolder(folderId, file) {
  const formData = new FormData();
  formData.append('file', file);

  let fileName = file.name;
  if (file.webkitRelativePath) {
 
    const pathParts = file.webkitRelativePath.split('/');
    fileName = pathParts[pathParts.length - 1];
  }
  
  formData.append('name', fileName);
  formData.append('type', getFileType(file.name));
  formData.append('root', folderId);
  
  console.log(`上传文件到文件夹 ${folderId}:`, fileName);
  
  try {
    await addFileFile(formData);
 
    await delay(300);
  } catch (error) {
    console.error(`文件 ${fileName} 上传失败:`, error);
    throw error;
  }
}

// 根据文件夹名称和父文件夹ID查询文件夹ID
function queryFolderIdByName(folderName, parentId) {
  return new Promise((resolve, reject) => {
    const queryParams = {
      name: folderName,
      type: 'dir',
      pageNum: 1,
      pageSize: 100
    };
   
    if (parentId !== null && parentId !== undefined) {
      queryParams.root = parentId;
    }
    listFile(queryParams).then(response => {
      let data = [];
      if (response.rows) {
        data = response.rows;
      } else if (response.data) {
        data = response.data;
      }
      const matchingFolders = data.filter(item => 
        item.type === 'dir' && 
        item.name === folderName
      );
 
      if (matchingFolders.length > 0) {
        const newestFolder = matchingFolders.reduce((prev, current) => {
          return (prev.id > current.id) ? prev : current;
        });
        resolve(newestFolder.id);
      } else {
        resolve(null);
      }
    }).catch(error => {
      console.error('查询文件夹失败:', error);
      reject(error);
    });
  });
}

// 带重试的文件夹查询
function queryFolderIdByNameWithRetry(folderName, parentId, maxRetries = 5, delay = 1000) {
  return new Promise((resolve, reject) => {
    const tryQuery = (attempt) => {
      queryFolderIdByName(folderName, parentId)
        .then(folderId => {
          if (folderId) {
            resolve(folderId);
          } else if (attempt < maxRetries) {
            console.log(`第 ${attempt} 次查询文件夹失败，${delay}ms后重试...`);
            setTimeout(() => tryQuery(attempt + 1), delay);
          } else {
            reject(new Error(`重试 ${maxRetries} 次后仍未找到文件夹 ${folderName}`));
          }
        })
        .catch(error => {
          if (attempt < maxRetries) {
            console.log(`第 ${attempt} 次查询文件夹失败，${delay}ms后重试...`);
            setTimeout(() => tryQuery(attempt + 1), delay);
          } else {
            reject(error);
          }
        });
    };
    
    tryQuery(1);
  });
}

// 重命名文件夹
function updateFloder() {
  folderShow.value = false;
  if (selectedItems.value.length === 0) {
    proxy.$modal.msgError("请先选择一个项目");
    return;
  }
  
  const selectedItem = folderList.value.find(item => item.id === selectedItems.value[0]);
  if (!selectedItem) {
    proxy.$modal.msgError("选中的项目不存在");
    return;
  }
  
  renameForm.newName = selectedItem.name;
  renameForm.item = selectedItem;
  renameForm.type = selectedItem.type === 'dir' ? 'folder' : 'file';
  renameDialogVisible.value = true;
}

// 确认重命名
function confirmRename() {
  if (!renameForm.newName) {
    proxy.$modal.msgError("请输入新名称");
    return;
  }

  const updateData = {
    id: renameForm.item.id,
    name: renameForm.newName,
    type: renameForm.item.type,
    root: renameForm.item.root || currentFolderId.value,
    size: renameForm.item.size || 0,
    uploadTime: renameForm.item.uploadTime || new Date().toISOString()
  };
  if (renameForm.item.type !== 'dir') {
    updateData.filePath = renameForm.item.filePath || '';
    updateData.fileType = renameForm.item.fileType || getFileType(renameForm.item.name);
  }

  updateFile(updateData).then(res => {
    if (res.code == 200) {
      proxy.$modal.msgSuccess("重命名成功!");
      renameDialogVisible.value = false;
  
      if (renameForm.type === 'folder') {
        list(); 
      } else {
        getFileList();
      }
    } else {
      proxy.$modal.msgError("重命名失败请重试!");
    }
  }).catch(error => {
    console.error('重命名错误:', error);
    proxy.$modal.msgError("重命名失败: " + (error.message || '未知错误'));
  });
}


// 删除文件夹
function delFloder(id) {
  folderShow.value = false;
  let itemsToDelete = [];
  if (selectedItems.value.length > 0) {
    itemsToDelete = folderList.value.filter(item => selectedItems.value.includes(item.id));
  } else if (currentFolder.value && currentFolder.value.id) {
    itemsToDelete = [currentFolder.value];
  } else {
    proxy.$message({
      type: 'error',
      message: '请先选择要删除的项目!'
    });
    return;
  }
  if (itemsToDelete.length === 0) {
    proxy.$message({
      type: 'error',
      message: '没有找到要删除的项目!'
    });
    return;
  }

  proxy.$confirm(`此操作将永久删除选中的 ${itemsToDelete.length} 个项目, 是否继续?`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    const deletePromises = itemsToDelete.map(item => {
      const itemIdToDelete = Number(item.id);
      console.log('删除项目ID:', itemIdToDelete, '名称:', item.name);

      if (isNaN(itemIdToDelete) || itemIdToDelete <= 0) {
        return Promise.reject(new Error(`无效的项目ID: ${item.id}`));
      }
      
      return delFile(itemIdToDelete).then(res => {
        if (res.code == 200) {
          return { success: true, name: item.name };
        } else {
          return { success: false, name: item.name, error: res.msg };
        }
      }).catch(error => {
        console.error('删除项目错误:', error);
        return { success: false, name: item.name, error: error.message };
      });
    });

    Promise.all(deletePromises).then(results => {
      const successCount = results.filter(r => r.success).length;
      const errorCount = results.filter(r => !r.success).length;

      if (errorCount === 0) {
        proxy.$message({
          type: 'success',
          message: `成功删除 ${successCount} 个项目!`
        });
      } else {
        const errorNames = results.filter(r => !r.success).map(r => r.name).join(', ');
        proxy.$message({
          type: 'error',
          message: `成功删除 ${successCount} 个项目，失败 ${errorCount} 个! 失败的项目: ${errorNames}`
        });
      }
      list();
      clearSelection();
      if (dialogVisible.value && itemsToDelete.some(item => item.id === fileQueryParams.value.root)) {
        dialogVisible.value = false;
      }
    });

  });
}
/** 下载文件 */
async function downloadFile(file) {
  try {
    if (!file || !file.id) {
      proxy.$modal.msgError("无法获取文件信息");
      return;
    }

    console.log('下载文件:', file.name, 'ID:', file.id);

    const loading = proxy.$loading({
      lock: true,
      text: `正在下载: ${file.name}`,
      background: 'rgba(0, 0, 0, 0.7)'
    });

    const blobData = await down(file.id);
    if (!blobData || blobData.size === 0) {
      throw new Error('文件内容为空');
    }
    const url = window.URL.createObjectURL(blobData);
    const a = document.createElement('a');
    a.href = url;
    a.download = file.name;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
    
    proxy.$modal.msgSuccess(`下载完成: ${file.name}`);
    
  } catch (error) {
    console.error('下载失败:', error);
    proxy.$modal.msgError(`下载失败: ${error.message}`);
  } finally {
    proxy.$loading().close();
  }
}
// 删除文件
function delFileItem(id) {
  proxy.$confirm('此操作将永久删除该文件, 是否继续?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    delFile(id).then(res => {
      if (res.code == 200) {
        proxy.$message({
          type: 'success',
          message: '删除成功!'
        });
        getFileList(); 
      } else {
        proxy.$message({
          type: 'error',
          message: '删除失败请重试!'
        });
      }
    }).catch(error => {
      proxy.$message({
        type: 'error',
        message: '删除失败: ' + (error.message || '未知错误')
      });
    });
  }).catch(() => {
  });
}


// 文件夹右键
function rightClickFolder(index, item, e) {
  if (!selectedItems.value.includes(item.id)) {
    selectedItems.value = [item.id];
  }
  
  currentFolder.value = item;
  folderName.value = item.name;
  folderId.value = item.id;
  type.value = item.type;
  dataIndex.value = index;
  folderStyle.value.left = e.pageX + 'px';
  folderStyle.value.top = e.pageY + 'px';
  folderShow.value = true;
  addFolderShow.value = false;
  
  console.log('右键文件夹:', item.name, 'ID:', item.id, '类型:', item.type);
}
function rightClick(e) {
  addFolderStyle.value.left = e.pageX + 'px';
  addFolderStyle.value.top = e.pageY + 'px';
  addFolderShow.value = true;
  folderShow.value = false;
  
  // 清除之前的文件夹选中状态
  currentFolder.value = {};
  console.log('右键空白处，当前文件夹ID:', currentFolderId.value);
}

// 初始化
onMounted(() => {
  list();
});
</script>
<style scoped>
@import "@/assets/css/file_icon.css";

.breadcrumb {
  margin-bottom: 15px;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.breadcrumb a {
  cursor: pointer;
  color: #409EFF;
}

.breadcrumb a:hover {
  color: #66b1ff;
}

.folderContainer {
  display: inline-block;
  margin: 10px;
  text-align: center;
}

.folderWrapper {
  cursor: pointer;
  padding: 10px;
  border-radius: 5px;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.folderWrapper:hover {
  background-color: #f5f7fa;
}

.folderWrapper.selected {
  background-color: #ecf5ff;
  width:140px;
  height:100px;
}

.folderName {
  margin-top: 5px;
  font-size: 14px;
}

.folderTime {
  margin-top: 2px;
  font-size: 12px;
  color: #909399;
}

.pagination {
  margin-top: 15px;
  text-align: right;
}



</style>
