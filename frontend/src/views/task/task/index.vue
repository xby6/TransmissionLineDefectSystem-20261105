<template>
  <div class="app-container">
    <PageHeader title="检测任务管理" description="创建检测任务，跟踪执行状态并查看结果。" eyebrow="DETECTION WORKSPACE" />
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="任务名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入任务名称" clearable style="width: 240px"
          @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="执行平台" prop="container">
        <el-select v-model="queryParams.container" placeholder="请选择执行平台" clearable style="width: 240px">
          <el-option v-for="container in containers" :key="container.id" :label="container.name"
            :value="container.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="算法名称" prop="algo">
        <el-select v-model="queryParams.algo" placeholder="请选择算法名称" clearable style="width: 240px">
          <el-option v-for="algorithm in algorithms" :key="algorithm.name" :label="algorithm.name"
            :value="algorithm.name" />
        </el-select>
      </el-form-item>
      <el-form-item label="任务状态" prop="state">
        <el-select v-model="queryParams.state" placeholder="请选择任务状态" clearable style="width: 240px">
          <el-option label="全部" value="" />
          <el-option label="等待中" value="pending" />
          <el-option label="运行中" value="running" />
          <el-option label="已完成" value="success" />
          <el-option label="失败" value="failed" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['task:task:add']">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="Edit" :disabled="single" @click="handleUpdate"
          v-hasPermi="['task:task:edit']">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="Delete" :disabled="multiple" @click="handleDelete"
          v-hasPermi="['task:task:remove']">删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="taskList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="任务号" align="center" prop="id" width="80" />
      <el-table-column label="任务名称" align="left" prop="name" min-width="200" show-overflow-tooltip />
      <el-table-column label="执行平台" align="left" prop="container" min-width="175" show-overflow-tooltip>
        <template #default="scope">
          <span>{{ getContainerName(scope.row.container) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="任务状态" align="center" prop="state" width="100">
        <template #default="scope">
          <div style="display: flex; align-items: center; justify-content: center;">
            <el-tag :type="getStatusType(scope.row.state, scope.row.result)">
              {{ getStatusText(scope.row.state, scope.row.result) }}
            </el-tag>
            <el-icon v-if="!scope.row.result && (scope.row.state === 'running' || scope.row.state === '')"
              class="is-loading" style="margin-left: 5px;">
              <Loading />
            </el-icon>
          </div>
        </template>
      </el-table-column>

      <el-table-column label="任务结果" align="center" prop="result" width="120">
        <template #default="scope">
          <el-button v-if="scope.row.result" link type="primary"
            @click="openResultFolder(scope.row.result, scope.row.name)">
            <el-icon>
              <FolderOpened />
            </el-icon>
            查看结果
          </el-button>
          <el-tag v-else-if="!scope.row.result && (scope.row.state === 'running' || scope.row.state === '')"
            type="warning">执行中...</el-tag>
          <el-tag v-else-if="scope.row.state === 'pending'" type="info">等待执行</el-tag>
          <el-tag v-else-if="scope.row.state === 'failed'" type="danger">执行失败</el-tag>
          <span v-else-if="!scope.row.result && scope.row.state === 'completed'" class="no-result">无结果</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="算法名称" align="left" prop="algo" min-width="205" show-overflow-tooltip />
      <el-table-column label="任务参数" align="center" prop="args" width="120">
        <template #default="scope">
          <el-tooltip effect="dark" placement="top">
            <template #content>
              <div style="max-width: 400px; white-space: pre-wrap;">{{ formatArgs(scope.row.args) }}</div>
            </template>
            <el-button link type="primary">查看参数</el-button>
          </el-tooltip>
        </template>
      </el-table-column>
      <el-table-column label="备注信息" align="center" prop="remark" min-width="120" show-overflow-tooltip />
      <el-table-column label="创建时间" align="center" prop="initTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.initTime, '{y}-{m}-{d} {h}:{i}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="完成时间" align="center" prop="endTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.endTime, '{y}-{m}-{d} {h}:{i}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" fixed="right" width="210" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="VideoPlay" @click="handleExecute(scope.row)"
            :disabled="['queued', 'running'].includes(scope.row.state)" v-hasPermi="['task:task:execute']">执行</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)"
            v-hasPermi="['task:task:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)"
            v-hasPermi="['task:task:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize"
      @pagination="getList" />

    <!-- 添加或修改任务对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="taskRef" :model="form" :rules="rules" label-width="100px">
        <el-steps :active="currentStep" align-center style="margin-bottom: 20px;">
          <el-step title="选择平台" />
          <el-step title="选择算法" />
          <el-step title="选择文件" />
          <el-step title="配置参数" />
        </el-steps>

        <!-- 第一步：选择平台 -->
        <div v-if="currentStep === 0">
          <el-form-item label="执行平台" prop="container">
            <el-select v-model="form.container" placeholder="请选择执行平台" style="width: 100%" @change="onContainerChange"
              :loading="containerLoading">
              <el-option v-for="container in containers" :key="container.id" :label="container.name"
                :value="container.id" />
            </el-select>
          </el-form-item>
          <div class="step-actions">
            <el-button type="primary" @click="currentStep = 1" :disabled="!form.container">下一步</el-button>
          </div>
        </div>

        <!-- 第二步：选择算法 -->
        <div v-if="currentStep === 1">
          <el-form-item label="算法名称" prop="algo">
            <el-select v-model="form.algo" placeholder="请选择算法名称" style="width: 100%" :disabled="!form.container"
              :loading="algorithmLoading" @change="onAlgorithmSelect">
              <el-option v-for="algorithm in containerAlgorithms[form.container] || []" :key="algorithm.name"
                :label="algorithm.name" :value="algorithm.name" />
            </el-select>
          </el-form-item>
          <div class="step-actions">
            <el-button @click="currentStep = 0">上一步</el-button>
            <el-button type="primary" @click="currentStep = 2" :disabled="!form.algo">下一步</el-button>
          </div>
        </div>

        <!-- 第三步：选择文件 -->
        <div v-if="currentStep === 2">
          <el-form-item label="选择输入文件">
            <div class="file-selection-container">
              <div class="file-selection-header">
                <span class="file-selection-title">已选文件</span>
                <el-button type="primary" @click="openFileSelectionDialog">
                  <el-icon>
                    <Plus />
                  </el-icon>选择文件
                </el-button>
              </div>

              <!-- 已选文件列表 -->
              <div v-if="selectedFiles.length > 0" class="selected-files-list">
                <div v-for="file in selectedFiles" :key="file.id" class="selected-file-item">
                  <div class="file-info">
                    <el-icon>
                      <Document />
                    </el-icon>
                    <span class="file-name">{{ file.name }}</span>
                    <span class="file-size">({{ formatFileSize(file.size) }})</span>
                    <el-tag v-if="file.folderPath" size="small" type="info">
                      {{ file.folderPath }}
                    </el-tag>
                  </div>
                  <el-button type="danger" link @click="removeSelectedFile(file.id)">
                    <el-icon>
                      <Delete />
                    </el-icon>
                  </el-button>
                </div>
              </div>
              <div v-else class="no-files-tip">
                <el-empty description="暂未选择文件" :image-size="80" />
              </div>

              <div class="selected-count">
                已选择 {{ selectedFiles.length }} 个文件
              </div>
            </div>
          </el-form-item>

          <div class="step-actions">
            <el-button @click="currentStep = 1">上一步</el-button>
            <el-button type="primary" @click="currentStep = 3" :disabled="selectedFiles.length === 0">下一步</el-button>
          </div>
        </div>

        <!-- 第四步：配置参数 -->
        <div v-if="currentStep === 3">
          <el-form-item label="任务名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入任务名称" />
          </el-form-item>

          <el-form-item label="备注信息" prop="remark">
            <el-input v-model="form.remark" placeholder="请输入备注信息" type="textarea" :rows="3" />
          </el-form-item>

          <el-form-item label="任务参数配置">
            <div class="param-container">
              <div class="param-header">
                <span class="param-title">参数配置</span>
                <el-button type="primary" link @click="addParameter">
                  <el-icon>
                    <Plus />
                  </el-icon>添加参数
                </el-button>
              </div>

              <!-- 显示算法参数说明 -->
              <div v-if="algorithmParams.length > 0" class="algorithm-params-info">
                <h4>算法参数说明：</h4>
                <div v-for="param in algorithmParams" :key="param.name" class="param-info-item">
                  <span class="param-name">{{ param.name }}:</span>
                  <span class="param-intro">{{ param.intro }}</span>
                  <span v-if="param.default && param.default !== '默认值'" class="param-default">(默认值: {{ param.default
                    }})</span>
                </div>
              </div>

              <div v-else class="algorithm-params-info">
                <h4>算法参数说明：</h4>
                <p class="no-params-tip">该算法没有预定义的参数配置，请根据需要手动添加参数。</p>
              </div>

              <!-- 参数列表 -->
              <div v-for="(param, index) in form.params" :key="index" class="param-item">
                <div class="param-item-header">
                  <span>参数 {{ index + 1 }}</span>
                  <el-button type="danger" link @click="removeParameter(index)">
                    <el-icon>
                      <Delete />
                    </el-icon>删除
                  </el-button>
                </div>

                <el-row :gutter="10">
                  <el-col :span="6">
                    <el-form-item label="参数名" :prop="`params.${index}.name`"
                      :rules="{ required: true, message: '参数名不能为空', trigger: 'blur' }">
                      <el-input v-model="param.name" placeholder="参数名称" />
                    </el-form-item>
                  </el-col>
                  <el-col :span="6">
                    <el-form-item label="参数类型">
                      <el-select v-model="param.type" placeholder="请选择" @change="onParamTypeChange(param)">
                        <el-option label="字符串" value="string" />
                        <el-option label="整数" value="int" />
                        <el-option label="浮点数" value="float" />
                        <el-option label="布尔值" value="bool" />
                        <el-option label="文件" value="file" />
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="10">
                    <el-form-item label="参数值" :prop="`params.${index}.value`" :rules="getParamRules(param)">
                      <div v-if="param.type === 'file'" class="file-param-input">
                        <el-input v-model="param.value" placeholder="请选择文件" readonly />
                        <el-button type="primary" @click="openFileParamSelection(param)" style="margin-left: 10px;">
                          选择文件
                        </el-button>
                      </div>
                      <el-input v-else v-model="param.value" :placeholder="getParamPlaceholder(param.type)" />
                    </el-form-item>
                  </el-col>
                </el-row>

                <div v-if="param.type === 'file' && param.value" class="file-param-info">
                  <el-tag type="success" size="small">
                    <el-icon>
                      <Document />
                    </el-icon>
                    {{ getFileNameById(param.value) }}
                  </el-tag>
                </div>
              </div>
            </div>
          </el-form-item>

          <div class="step-actions">
            <el-button @click="currentStep = 2">上一步</el-button>
            <el-button type="primary" @click="submitForm">提交</el-button>
          </div>
        </div>
      </el-form>
    </el-dialog>


    <!-- 文件选择对话框 - 树状结构 -->
    <el-dialog title="选择文件" v-model="fileSelectionDialogVisible" width="1000px" top="5vh" append-to-body>
      <div class="file-selection-dialog">
        <el-row :gutter="20">
          <!-- 左侧文件夹树 -->
          <el-col :span="8">
            <div class="folder-tree-panel">
              <div class="panel-header">
                <h4>文件夹结构</h4>
                <el-button type="primary" link @click="refreshFolderTree" :loading="folderTreeLoading">
                  <el-icon>
                    <Refresh />
                  </el-icon>
                  刷新
                </el-button>
              </div>
              <div class="tree-container">
                <el-tree ref="folderTreeRef" :data="folderTreeData" :props="folderTreeProps" :load="loadFolderTree" lazy
                  node-key="id" :expand-on-click-node="false" :highlight-current="true"
                  @node-click="handleFolderTreeNodeClick" v-loading="folderTreeLoading">
                  <template #default="{ node, data }">
                    <span class="custom-tree-node">
                      <el-icon v-if="data.type === 'dir'">
                        <Folder />
                      </el-icon>
                      <el-icon v-else>
                        <Document />
                      </el-icon>
                      <span>{{ node.label }}</span>
                    </span>
                  </template>
                </el-tree>
              </div>
            </div>
          </el-col>

          <!-- 右侧文件列表 -->
          <el-col :span="16">
            <div class="file-list-panel">
              <div class="panel-header">
                <h4>文件列表
                  <span v-if="currentFolder" class="current-folder">- {{ currentFolder.name }}</span>
                </h4>
                <el-form :model="fileSelectionQuery" ref="fileSelectionQueryRef" size="small" :inline="true">
                  <el-form-item>
                    <el-input v-model="fileSelectionQuery.name" placeholder="输入文件名称搜索" clearable
                      @keyup.enter="handleFileSelectionSearch" />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="primary" icon="Search" @click="handleFileSelectionSearch">搜索</el-button>
                    <el-button icon="Refresh" @click="resetFileSelectionQuery">重置</el-button>
                  </el-form-item>
                </el-form>
              </div>

              <div class="file-selection-summary" role="status">
                <span>当前文件夹共 {{ fileSelectionTotal }} 张图片，本页 {{ fileSelectionList.length }} 张</span>
                <span>列表可滚动查看，支持跨页、跨文件夹勾选</span>
              </div>
              <el-table :data="fileSelectionList" v-loading="fileSelectionLoading"
                @selection-change="handleFileSelectionChange" ref="fileSelectionTableRef" :max-height="filePickerTableMaxHeight" row-key="id">
                <!-- reserve-selection 必须配合 row-key 使用 -->
                <el-table-column type="selection" :reserve-selection="true" width="55" />
                <el-table-column type="index" label="序号" width="55"
                  :index="index => (fileSelectionQuery.pageNum - 1) * fileSelectionQuery.pageSize + index + 1" />
                <el-table-column label="文件名称" prop="name" />
                <el-table-column label="文件大小" prop="size" width="100">
                  <template #default="scope">
                    {{ formatFileSize(scope.row.size) }}
                  </template>
                </el-table-column>
                <el-table-column label="文件类型" prop="type" width="80" />
                <el-table-column label="创建时间" prop="uploadTime" width="160">
                  <template #default="scope">
                    {{ parseTime(scope.row.uploadTime) }}
                  </template>
                </el-table-column>
              </el-table>

              <div class="pagination">
                <el-pagination v-model:current-page="fileSelectionQuery.pageNum"
                  v-model:page-size="fileSelectionQuery.pageSize" :page-sizes="[10, 20, 50]" :total="fileSelectionTotal"
                  layout="total, sizes, prev, pager, next" @size-change="handleFileSelectionSizeChange"
                  @current-change="handleFileSelectionCurrentChange" />
              </div>
            </div>
          </el-col>
        </el-row>

        <div class="dialog-footer">
          <div class="selected-info">
            <div class="selected-count">
              已选择 {{ fileSelectionSelected.length }} 个文件
            </div>
            <div v-if="fileSelectionSelected.length > 0" class="selected-preview">
              <el-tag v-for="file in fileSelectionSelected.slice(0, 3)" :key="file.id" size="small" closable
                @close="removeFileSelection(file.id)" style="margin-right: 5px; margin-bottom: 5px;">
                {{ file.name }}
              </el-tag>
              <span v-if="fileSelectionSelected.length > 3" class="more-files">
                等 {{ fileSelectionSelected.length }} 个文件
              </span>
            </div>
          </div>
          <div>
            <el-button @click="fileSelectionDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="confirmFileSelection">确认选择</el-button>
          </div>
        </div>
      </div>
    </el-dialog>

    <!-- 单个文件参数选择对话框  -->
    <el-dialog title="选择文件参数" v-model="fileParamDialogVisible" width="1000px" append-to-body>
      <div class="file-param-dialog">
        <el-row :gutter="20">
          <!-- 左侧文件夹树 -->
          <el-col :span="8">
            <div class="folder-tree-panel">
              <div class="panel-header">
                <h4>文件夹结构</h4>
              </div>
              <div class="tree-container">
                <el-tree ref="fileParamTreeRef" :data="fileParamTreeData" :props="folderTreeProps"
                  :load="loadFileParamTree" lazy node-key="id" :expand-on-click-node="false" :highlight-current="true"
                  @node-click="handleFileParamTreeNodeClick" v-loading="fileParamTreeLoading">
                  <template #default="{ node, data }">
                    <span class="custom-tree-node">
                      <el-icon v-if="data.type === 'dir'">
                        <Folder />
                      </el-icon>
                      <el-icon v-else>
                        <Document />
                      </el-icon>
                      <span>{{ node.label }}</span>
                    </span>
                  </template>
                </el-tree>
              </div>
            </div>
          </el-col>

          <!-- 右侧文件列表 -->
          <el-col :span="16">
            <div class="file-list-panel">
              <div class="panel-header">
                <h4>文件列表
                  <span v-if="fileParamCurrentFolder" class="current-folder">- {{ fileParamCurrentFolder.name }}</span>
                </h4>
                <el-form :model="fileParamQuery" ref="fileParamQueryRef" size="small" :inline="true">
                  <el-form-item>
                    <el-input v-model="fileParamQuery.name" placeholder="输入文件名称搜索" clearable
                      @keyup.enter="handleFileParamSearch" />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="primary" icon="Search" @click="handleFileParamSearch">搜索</el-button>
                    <el-button icon="Refresh" @click="resetFileParamQuery">重置</el-button>
                  </el-form-item>
                </el-form>
              </div>

              <el-table :data="fileParamList" v-loading="fileParamLoading" @row-click="handleFileParamRowClick"
                height="400">
                <el-table-column label="文件名称" prop="name" />
                <el-table-column label="文件大小" prop="size" width="120">
                  <template #default="scope">
                    {{ formatFileSize(scope.row.size) }}
                  </template>
                </el-table-column>
                <el-table-column label="文件类型" prop="type" width="120" />
                <el-table-column label="创建时间" prop="uploadTime" width="180">
                  <template #default="scope">
                    {{ parseTime(scope.row.uploadTime) }}
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="80">
                  <template #default="scope">
                    <el-button type="primary" link @click="selectFileParam(scope.row)">选择</el-button>
                  </template>
                </el-table-column>
              </el-table>

              <div class="pagination">
                <el-pagination v-model:current-page="fileParamQuery.pageNum" v-model:page-size="fileParamQuery.pageSize"
                  :page-sizes="[10, 20, 50]" :total="fileParamTotal" layout="total, sizes, prev, pager, next"
                  @size-change="handleFileParamSizeChange" @current-change="handleFileParamCurrentChange" />
              </div>
            </div>
          </el-col>
        </el-row>
      </div>
    </el-dialog>

    <!-- 结果文件列表对话框 -->
    <el-dialog :title="`任务结果文件 - ${currentFolderName}`" v-model="fileDialogVisible" width="900px" destroy-on-close
      @close="handleFileDialogClose">
      <div>
        <el-form :model="fileQueryParams" ref="fileQueryRef" size="small" :inline="true" @submit.native.prevent>
          <el-form-item label="文件名称">
            <el-input placeholder="文件名称" v-model="fileQueryParams.name"></el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" size="small" @click="handleFileQuery">搜索</el-button>
            <el-button icon="Refresh" size="small" @click="resetFileQuery">重置</el-button>
          </el-form-item>
        </el-form>

        <el-table :data="fileDataList" border v-loading="fileLoading">
          <template #empty>
            <el-empty description="该文件夹暂无文件或文件夹" />
          </template>

          <el-table-column align="center" prop="id" label="ID" width="80" />
          <el-table-column align="center" prop="name" label="名称" width="200" />
          <el-table-column align="center" prop="type" label="类型" width="120">
            <template #default="scope">
              <el-tag :type="scope.row.type === 'dir' ? 'primary' : 'success'">
                {{ scope.row.type === 'dir' ? '文件夹' : '文件' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column align="center" prop="root" label="所属文件夹ID" width="120">
            <template #default="scope">
              <span>{{ scope.row.root }}</span>
            </template>
          </el-table-column>
          <el-table-column align="center" prop="size" label="大小" width="120">
            <template #default="scope">
              <div>
                <span v-if="scope.row.type === 'dir'">-</span>
                <span v-else>{{ formatFileSize(scope.row.size) }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column align="center" label="操作" width="200">
            <template #default="scope">
              <!-- 文件夹操作 -->
              <template v-if="scope.row.type === 'dir'">
                <el-button type="text" @click="openSubFolder(scope.row)">打开</el-button>
              </template>
              <!-- 文件操作 -->
              <template v-else>
                <el-button type="text" @click="downloadFile(scope.row)">下载</el-button>
                <el-button type="text" @click="previewFile(scope.row)" v-if="isPreviewable(scope.row)">预览</el-button>
              </template>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页组件 -->
        <div class="pagination" v-if="fileTotal > 0">
          <el-pagination v-model:current-page="fileQueryParams.pageNum" v-model:page-size="fileQueryParams.pageSize"
            :page-sizes="[5, 10, 20, 50]" :total="fileTotal" :pager-count="5"
            layout="total, sizes, prev, pager, next, jumper" @size-change="handleFileSizeChange"
            @current-change="handleFileCurrentChange" />
        </div>
      </div>
    </el-dialog>

    <!-- 预览对话框 (Bug 5 修复) -->
    <el-dialog v-model="previewDialogVisible" :title="previewTitle" width="800px" append-to-body>
      <div v-loading="previewLoading" class="preview-container">
        <!-- 图片预览 -->
        <div v-if="previewType === 'image'" style="text-align: center;">
          <img :src="previewContent" style="max-width: 100%; max-height: 500px;" />
        </div>
        <!-- 文本预览 -->
        <div v-else-if="previewType === 'text'">
          <pre
            style="white-space: pre-wrap; word-wrap: break-word; background: #f5f5f5; padding: 10px; max-height: 500px; overflow-y: auto;">
        {{ previewContent }}</pre>
        </div>
        <div v-else>
          <el-empty description="暂不支持该格式预览" />
        </div>
      </div>
    </el-dialog>

  </div>
</template>

<script setup name="Task">
import PageHeader from '@/components/PageHeader/index.vue'
import { listTask, getTask, delTask, addTask, updateTask, executeTask } from "@/api/task/task";
import { listFile, down } from "@/api/file/file";
import { listContainer } from "@/api/container/container";
import { listAlgorithm } from "@/api/container/container";
import { FolderOpened, Plus, Delete, VideoPlay, Loading, Folder, Document, Refresh, Search } from '@element-plus/icons-vue'
import { getCurrentInstance, reactive, ref, toRefs, onUnmounted } from 'vue';
import { parseTime } from '@/utils/ruoyi';

const { proxy } = getCurrentInstance();

// 预览相关变量
const previewDialogVisible = ref(false);
const previewTitle = ref('文件预览');
const previewType = ref('');
const previewContent = ref('');
const previewLoading = ref(false);

const fileSelectionDialogVisible = ref(false);
const currentFolderName = ref('');
const selectedFiles = ref([]);
const fileSelectionSelected = ref([]);
const fileSelectionLoading = ref(false);
const fileSelectionList = ref([]);
const fileSelectionTotal = ref(0);
const fileParamDialogVisible = ref(false);
const fileParamLoading = ref(false);
const fileParamList = ref([]);
const fileParamTotal = ref(0);
const fileSelectionTableRef = ref();
const filePickerTableMaxHeight = ref(520);
const folderTreeRef = ref();
const folderTreeData = ref([]);
const folderTreeLoading = ref(false);
const folderTreeProps = ref({
  label: 'name',
  children: 'children',
  isLeaf: 'isLeaf'
});
const currentFolder = ref(null);
const fileParamCurrentFolder = ref(null);
const fileParamTreeRef = ref();
const fileParamTreeData = ref([]);
const fileParamTreeLoading = ref(false);
const taskList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const title = ref("");
const currentStep = ref(0);
const containerLoading = ref(false);
const algorithmLoading = ref(false);
const fileDialogVisible = ref(false);
const fileLoading = ref(false);
const fileDataList = ref([]);
const fileTotal = ref(0);
const currentFolderId = ref('');
const pollingRetryCounts = ref({});
const pollingIntervals = ref({});
const emptyStateCounts = ref({});
const containers = ref([]);
const algorithms = ref([]);
const containerAlgorithms = ref({});
const pollingStartTimes = ref({});
const algorithmParams = ref([]);
const currentFileParam = ref(null); // 添加遗漏的变量

const fileSelectionQuery = reactive({
  pageNum: 1,
  pageSize: 10,
  name: null,
  root: '0' // 默认根目录
});
const fileParamQuery = reactive({
  pageNum: 1,
  pageSize: 10,
  name: null,
  root: '0'
});
const data = reactive({
  form: {
    id: null,
    name: null,
    container: null,
    algo: null,
    args: null,
    argstr: null,
    params: [],
    file_ids: '',
    remark: null,
    state: null,
    result: null,
    initTime: null,
    endTime: null,
    dept: null,
  },
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    name: null,
    container: null,
    algo: null,
    remark: null,
    state: null,
  },
  fileQueryParams: {
    pageNum: 1,
    pageSize: 10,
    name: null,
    root: null
  },
  rules: {
    name: [
      { required: true, message: "任务名称不能为空", trigger: "blur" }
    ],
    container: [
      { required: true, message: "执行平台不能为空", trigger: "change" }
    ],
    algo: [
      { required: true, message: "算法名称不能为空", trigger: "change" }
    ]
  }
});

const { queryParams, form, rules, fileQueryParams } = toRefs(data);

/** 重置文件列表查询 */
function resetFileQuery() {
  fileQueryParams.value.name = null;
  fileQueryParams.value.pageNum = 1;
  getFileList();
}

/** 打开子文件夹 */
function openSubFolder(folder) {
  if (folder.type !== 'dir') {
    return;
  }

  currentFolderId.value = folder.id;
  currentFolderName.value = `${currentFolderName.value} / ${folder.name}`;

  // 更新查询参数
  fileQueryParams.value.root = folder.id;
  fileQueryParams.value.pageNum = 1;

  getFileList();
}

/** 查询任务列表 */
function getList() {
  loading.value = true;
  listTask(queryParams.value).then(response => {
    taskList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  });
}

/** 加载平台列表 */
function loadContainers() {
  containerLoading.value = true;
  listContainer().then(response => {
    containers.value = response.rows || response.data || [];
    containerLoading.value = false;
  }).catch(() => {
    containerLoading.value = false;
  });
}

/** 加载算法列表 */
function loadAlgorithms(containerId) {
  if (!containerId) return Promise.resolve(); // 修复未返回 Promise 问题
  algorithmLoading.value = true;
  return listAlgorithm(containerId).then(response => {
    if (response && response.data && typeof response.data === 'object') {
      const algorithmsArray = Object.entries(response.data).map(([algo_name, algoInfo]) => {
        const { parameters, parameters_intro, hasValidParams } = validateAndProcessAlgorithmParams(algoInfo);

        return {
          id: algo_name,
          algo_name: algo_name,
          name: algo_name,
          type: '自定义算法',
          version: '1.0',
          intro: algoInfo.intro || '',
          args_intro: algoInfo.args_intro || '{}',
          args: algoInfo.args || '{}',
          container_id: containerId,
          parameters: parameters,
          parameters_intro: parameters_intro,
          hasValidParams: hasValidParams
        };
      });
      containerAlgorithms.value[containerId] = algorithmsArray;
    } else {
      containerAlgorithms.value[containerId] = [];
      console.warn('响应数据格式异常:', response);
    }

    algorithmLoading.value = false;
  }).catch((error) => {
    console.error('获取算法列表失败:', error);
    algorithmLoading.value = false;
  });
}

/** 加载文件夹树 */
function loadFolderTree(node, resolve) {
  if (node.level === 0) {
    // 根节点，通常由 refreshFolderTree 手动加载，或者这里首次加载
    // 如果已经有数据，直接resolve空，防止重复
    if (folderTreeData.value.length > 0) {
      return resolve([]);
    }
    loadRootFolders().then(data => {
      folderTreeData.value = data; // 显式赋值
      resolve(data);
    });
  } else {
    loadChildFolders(node.data.id).then(data => {
      resolve(data);
    });
  }
}

/** 加载文件参数文件夹树 */
function loadFileParamTree(node, resolve) {
  if (node.level === 0) {
    loadRootFolders().then(data => {
      fileParamTreeData.value = data;
      resolve(data);
    });
  } else {
    loadChildFolders(node.data.id).then(data => {
      resolve(data);
    });
  }
}

/** 加载根目录文件夹 (修复 Bug 3: 根目录重复) */
function loadRootFolders() {
  return new Promise((resolve) => {
    const query = {
      pageNum: 1,
      pageSize: 1000,
      type: 'dir',
      root: '0'
    };

    listFile(query).then(response => {
      let data = [];
      if (response.rows) {
        data = response.rows;
      } else if (response.data) {
        data = response.data;
      }
      // 修复根目录判断逻辑：root 为 0, "0", 或 null 都视为根目录
      const folders = data.filter(item => item.type === 'dir' && (item.root == 0 || item.root === '0' || item.root === null));
      const treeData = folders.map(folder => ({
        ...folder,
        isLeaf: false
      }));

      resolve(treeData);
    }).catch(error => {
      console.error('加载根目录失败:', error);
      resolve([]);
    });
  });
}

/** 加载子文件夹 */
function loadChildFolders(parentId) {
  return new Promise((resolve) => {
    const query = {
      pageNum: 1,
      pageSize: 1000,
      type: 'dir',
      root: parentId
    };

    listFile(query).then(response => {
      let data = [];
      if (response.rows) {
        data = response.rows;
      } else if (response.data) {
        data = response.data;
      }

      const folders = data.filter(item => item.type === 'dir');
      const treeData = folders.map(folder => ({
        ...folder,
        isLeaf: false
      }));

      resolve(treeData);
    }).catch(error => {
      console.error('加载子文件夹失败:', error);
      resolve([]);
    });
  });
}

/** 文件夹树节点点击事件 */
function handleFolderTreeNodeClick(data) {
  if (data.type === 'dir') {
    currentFolder.value = data;
    fileSelectionQuery.root = data.id;
    fileSelectionQuery.pageNum = 1;
    loadFileSelectionList();
  }
}

/** 文件参数文件夹树节点点击事件 */
function handleFileParamTreeNodeClick(data) {
  if (data.type === 'dir') {
    fileParamCurrentFolder.value = data;
    fileParamQuery.root = data.id;
    fileParamQuery.pageNum = 1;
    loadFileParamList();
  }
}

/** 刷新文件夹树 */
function refreshFolderTree() {
  folderTreeLoading.value = true;
  // 先清空，避免 lazy loading 导致重复
  folderTreeData.value = [];
  loadRootFolders().then(data => {
    folderTreeData.value = data;
    folderTreeLoading.value = false;
  }).catch(() => {
    folderTreeLoading.value = false;
  });
}

/** 打开文件选择对话框 (修复 Bug 1) */
function openFileSelectionDialog() {
  filePickerTableMaxHeight.value = Math.max(240, Math.min(520, window.innerHeight - 350));
  fileSelectionDialogVisible.value = true;
  fileSelectionSelected.value = []; // 清空临时选择数组

  // 重要：清除表格的选中状态，防止"保存上一次选的状态"
  if (fileSelectionTableRef.value) {
    fileSelectionTableRef.value.clearSelection();
  }

  // 重置根目录查询
  fileSelectionQuery.root = '0';
  fileSelectionQuery.pageNum = 1;
  currentFolder.value = { id: '0', name: '根目录' };

  // 刷新树
  refreshFolderTree();
  // 初始加载文件列表
  loadFileSelectionList();
}

/** 加载文件选择列表 */
function loadFileSelectionList() {
  fileSelectionLoading.value = true;
  const query = {
    ...fileSelectionQuery,
    type: 'image' // 这里原本是image，如果想选所有文件可能需要改
  };

  // 移除 type 限制，除非业务明确只选 image
  // delete query.type; 

  listFile(query).then(response => {
    let data = [];
    if (response.rows) {
      data = response.rows;
    } else if (response.data) {
      data = response.data;
    }
    // 过滤文件夹
    fileSelectionList.value = data.filter(item =>
      item.type !== 'dir' &&
      item.size !== null &&
      item.size > 0
    ).map(file => ({
      ...file,
      folderPath: currentFolder.value ? currentFolder.value.name : '根目录'
    }));

    fileSelectionTotal.value = response.total || fileSelectionList.value.length;
    fileSelectionLoading.value = false;
  }).catch(error => {
    console.error('加载文件列表失败:', error);
    fileSelectionLoading.value = false;
  });
}

/** 文件选择变化 (修复 Bug 2: 跨页/跨文件夹选择) */
function handleFileSelectionChange(selection) {
  // 因为使用了 reserve-selection，selection 包含所有已选的行（跨页/跨文件夹）
  fileSelectionSelected.value = selection;
}

/** 移除文件选择 */
function removeFileSelection(fileId) {
  // 从临时数组中移除
  const index = fileSelectionSelected.value.findIndex(file => file.id === fileId);
  if (index > -1) {
    fileSelectionSelected.value.splice(index, 1);
  }

  // 同步取消表格勾选
  if (fileSelectionTableRef.value) {
    const row = fileSelectionList.value.find(item => item.id === fileId);
    if (row) {
      fileSelectionTableRef.value.toggleRowSelection(row, false);
    } else {
      // 如果当前页找不到该行（在其他文件夹），Element Plus 的 reserve-selection 会自动处理
      // 但我们需要手动更新表格状态（如果它被缓存了）
      // 对于 row-key + reserve-selection，直接操作数据源通常不够，需要操作 selection 数组
      // 上面的 splice 已经移除了数据，但 table 内部状态可能还在
      // 实际上 handleFileSelectionChange 是单向的 Table -> Data
      // 如果要 Data -> Table 反向操作，对于不在当前视图的行比较麻烦
      // 这里简单处理：toggleRowSelection 只能处理当前视图
    }
  }
}

/** 确认文件选择 */
function confirmFileSelection() {
  // 合并到主列表，去重
  const newFiles = fileSelectionSelected.value.filter(newFile =>
    !selectedFiles.value.some(existingFile => existingFile.id === newFile.id)
  );

  selectedFiles.value = [...selectedFiles.value, ...newFiles];
  fileSelectionDialogVisible.value = false;

  proxy.$modal.msgSuccess(`已添加 ${newFiles.length} 个文件`);
}

function removeSelectedFile(fileId) {
  selectedFiles.value = selectedFiles.value.filter(file => file.id !== fileId);
}

/** 打开文件参数选择对话框 */
function openFileParamSelection(param) {
  currentFileParam.value = param;
  fileParamDialogVisible.value = true;
  // 加载树
  if (fileParamTreeData.value.length === 0) {
    loadRootFolders().then(data => {
      fileParamTreeData.value = data;
    });
  }

  fileParamQuery.root = '0';
  fileParamQuery.pageNum = 1;
  fileParamCurrentFolder.value = { id: '0', name: '根目录' };
  loadFileParamList();
}

/** 加载文件参数列表 */
function loadFileParamList() {
  fileParamLoading.value = true;

  const query = {
    ...fileParamQuery,
    type: 'file'
  };

  listFile(query).then(response => {
    let data = [];
    if (response.rows) {
      data = response.rows;
    } else if (response.data) {
      data = response.data;
    }

    fileParamList.value = data.filter(item =>
      item.type !== 'dir' &&
      item.size !== null &&
      item.size > 0
    );

    fileParamTotal.value = response.total || fileParamList.value.length;
    fileParamLoading.value = false;
  }).catch(error => {
    console.error('加载文件参数列表失败:', error);
    fileParamLoading.value = false;
  });
}

/** 选择文件参数 */
function selectFileParam(file) {
  if (currentFileParam.value) {
    currentFileParam.value.value = file.id;
    fileParamDialogVisible.value = false;
    proxy.$modal.msgSuccess(`已选择文件: ${file.name}`);
  }
}

/** 文件参数行点击 */
function handleFileParamRowClick(row) {
  selectFileParam(row);
}

/** 根据文件ID获取文件名 */
function getFileNameById(fileId) {
  const file = selectedFiles.value.find(f => f.id === fileId);
  if (file) return file.name;
  const paramFile = fileParamList.value.find(f => f.id === fileId);
  if (paramFile) return paramFile.name;

  return `文件ID: ${fileId}`;
}

/** 参数类型变化处理 */
function onParamTypeChange(param) {
  if (param.type === 'file') {
    param.value = '';
  }
}
function getParamRules(param) {
  const baseRule = { required: true, message: '参数值不能为空', trigger: 'blur' };

  if (param.type === 'file') {
    return [
      baseRule,
      {
        validator: (rule, value, callback) => {
          if (!value) {
            callback(new Error('请选择文件'));
          } else {
            callback();
          }
        },
        trigger: 'change'
      }
    ];
  }

  return [baseRule];
}

/** 文件选择搜索 */
function handleFileSelectionSearch() {
  fileSelectionQuery.pageNum = 1;
  loadFileSelectionList();
}

/** 重置文件选择查询 */
function resetFileSelectionQuery() {
  fileSelectionQuery.name = null;
  fileSelectionQuery.pageNum = 1;
  loadFileSelectionList();
}

/** 文件选择分页大小改变 */
function handleFileSelectionSizeChange(val) {
  fileSelectionQuery.pageSize = val;
  fileSelectionQuery.pageNum = 1;
  loadFileSelectionList();
}

/** 文件选择当前页改变 */
function handleFileSelectionCurrentChange(val) {
  fileSelectionQuery.pageNum = val;
  loadFileSelectionList();
}

/** 文件参数搜索 */
function handleFileParamSearch() {
  fileParamQuery.pageNum = 1;
  loadFileParamList();
}

/** 重置文件参数查询 */
function resetFileParamQuery() {
  fileParamQuery.name = null;
  fileParamQuery.pageNum = 1;
  loadFileParamList();
}

/** 文件参数分页大小改变 */
function handleFileParamSizeChange(val) {
  fileParamQuery.pageSize = val;
  fileParamQuery.pageNum = 1;
  loadFileParamList();
}

/** 文件参数当前页改变 */
function handleFileParamCurrentChange(val) {
  fileParamQuery.pageNum = val;
  loadFileParamList();
}

/** 准备任务参数*/
function prepareTaskArgs() {
  const argsObject = {
    args: []
  };

  const paramsObj = {};
  form.value.params.forEach(param => {
    if (param.name === 'input' || param.name === 'Input' || param.name === 'INPUT') {
      return;
    }

    if (param.name && param.value !== undefined && param.value !== '') {
      let value = param.value;
      switch (param.type) {
        case 'int':
          value = parseInt(value);
          if (isNaN(value)) value = param.value;
          break;
        case 'float':
          value = parseFloat(value);
          if (isNaN(value)) value = param.value;
          break;
        case 'bool':
          value = value.toLowerCase() === 'true';
          break;
        case 'file':
          value = String(value);
          break;
      }

      paramsObj[param.name] = value;
    }
  });
  if (selectedFiles.value.length > 0) {
    const fileIdArray = selectedFiles.value.map(file => file.id);
    paramsObj['file_ids'] = fileIdArray;
    form.value.file_ids = fileIdArray.join(',');
  }
  argsObject.args.push(paramsObj);
  return {
    args: JSON.stringify(argsObject),
    argstr: JSON.stringify(paramsObj)
  };
}

/** 重置 */
function reset() {
  form.value = {
    id: null,
    name: null,
    container: null,
    algo: null,
    args: null,
    argstr: null,
    params: [],
    file_ids: '',
    remark: null,
    state: null,
    result: null,
    initTime: null,
    endTime: null,
    dept: null,
  };
  selectedFiles.value = [];
  algorithmParams.value = [];
  proxy.resetForm("taskRef");
  currentStep.value = 0;
}


/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const _id = row.id || ids.value;
  getTask(_id).then(response => {
    form.value = response.data;
    if (form.value.args && typeof form.value.args === 'string') {
      try {
        const parsedArgs = JSON.parse(form.value.args);
        if (parsedArgs.args && Array.isArray(parsedArgs.args) && parsedArgs.args.length > 0) {
          const firstArgObj = parsedArgs.args[0];
          if (firstArgObj.file_ids && Array.isArray(firstArgObj.file_ids)) {
            selectedFiles.value = firstArgObj.file_ids.map(id => ({
              id: id,
              name: `文件ID: ${id}`,
              size: 0
            }));
          }

          form.value.params = Object.entries(firstArgObj)
            .filter(([key]) => key !== 'file_ids' && key !== 'input' && key !== 'Input' && key !== 'INPUT')
            .map(([name, value]) => {
              const isFileId = typeof value === 'string' && value.length > 0 && !isNaN(value);

              return {
                name,
                type: isFileId ? 'file' : getParamType(value),
                value: String(value)
              };
            });
        } else {
          form.value.params = Object.entries(parsedArgs)
            .filter(([key]) => key !== 'input' && key !== 'Input' && key !== 'INPUT')
            .map(([name, value]) => {
              return {
                name,
                type: getParamType(value),
                value: String(value)
              };
            });
        }
      } catch (e) {
        console.error('解析任务参数失败:', e);
        form.value.params = [];
      }
    }

    open.value = true;
    title.value = "修改任务";
    currentStep.value = 3;
    loadContainers();
    if (form.value.container) {
      loadAlgorithms(form.value.container).then(() => {
        if (form.value.algo) {
          onAlgorithmSelect(true);
        }
      });
    }
  });
}

/** 执行任务 */
function handleExecute(row) {
  if (['queued', 'running'].includes(row.state)) {
    proxy.$modal.msgWarning('任务已排队或正在执行，请勿重复提交');
    return;
  }

  const previousState = row.state;
  const previousResult = row.result;

  proxy.$modal.confirm('确认要执行任务 "' + row.name + '" 吗？').then(function () {
    const taskIndex = taskList.value.findIndex(item => item.id === row.id);
    if (taskIndex !== -1) {
      taskList.value[taskIndex].state = 'running';
      taskList.value[taskIndex].result = null;
    }
    return executeTask(row.id);
  }).then((response) => {
    if (response.code === 200) {
      proxy.$modal.msgSuccess("任务开始执行");
      setTimeout(() => {
        startPollingTaskStatus(row.id);
      }, 3000);

    } else {
      proxy.$modal.msgError("任务执行失败: " + (response.msg || '未知错误'));
      const taskIndex = taskList.value.findIndex(item => item.id === row.id);
      if (taskIndex !== -1) {
        taskList.value[taskIndex].state = previousState;
        taskList.value[taskIndex].result = previousResult;
      }
    }
  }).catch((error) => {
    if (error === 'cancel' || error === 'close') return;
    const taskIndex = taskList.value.findIndex(item => item.id === row.id);
    if (taskIndex !== -1) {
      taskList.value[taskIndex].state = previousState;
      taskList.value[taskIndex].result = previousResult;
    }
    proxy.$modal.msgError("任务提交失败，请刷新确认最新状态");
  });
}

/** 轮询任务状态 */
function startPollingTaskStatus(taskId) {
  pollingStartTimes.value[taskId] = Date.now();
  pollingRetryCounts.value[taskId] = 0;
  emptyStateCounts.value[taskId] = 0;
  if (pollingIntervals.value[taskId]) {
    clearInterval(pollingIntervals.value[taskId]);
    delete pollingIntervals.value[taskId];
  }
  const forceStopTimer = setTimeout(() => {
    stopPollingTaskStatus(taskId);
    const taskIndex = taskList.value.findIndex(item => item.id === taskId);
    if (taskIndex !== -1) {
      taskList.value[taskIndex].state = 'unknown';
    }
    proxy.$modal.msgWarning('任务执行超时，状态未知');
  }, 5 * 60 * 6000);
  pollingIntervals.value[taskId] = {
    interval: null,
    forceStop: forceStopTimer
  };
  updateTaskStatus(taskId);
  pollingIntervals.value[taskId].interval = setInterval(() => {
    updateTaskStatus(taskId);
  }, 5000);
}

/** 轮询任务状态 */
async function updateTaskStatus(taskId) {
  try {
    const taskResponse = await getTask(taskId);
    const task = taskResponse.data;
    pollingRetryCounts.value[taskId] = (pollingRetryCounts.value[taskId] || 0) + 1;
    const taskIndex = taskList.value.findIndex(item => item.id === taskId);
    if (taskIndex !== -1) {
      taskList.value[taskIndex] = {
        ...taskList.value[taskIndex],
        state: task.state || 'unknown',
        result: task.result,
        endTime: task.endTime
      };
    }

    const maxTotalRetries = 120;
    const hasValidResult = task.result && task.result !== 'null' && task.result !== 'None';

    if (task.state === 'completed' || task.state === 'success' || hasValidResult) {
      stopPollingTaskStatus(taskId);
      proxy.$message.success(`任务 "${task.name}" 执行完成`);
    }
    else if (task.state === 'failed') {
      stopPollingTaskStatus(taskId);
      proxy.$message.error(`任务 "${task.name}" 执行失败`);
    }
    else if (pollingRetryCounts.value[taskId] >= maxTotalRetries) {
      stopPollingTaskStatus(taskId);
    }
  } catch (error) {
    console.error('获取任务状态失败:', error);
  }
}

/** 停止轮询任务状态 */
function stopPollingTaskStatus(taskId) {
  if (pollingIntervals.value[taskId]) {
    if (pollingIntervals.value[taskId].interval) {
      clearInterval(pollingIntervals.value[taskId].interval);
    }
    if (pollingIntervals.value[taskId].forceStop) {
      clearTimeout(pollingIntervals.value[taskId].forceStop);
    }
    delete pollingIntervals.value[taskId];
  }
  if (pollingStartTimes.value[taskId]) {
    delete pollingStartTimes.value[taskId];
  }
}


// 组件卸载时清除所有轮询
onUnmounted(() => {
  Object.values(pollingIntervals.value).forEach(interval => {
    if (interval.interval) clearInterval(interval.interval);
    if (interval.forceStop) clearTimeout(interval.forceStop);
  });
  pollingIntervals.value = {};
});

function openResultFolder(folderId, taskName = '') {
  if (!folderId || folderId === 'null' || folderId === 'None') {
    proxy.$modal.msgWarning('该任务暂无结果');
    return;
  }

  const actualFolderId = String(folderId).trim();
  if (!actualFolderId || actualFolderId === '0') {
    proxy.$modal.msgWarning('无效的文件夹ID');
    return;
  }

  currentFolderId.value = actualFolderId;
  currentFolderName.value = taskName ? `任务结果 - ${taskName}` : `任务结果 - 文件夹ID: ${actualFolderId}`;

  // 重置分页参数
  fileQueryParams.value.pageNum = 1;
  fileQueryParams.value.pageSize = 10;
  fileQueryParams.value.name = null;
  fileQueryParams.value.root = actualFolderId;

  getFileList();
  fileDialogVisible.value = true;
}


/** 获取文件列表 (修复 Bug 4: 移除前端过滤) */
function getFileList() {
  fileLoading.value = true;

  const query = {
    pageNum: fileQueryParams.value.pageNum,
    pageSize: fileQueryParams.value.pageSize,
    name: fileQueryParams.value.name || undefined,
    root: fileQueryParams.value.root
  };

  listFile(query).then(response => {
    let data = [];
    let total = 0;

    if (response.rows) {
      data = response.rows;
      total = response.total;
    } else if (response.data) {
      data = response.data;
      total = response.total;
    } else if (Array.isArray(response)) {
      data = response;
      total = data.length;
    }

    // 修复 Bug 4: 不在前端进行 root 过滤，假设后端已正确处理分页和筛选
    // 如果后端不支持筛选，分页肯定有问题，这是后端逻辑
    fileDataList.value = data;
    fileTotal.value = total;
    fileLoading.value = false;

  }).catch((error) => {
    console.error('获取文件列表失败:', error);
    fileLoading.value = false;
    proxy.$modal.msgError('获取文件列表失败: ' + (error.message || '未知错误'));
  });
}


/** 取消按钮 */
function cancel() {
  open.value = false;
  reset();
  currentStep.value = 0;
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

/** 新增按钮操作 */
function handleAdd() {
  reset();
  open.value = true;
  title.value = "添加任务";
  currentStep.value = 0;
  // 加载平台列表
  loadContainers();
}


/** 平台变更处理 */
function onContainerChange() {
  form.value.algo = null;
  algorithmParams.value = [];
  form.value.params = [];
  loadAlgorithms(form.value.container);
}

/** 算法选择后的处理  */
function onAlgorithmSelect(preserveValues = false) {
  if (!form.value.container || !form.value.algo) return;
  const algoList = containerAlgorithms.value[form.value.container] || [];
  const selectedAlgo = algoList.find(algo => algo.name === form.value.algo);
  if (selectedAlgo) {
    algorithmParams.value = [];
    if (selectedAlgo.parameters && Object.keys(selectedAlgo.parameters).length > 0) {
      algorithmParams.value = Object.entries(selectedAlgo.parameters).map(([name, defaultValue]) => {
        const intro = selectedAlgo.parameters_intro && selectedAlgo.parameters_intro[name]
          ? selectedAlgo.parameters_intro[name]
          : '暂无说明';
        return {
          name,
          default: defaultValue,
          intro
        };
      });
      if (preserveValues !== true) form.value.params = Object.entries(selectedAlgo.parameters)
        .filter(([name]) => name !== 'input' && name !== 'Input' && name !== 'INPUT')
        .map(([name, defaultValue]) => {
          return {
            name,
            type: getParamType(defaultValue),
            value: String(defaultValue)
          };
        });
    } else {
      algorithmParams.value = [];
      if (preserveValues !== true) form.value.params = [];
    }
  } else {
    algorithmParams.value = [];
    if (preserveValues !== true) form.value.params = [];
  }
}
/** 根据默认值推断参数类型  */
function getParamType(value) {
  if (value === null || value === undefined) return 'string';
  if (typeof value === 'boolean') return 'bool';
  if (Number.isInteger(value)) return 'int';
  if (typeof value === 'number') return 'float';
  if (typeof value === 'string') {
    if (value.toLowerCase() === 'true' || value.toLowerCase() === 'false') return 'bool';
    if (!isNaN(value) && value.trim() !== '') return 'float';
    return 'string';
  }
  return 'string';
}

/** 添加参数 */
function addParameter() {
  form.value.params.push({
    name: '',
    type: 'string',
    value: ''
  });
}

/** 删除参数 */
function removeParameter(index) {
  form.value.params.splice(index, 1);
}

/** 验证任务参数  */
function validateTaskArgs() {
  const paramNames = form.value.params.map(param => param.name);
  const uniqueNames = new Set(paramNames);
  if (uniqueNames.size !== paramNames.length) {
    proxy.$modal.msgError("参数名称不能重复");
    return false;
  }

  for (let i = 0; i < form.value.params.length; i++) {
    const param = form.value.params[i];

    if (!param.name || param.name.trim() === '') {
      proxy.$modal.msgError(`参数 ${i + 1} 的名称不能为空`);
      return false;
    }

    if (param.name === 'input' || param.name === 'Input' || param.name === 'INPUT') {
      continue;
    }

    if (param.value === undefined || param.value === '') {
      proxy.$modal.msgError(`参数 "${param.name}" 的值不能为空`);
      return false;
    }

    if (param.type === 'int' || param.type === 'float') {
      const numValue = parseFloat(param.value);
      if (isNaN(numValue)) {
        proxy.$modal.msgError(`参数 "${param.name}" 必须是有效的数字`);
        return false;
      }
    }

    if (param.type === 'bool') {
      const lowerValue = param.value.toLowerCase();
      if (lowerValue !== 'true' && lowerValue !== 'false') {
        proxy.$modal.msgError(`参数 "${param.name}" 必须是 true 或 false`);
        return false;
      }
    }
  }

  return true;
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["taskRef"].validate(valid => {
    if (valid) {

      if (!validateTaskArgs()) {
        return;
      }

      const taskParams = prepareTaskArgs();
      form.value.args = taskParams.args;
      form.value.argstr = taskParams.argstr;
      if (form.value.id != null) {
        updateTask(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        }).catch(error => {
          console.error('更新任务失败:', error);
          proxy.$modal.msgError("更新任务失败: " + (error.message || '未知错误'));
        });
      } else {
        addTask(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          open.value = false;
          getList();
        }).catch(error => {
          console.error('新增任务失败:', error);
          proxy.$modal.msgError("新增任务失败: " + (error.message || '未知错误'));
        });
      }
    }
  });
}

/** 删除按钮操作 */
function handleDelete(row) {
  const _ids = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除任务编号为"' + _ids + '"的数据项？').then(function () {
    return delTask(_ids);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => { });
}

/** 获取平台名称 */
function getContainerName(containerId) {
  const container = containers.value.find(c => c.id === containerId);
  return container ? container.name : `平台 ${containerId}`;
}

function getStatusText(status, result) {
  if (result && result !== 'null' && result !== 'None') {
    return '已完成';
  }
  if (!status || status === 'null' || status === 'None') {
    return '状态未知';
  }

  const statusMap = {
    'pending': '等待中',
    'running': '运行中',
    'completed': '已完成',
    'success': '已完成',
    'queued': '排队中',
    'failed': '失败',
    'unknown': '状态未知',
    'error': '查询错误'
  };
  return statusMap[status] || status || '状态未知';
}

function getStatusType(status, result) {
  if (result && result !== 'null' && result !== 'None') {
    return 'success';
  }
  if (!status || status === 'null' || status === 'None') {
    return 'warning';
  }
  const typeMap = {
    'pending': 'warning',
    'running': 'primary',
    'completed': 'success',
    'success': 'success',
    'queued': 'warning',
    'failed': 'danger',
    'unknown': 'warning',
    'error': 'danger'
  };
  return typeMap[status] || 'info';
}

/** 格式化参数显示 */
function formatArgs(args) {
  if (!args) return '无参数';
  try {
    const parsed = JSON.parse(args);
    return JSON.stringify(parsed, null, 2);
  } catch (e) {
    return args;
  }
}

/** 根据参数类型获取占位符文本 */
function getParamPlaceholder(type) {
  const placeholderMap = {
    'string': '请输入字符串',
    'int': '请输入整数',
    'float': '请输入浮点数',
    'bool': 'true 或 false'
  };
  return placeholderMap[type] || '请输入值';
}


/** 文件列表搜索 */
function handleFileQuery() {
  fileQueryParams.value.pageNum = 1;
  getFileList();
}


/** 文件列表分页大小改变 */
function handleFileSizeChange(val) {
  fileQueryParams.value.pageSize = val;
  fileQueryParams.value.pageNum = 1;
  getFileList();
}

/** 文件列表当前页改变 */
function handleFileCurrentChange(val) {
  fileQueryParams.value.pageNum = val;
  getFileList();
}

/** 文件对话框关闭处理 */
function handleFileDialogClose() {
  fileDataList.value = [];
  fileTotal.value = 0;
  currentFolderId.value = '';
  currentFolderName.value = '';

  // 重置查询参数
  fileQueryParams.value.pageNum = 1;
  fileQueryParams.value.pageSize = 10;
  fileQueryParams.value.name = null;
  fileQueryParams.value.root = null;
}


/** 格式化文件大小 */
function formatFileSize(size) {
  if (!size && size !== 0) return '-';

  if (size < 1024) {
    return size + ' B';
  } else if (size < 1024 * 1024) {
    return (size / 1024).toFixed(2) + ' KB';
  } else if (size < 1024 * 1024 * 1024) {
    return (size / (1024 * 1024)).toFixed(2) + ' MB';
  } else {
    return (size / (1024 * 1024 * 1024)).toFixed(2) + ' GB';
  }
}

/** 下载文件 */
async function downloadFile(file) {
  try {
    if (!file || !file.id) {
      proxy.$modal.msgError("无法获取文件信息");
      return;
    }

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
/** 验证并处理算法参数 */
function validateAndProcessAlgorithmParams(algoInfo) {
  const result = {
    parameters: {},
    parameters_intro: {},
    hasValidParams: false
  };

  try {
    if (algoInfo.args && typeof algoInfo.args === 'string') {
      if (algoInfo.args.trim().startsWith('{') || algoInfo.args.trim().startsWith('[')) {
        result.parameters = JSON.parse(algoInfo.args);
        result.hasValidParams = true;
      } else {
        result.parameters = {
          input: 'default'
        };
        result.parameters_intro = {
          input: algoInfo.args || '算法输入参数'
        };
      }
    }
  } catch (e) {
    console.warn('参数解析失败，使用默认参数:', e.message);
    result.parameters = {
      input: 'default'
    };
    result.parameters_intro = {
      input: '算法输入参数'
    };
  }

  try {
    const parameterIntro = algoInfo.args_intro || algoInfo.intro;
    if (parameterIntro && typeof parameterIntro === 'string') {
      if (parameterIntro.trim().startsWith('{')) {
        result.parameters_intro = JSON.parse(parameterIntro);
      } else {
        Object.keys(result.parameters).forEach(key => {
          result.parameters_intro[key] = parameterIntro;
        });
      }
    }
  } catch (e) {
    console.warn('参数说明解析失败:', e.message);
  }

  return result;
}

/** 预览文件 (Bug 5 修复) */
async function previewFile(file) {
  if (!isPreviewable(file)) {
    proxy.$message.warning('该文件类型暂不支持预览');
    return;
  }

  previewLoading.value = true;
  previewDialogVisible.value = true;
  previewTitle.value = `预览: ${file.name}`;
  previewContent.value = '';

  const ext = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();

  try {
    const blobData = await down(file.id);
    if (!blobData || blobData.size === 0) {
      throw new Error('文件内容为空');
    }

    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg'].includes(ext)) {
      previewType.value = 'image';
      previewContent.value = window.URL.createObjectURL(blobData);
    } else if (['.txt', '.json', '.xml', '.log', '.md', '.py', '.js', '.java', '.c', '.cpp', '.h'].includes(ext)) {
      previewType.value = 'text';
      const text = await blobData.text();
      previewContent.value = text;
    } else {
      previewType.value = 'unknown';
    }

  } catch (error) {
    console.error('预览失败:', error);
    proxy.$message.error('预览加载失败');
    previewDialogVisible.value = false;
  } finally {
    previewLoading.value = false;
  }
}

function isPreviewable(file) {
  const previewableTypes = [
    // 图片
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg',
    // 文本
    '.txt', '.json', '.xml', '.log', '.md', '.py', '.js', '.java', '.c', '.cpp', '.h'
  ];
  if (!file || !file.name) return false;
  const ext = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();
  return previewableTypes.includes(ext);
}

// 初始化加载任务列表
loadContainers();
getList();
</script>

<style scoped>
.file-selection-dialog .file-list-panel {
  height: auto;
  min-height: 500px;
}

.file-selection-dialog :deep(.el-table) {
  flex-shrink: 0;
}

.file-selection-summary {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 6px 12px;
  padding: 10px 0;
  color: #606266;
  font-size: 13px;
}
/* 分页样式 */
.pagination {
  margin-top: 15px;
  display: flex;
  justify-content: center;
}

/* 文件列表空状态样式 */
:deep(.el-empty__description) {
  color: #909399;
}

/* 表格样式优化 */
:deep(.el-table) {
  margin-top: 10px;
}

:deep(.el-table .cell) {
  word-break: break-word;
}

.folder-tree-panel {
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  background-color: #fff;
  height: 500px;
  display: flex;
  flex-direction: column;
}

.file-list-panel {
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  background-color: #fff;
  height: 500px;
  display: flex;
  flex-direction: column;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #e0e0e0;
  background-color: #f5f7fa;
}

.panel-header h4 {
  margin: 0;
  color: #409eff;
}

.current-folder {
  color: #606266;
  font-size: 14px;
  font-weight: normal;
}

.tree-container {
  flex: 1;
  overflow-y: auto;
  padding: 10px;
}

.custom-tree-node {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

:deep(.el-tree-node__content) {
  height: 36px;
}

:deep(.el-tree-node__expand-icon) {
  color: #409eff;
}

:deep(.el-tree-node:focus > .el-tree-node__content) {
  background-color: #f0f7ff;
}

.dialog-footer {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #e0e0e0;
}

.selected-info {
  flex: 1;
}

.selected-preview {
  margin-top: 8px;
  max-width: 400px;
}

.more-files {
  color: #909399;
  font-size: 12px;
}

/* 原有样式保持不变 */
.file-selection-container {
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 15px;
  width: 400px
}

.file-selection-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.file-selection-title {
  font-weight: bold;
  font-size: 16px;
}

.selected-files-list {
  max-height: 300px;
  overflow-y: auto;
  margin-bottom: 15px;
}

.selected-file-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  margin-bottom: 8px;
  background-color: #fafafa;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.file-name {
  font-weight: 500;
}

.file-size {
  color: #909399;
  font-size: 12px;
}

.selected-count {
  text-align: center;
  color: #409eff;
  font-weight: 500;
  padding: 10px;
  background-color: #f0f9ff;
  border-radius: 4px;
}

.no-files-tip {
  text-align: center;
  padding: 20px;
  color: #909399;
}

.file-param-input {
  display: flex;
  align-items: center;
}

.file-param-info {
  margin-top: 8px;
}

.step-actions {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin-top: 20px;
}

.pagination {
  margin-top: 15px;
  text-align: right;
}

.param-container {
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 15px;
}

.param-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 1px solid #e0e0e0;
}

.param-title {
  font-weight: bold;
}

.algorithm-params-info {
  background-color: #f5f7fa;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 15px;
  margin-bottom: 15px;
}

.algorithm-params-info h4 {
  margin: 0 0 10px 0;
  color: #409eff;
}

.param-info-item {
  margin-bottom: 8px;
  padding: 5px 0;
}

.param-name {
  font-weight: bold;
  color: #606266;
  margin-right: 8px;
}

.param-intro {
  color: #909399;
  margin-right: 8px;
}

.param-default {
  color: #e6a23c;
  font-size: 0.9em;
}

.param-item {
  margin-bottom: 15px;
  padding: 15px;
  background-color: #fafafa;
  border-radius: 4px;
  border: 1px solid #f0f0f0;
}

.param-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  font-weight: bold;
}

.no-params-tip {
  color: #909399;
  font-style: italic;
  padding: 8px 0;
}

.preview-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
}
</style>
