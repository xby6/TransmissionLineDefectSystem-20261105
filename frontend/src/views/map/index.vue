<template>
<div class="dashboard-container">
  <!-- 左侧地图区域 -->
  <div class="map-container">
    <!-- 地图标题 -->
    <div class="map-header">
      <div class="header-left">
        <div class="title-icon">
          <img src="@/assets/logo/grid-mark.svg" class="title-img">
        </div>
        <div class="header-content">
          <h2 class="map-title">输电线路监测</h2>
          <p class="map-subtitle">节点定位 · 关联图像 · 运行状态</p>
        </div>
      </div>
      <div class="header-right">
        <div class="time-display">{{ currentTime }}</div>
        <div class="status-indicator">
          <span class="indicator-dot online"></span>
          <span class="indicator-text">系统在线</span>
        </div>
      </div>
    </div>
    
    <!-- 地图 -->
    <div id="map" class="map"></div>
    
    <!-- 图例 -->
    <div class="map-legend">
      <div class="legend-header">
        <div class="legend-icon">
          <i class="el-icon-legend"></i>
        </div>
      </div>
      <div class="legend-items">
        <div class="legend-item" v-for="(text, status) in statusText" :key="status">
          <div class="legend-dot-wrapper">
            <span 
              class="legend-dot" 
              :style="{ backgroundColor: statusColors[status] }"
            ></span>
            <span class="legend-pulse" :style="{ backgroundColor: statusColors[status] }"></span>
          </div>
          <span class="legend-text">{{ text }}</span>
        </div>
      </div>
    </div>
  </div>

  <!-- 右侧图表容器 -->
  <div class="right-charts">
    <!-- 控制按钮区域 -->
    <div class="control-section">
      <div class="section-header">
        <div class="section-icon">
          <i class="el-icon-setting"></i>
        </div>
        <div class="section-title">
          <h3>系统控制</h3>
          <p>线路管理与数据刷新</p>
        </div>
      </div>
      <div class="control-buttons">
        <button class="btn-tech btn-primary" @click="showAllLines">
          <div class="btn-icon">
            <i class="el-icon-s-promotion"></i>
          </div>
          <span class="btn-text">显示所有线路</span>
          <div class="btn-glow"></div>
        </button>
        <button class="btn-tech btn-secondary" @click="clearAllLines">
          <div class="btn-icon">
            <i class="el-icon-delete"></i>
          </div>
          <span class="btn-text">清除显示</span>
          <div class="btn-glow"></div>
        </button>
        <button class="btn-tech btn-refresh" @click="refreshData">
          <div class="btn-icon">
            <i class="el-icon-refresh"></i>
          </div>
          <span class="btn-text">刷新数据</span>
          <div class="btn-glow"></div>
        </button>
      </div>
    </div>
    
    <!-- 统计卡片区域 -->
    <div class="stats-section">
      <div class="section-header">
        <div class="section-icon">
          <i class="el-icon-data-analysis"></i>
        </div>
        <div class="section-title">
          <h3>系统概览</h3>
          <p>实时监控数据统计</p>
        </div>
      </div>
      <div class="stats-cards">
        <div class="stats-row">
          <div class="grid-content card-tech">
            <div class="card-corner"></div>
            <div class="card-glow"></div>
            <div class="card-inner">
              <div class="card-header">
                <div class="icon-wrapper bg-blue-glow">
                  <div class="icon-glow"></div>
                  <i class="el-icon-monitor"></i>
                </div>
                <div class="card-title">节点总数</div>
              </div>
              <div class="card-body">
                <div class="card-number">{{ statisticsData.node_total || 0 }}</div>
                <div class="card-progress">
                  <div class="progress-info">
                    <span class="progress-label">在线率</span>
                    <span class="progress-value">{{ getPercentage(statisticsData.node_online, statisticsData.node_total) }}%</span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill" :style="{ width: getPercentage(statisticsData.node_online, statisticsData.node_total) + '%' }"></div>
                    <div class="progress-track"></div>
                  </div>
                  <div class="progress-stats">
                    <span class="text-success">在线: {{ statisticsData.node_online || 0 }}</span>
                    <span class="text-muted">离线: {{ statisticsData.node_total - statisticsData.node_online || 0 }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="grid-content card-tech">
            <div class="card-corner"></div>
            <div class="card-glow"></div>
            <div class="card-inner">
              <div class="card-header">
                <div class="icon-wrapper bg-green-glow">
                  <div class="icon-glow"></div>
                  <i class="el-icon-document"></i>
                </div>
                <div class="card-title">文件总数</div>
              </div>
              <div class="card-body">
                <div class="card-number">{{ statisticsData.file_total || 0 }}</div>
                <div class="card-progress">
                  <div class="progress-info">
                    <span class="progress-label">图像占比</span>
                    <span class="progress-value">{{ getPercentage(statisticsData.file_processed, statisticsData.file_total) }}%</span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill" :style="{ width: getPercentage(statisticsData.file_processed, statisticsData.file_total) + '%' }"></div>
                    <div class="progress-track"></div>
                  </div>
                  <div class="progress-stats">
                    <span class="text-success">图像文件: {{ statisticsData.file_processed || 0 }}</span>
                    <span class="text-muted">其他文件: {{ statisticsData.file_total - statisticsData.file_processed || 0 }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="stats-row">
          <div class="grid-content card-tech">
            <div class="card-corner"></div>
            <div class="card-glow"></div>
            <div class="card-inner">
              <div class="card-header">
                <div class="icon-wrapper bg-orange-glow">
                  <div class="icon-glow"></div>
                  <i class="el-icon-s-data"></i>
                </div>
                <div class="card-title">任务总数</div>
              </div>
              <div class="card-body">
                <div class="card-number">{{ statisticsData.task_total || 0 }}</div>
                <div class="card-progress">
                  <div class="progress-info">
                    <span class="progress-label">运行率</span>
                    <span class="progress-value">{{ getPercentage(statisticsData.task_running, statisticsData.task_total) }}%</span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill" :style="{ width: getPercentage(statisticsData.task_running, statisticsData.task_total) + '%' }"></div>
                    <div class="progress-track"></div>
                  </div>
                  <div class="progress-stats">
                    <span class="text-success">运行中: {{ statisticsData.task_running || 0 }}</span>
                    <span class="text-muted">其他: {{ statisticsData.task_total - statisticsData.task_running || 0 }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="grid-content card-tech">
            <div class="card-corner"></div>
            <div class="card-glow"></div>
            <div class="card-inner">
              <div class="card-header">
                <div class="icon-wrapper bg-purple-glow">
                  <div class="icon-glow"></div>
                  <i class="el-icon-box"></i>
                </div>
                <div class="card-title">容器总数</div>
              </div>
              <div class="card-body">
                <div class="card-number">{{ statisticsData.container_total || 0 }}</div>
                <div class="card-progress">
                  <div class="progress-info">
                    <span class="progress-label">运行率</span>
                    <span class="progress-value">{{ getPercentage(statisticsData.container_running, statisticsData.container_total) }}%</span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill" :style="{ width: getPercentage(statisticsData.container_running, statisticsData.container_total) + '%' }"></div>
                    <div class="progress-track"></div>
                  </div>
                  <div class="progress-stats">
                    <span class="text-success">运行中: {{ statisticsData.container_running || 0 }}</span>
                    <span class="text-muted">停止: {{ statisticsData.container_total - statisticsData.container_running || 0 }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
   
    <!-- 饼图：文件类型分布 -->
    <div class="chart-section">
      <div class="section-header">
        <div class="section-icon">
          <i class="el-icon-data-board"></i>
        </div>
        <div class="section-title">
          <h3>文件类型分布</h3>
          <p>各类文件占比分析</p>
        </div>
      </div>
      <div class="chart-wrapper">
        <div class="chart-box" ref="fileTypeChart"></div>
      </div>
    </div>
  </div>
</div>
</template>

<script>
import { onMounted, onBeforeUnmount, ref, computed, nextTick } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { listNode } from '@/api/node/node'
import { getAllStatistics } from '@/api/statistics/statistics'
import { listFile } from '@/api/file/file'  // 根据文件夹ID获取文件列表
import { down } from '@/api/file/file'      // 根据文件ID下载文件
import * as echarts from 'echarts'


delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
})

export default {
  name: 'DandongMapWithCharts',
  setup() {
    // 响应式数据
    const loading = ref(false)
    const statisticsData = ref({})
    const rawStatisticsData = ref({})
    const currentTime = ref('')
    
    // 图表DOM引用
    const nodeStatusChart = ref(null)
    const fileTypeChart = ref(null)
    let charts = []
    
    // 状态颜色映射
    const statusColors = {
      completed: '#60C2D4',  // 青色
      running: '#00CCFF',    // 亮蓝色
      pending: '#FEDB5C',    // 黄色
      abnormal: '#FF6B8B',   // 粉色
    }

    // 状态文字映射
    const statusText = {
      completed: '已完成',
      running: '进行中',
      pending: '待处理',
      abnormal: '异常',
    }

    // 线路数据 - 初始为空，从后端加载
    const linesData = ref([])
    
    // 缓存已加载的图片数据
    const imageCache = ref(new Map())

    // 计算属性 - 所有线路
    const allLines = computed(() => {
      return linesData.value
    })

    // 获取百分比
    const getPercentage = (part, total) => {
      if (!total || total === 0) return 0
      return Math.round((part / total) * 100)
    }

    // 更新时间显示
    const updateTime = () => {
      const now = new Date()
      currentTime.value = now.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
      })
    }

    // 将节点坐标调整为直线排列
const alignNodesToLine = (towers) => {
  if (towers.length <= 2) return towers; // 少于3个点，不需要调整
  
  // 提取所有节点的经纬度
  const lats = towers.map(t => t.coordinates[0]);
  const lngs = towers.map(t => t.coordinates[1]);
  
  // 计算经纬度的最小最大值
  const minLat = Math.min(...lats);
  const maxLat = Math.max(...lats);
  const minLng = Math.min(...lngs);
  const maxLng = Math.max(...lngs);
  
  // 判断是南北走向还是东西走向
  const latRange = maxLat - minLat;
  const lngRange = maxLng - minLng;
  
  // 如果经度范围更大，说明是东西走向（水平线）
  if (lngRange > latRange) {
    // 东西走向：纬度相同，经度线性变化
    const avgLat = (minLat + maxLat) / 2;
    return towers.map((tower, index) => {
      // 按经度排序
      const sortedTowers = [...towers].sort((a, b) => a.coordinates[1] - b.coordinates[1]);
      const sortedIndex = sortedTowers.findIndex(t => t.id === tower.id);
      
      // 计算线性插值
      const ratio = sortedTowers.length > 1 ? sortedIndex / (sortedTowers.length - 1) : 0.5;
      const newLng = minLng + ratio * lngRange;
      
      return {
        ...tower,
        coordinates: [avgLat, newLng]
      };
    });
  } else {
    // 南北走向：经度相同，纬度线性变化
    const avgLng = (minLng + maxLng) / 2;
    return towers.map((tower, index) => {
      // 按纬度排序
      const sortedTowers = [...towers].sort((a, b) => a.coordinates[0] - b.coordinates[0]);
      const sortedIndex = sortedTowers.findIndex(t => t.id === tower.id);
      
      // 计算线性插值
      const ratio = sortedTowers.length > 1 ? sortedIndex / (sortedTowers.length - 1) : 0.5;
      const newLat = minLat + ratio * latRange;
      
      return {
        ...tower,
        coordinates: [newLat, avgLng]
      };
    });
  }
};


    // 获取统计数据
    const fetchStatistics = async () => {
      try {
        const res = await getAllStatistics()
        console.log('统计API响应:', res)

        // 解析逻辑：根据实际响应数据结构进行解析
        let finalData = null
        
        // 根据您提供的实际响应数据，res应该包含code、msg、data等字段
        if (res && res.data && typeof res.data === 'object') {
          // 标准结构，res.data包含统计数据
          finalData = res.data
        } else if (res && res.tasks) {
          // 如果res直接包含tasks，说明已经是解包后的数据
          finalData = res
        }
        
        if (!finalData) {
          console.warn('收到响应但数据格式不匹配，无法解析:', res)
          return
        }

        rawStatisticsData.value = finalData
        
        // 将后端数据映射到前端变量
        statisticsData.value = {
          // 1. 任务
          task_total: finalData.tasks?.total || 0,
          task_running: getCount(finalData.tasks?.by_status, 'status', 'running'),
          task_completed: getCount(finalData.tasks?.by_status, 'status', 'completed') || getCount(finalData.tasks?.by_status, 'status', 'success'),
          task_failed: getCount(finalData.tasks?.by_status, 'status', 'failed'),
          
          // 2. 文件
          file_total: finalData.files?.total || 0,
          file_processed: finalData.files?.image_total || 0,
          
          // 3. 容器
          container_total: finalData.containers?.total || 0,
          container_running: getCount(finalData.containers?.by_status, 'status', 'running'),
          container_stopped: getCount(finalData.containers?.by_status, 'status', 'stopped') || getCount(finalData.containers?.by_status, 'status', 'exited'),
          
          // 4. 节点
          node_total: finalData.nodes?.total || 0,
          node_online: getCount(finalData.nodes?.by_status, 'status', 'online') || getCount(finalData.nodes?.by_status, 'status', '健康')
        }

        console.log('解析后的展示数据:', statisticsData.value)
        
        // 初始化图表
        nextTick(() => {
          initCharts()
        })
        
      } catch (error) {
        console.error('获取统计数据失败:', error)
      }
    }

    // 忽略大小写匹配统计数量
    const getCount = (list, keyName, value) => {
      if (!list || !Array.isArray(list)) return 0
      const valStr = String(value).toLowerCase()
      const target = list.find(item => String(item[keyName]).toLowerCase() === valStr)
      return target ? target.count : 0
    }

    // 初始化图表
    const initCharts = () => {
      charts.forEach(c => c.dispose())
      charts = []

      // 2. 文件类型分布饼图
      if (fileTypeChart.value) {
        const chart = echarts.init(fileTypeChart.value)
        const fileData = rawStatisticsData.value.files?.by_type || []
        
        // 准备数据
        const seriesData = fileData.map(item => ({
          value: item.count,
          name: formatFileType(item.type)
        }))
        
        // 如果没有数据，显示空状态
        if (seriesData.length === 0) {
          seriesData.push({ value: 1, name: '暂无数据' })
        }
        
        // 颜色方案
        const colorPalette = [
          '#60C2D4', '#00CCFF', '#2C7BFE', '#A262F2', '#FF6B8B',
          '#FEDB5C', '#FE672C', '#69F262', '#2CA8FE', '#C0232A'
        ]
        
        chart.setOption({
          backgroundColor: 'transparent',
          tooltip: { 
            trigger: 'item',
            backgroundColor: 'rgba(7, 19, 50, 0.95)',
            borderColor: 'rgba(96, 194, 212, 0.5)',
            borderWidth: 1,
            textStyle: { 
              color: '#75deef',
              fontSize: 12
            },
            formatter: '{a}<br/>{b}: {c} ({d}%)'
          },
          legend: { 
            bottom: 10, 
            left: 'center',
            itemWidth: 12,
            itemHeight: 12,
            textStyle: {
              color: 'rgba(117, 222, 239, 0.9)',
              fontSize: 11,
              textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)'
            },
            formatter: function(name) {
              return name
            }
          },
          color: colorPalette,
          series: [{
            name: '文件类型分布',
            type: 'pie',
            radius: ['45%', '70%'],
            center: ['50%', '45%'],
            avoidLabelOverlap: true,
            itemStyle: { 
              borderRadius: 6, 
              borderColor: 'rgba(3, 4, 74, 0.3)', 
              borderWidth: 2,
              shadowBlur: 10,
              shadowColor: 'rgba(0, 0, 0, 0.3)'
            },
            label: { 
              show: true,
              formatter: '{b}: {c}',
              fontSize: 12,
              color: 'rgba(255, 255, 255, 0.9)',
              textShadowColor: '#000',
              textShadowBlur: 2,
              textShadowOffsetY: 1
            },
            labelLine: { 
              lineStyle: { 
                color: 'rgba(117, 222, 239, 0.5)',
                width: 1
              },
              smooth: 0.2,
              length: 15,
              length2: 10
            },
            emphasis: { 
              scale: true,
              scaleSize: 10,
              itemStyle: { 
                shadowBlur: 20, 
                shadowOffsetX: 0, 
                shadowColor: 'rgba(0, 0, 0, 0.5)' 
              },
              label: { 
                show: true, 
                fontSize: 14, 
                fontWeight: 'bold', 
                color: '#fff',
                textShadowColor: '#000',
                textShadowBlur: 3
              } 
            },
            data: seriesData
          }]
        })
        charts.push(chart)
      }
    }

    // 格式化文件类型显示
    const formatFileType = (type) => {
      const typeMap = {
        'image': '图片文件',
        'text': '文本文件',
        'pdf': 'PDF文档',
        'doc': 'Word文档',
        'xls': 'Excel文件',
        'ppt': 'PPT文件',
        'video': '视频文件',
        'audio': '音频文件',
        'zip': '压缩文件',
        'unknown': '未知类型'
      }
      return typeMap[type] || type || '其他文件'
    }

    // 调整图表大小
    const resizeCharts = () => {
      charts.forEach(c => c.resize())
    }


const fetchDataFromBackend = async () => {
  loading.value = true
  try {
    // 调用后端API获取节点数据
    const response = await listNode({
      pageNum: 1,
      pageSize: 10000
    })
    const nodes = response.data || response.rows || response
    
    console.log('从后端获取的节点数据:', nodes)
    
    // 如果没有数据，使用示例数据
    if (!nodes || nodes.length === 0) {
      console.warn('后端返回空数据，使用示例数据')
      linesData.value = []
      return
    }
    
    // 按照线路分组
    const linesMap = new Map()
    
    nodes.forEach(node => {
      const lineId = node.lineId || 1
      const lineName = node.lineName || '默认线路'
      const lineStatus = node.lineStatus || '运行中'
      const lineColor = getLineColor(lineId)
      
      if (!linesMap.has(lineId)) {
        linesMap.set(lineId, {
          id: lineId,
          name: lineName,
          color: lineColor,
          status: lineStatus,
          towers: []
        })
      }
      
      // 添加节点到对应线路
      const line = linesMap.get(lineId)
      line.towers.push({
        id: node.id,
        name: node.name || `节点${node.id}`,
        coordinates: [node.latitude, node.longitude],
        status: ['0', '健康', '正常', 'online', 'active', 'normal'].includes(String(node.status)) ? 'completed' : (['1', '停用', 'offline'].includes(String(node.status)) ? 'abnormal' : node.status || 'pending'),
        dir: node.dir,
        voltage: node.voltage,
        description: node.description,
        createTime: node.createTime
      })
    })
    
    // 转换为数组并对齐节点
    const linesArray = Array.from(linesMap.values())
    
    // 对每条线路的节点进行直线对齐
    linesArray.forEach(line => {
      line.towers = line.towers.filter(tower => tower.coordinates.every(value => Number.isFinite(Number(value))))
    })
    
    linesData.value = linesArray
    
    console.log('转换并对齐后的线路数据:', linesData.value)
    
  } catch (error) {
    console.error('获取节点数据失败:', error)
    // 如果后端不可用，使用示例数据
    linesData.value = []
  } finally {
    loading.value = false
  }
}

    // 为线路分配颜色
    const getLineColor = (lineId) => {
      const colors = ['#60C2D4', '#00CCFF', '#FEDB5C', '#A262F2', '#FF6B8B', '#69F262']
      return colors[lineId % colors.length]
    }

    // 刷新数据
    const refreshData = () => {
      fetchDataFromBackend()
      fetchStatistics()
      updateTime()
    }

const getSampleData = () => {
  // 定义直线的基础坐标
  const baseLat = 40.1291;
  const baseLng = 124.3947;
  const latStep = 0.008;  // 纬度步长
  const lngStep = 0.008;  // 经度步长
  
  return [
    {
      id: 1,
      name: '丹东主干线1',
      color: '#60C2D4',
      status: '运行中',
      towers: [
        { 
          id: 1, 
          coordinates: [baseLat, baseLng], 
          status: 'completed', 
          name: '1号塔',
          dir: 1
        },
        { 
          id: 2, 
          coordinates: [baseLat + latStep, baseLng + lngStep], 
          status: 'running', 
          name: '2号塔',
          dir: 2
        },
        { 
          id: 3, 
          coordinates: [baseLat + latStep * 2, baseLng + lngStep * 2], 
          status: 'pending', 
          name: '3号塔',
          dir: 3
        },
        { 
          id: 4, 
          coordinates: [baseLat + latStep * 3, baseLng + lngStep * 3], 
          status: 'abnormal', 
          name: '4号塔',
          dir: 4
        },
      ]
    },
    {
      id: 2,
      name: '丹东支线2',
      color: '#00CCFF',
      status: '正常运行',
      towers: [
        { 
          id: 5, 
          coordinates: [baseLat + 0.02, baseLng + 0.02], 
          status: 'completed', 
          name: '5号塔',
          dir: 5
        },
        { 
          id: 6, 
          coordinates: [baseLat + 0.02 + latStep, baseLng + 0.02 + lngStep], 
          status: 'running', 
          name: '6号塔',
          dir: 6
        },
        { 
          id: 7, 
          coordinates: [baseLat + 0.02 + latStep * 2, baseLng + 0.02 + lngStep * 2], 
          status: 'pending', 
          name: '7号塔',
          dir: 7
        },
      ]
    }
  ]
}
    // 创建自定义图标
    const createTowerIcon = (status, name) => {
      const color = statusColors[status] || '#60C2D4'
      
      const svg = `
        <svg width="40" height="40" viewBox="0 0 40 40">
          <defs>
            <linearGradient id="gradient${status}" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" style="stop-color:${color};stop-opacity:1" />
              <stop offset="100%" style="stop-color:${color}cc;stop-opacity:1" />
            </linearGradient>
            <filter id="shadow${status}" x="-50%" y="-50%" width="200%" height="200%">
              <feDropShadow dx="0" dy="0" stdDeviation="3" flood-color="${color}" flood-opacity="0.8"/>
            </filter>
          </defs>
          <circle cx="20" cy="20" r="14" fill="url(#gradient${status})" filter="url(#shadow${status})" stroke="#fff" stroke-width="2"/>
          <text x="20" y="20" text-anchor="middle" dominant-baseline="central" fill="#fff" font-size="10" font-weight="bold">${name}</text>
        </svg>
      `
      
      return L.divIcon({
        html: svg,
        className: 'tower-icon',
        iconSize: [40, 40],
        iconAnchor: [20, 20],
      })
    }

    // 获取文件夹下的JPG图片
    const getFolderImagesAsync = async (dir) => {
      // 检查缓存
      if (imageCache.value.has(dir)) {
        console.log(`从缓存获取文件夹${dir}的图片`)
        return imageCache.value.get(dir)
      }
      
      console.log(`开始异步获取文件夹${dir}的图片`)
      // 返回一个立即完成的Promise，表示正在加载中
      return new Promise((resolve) => {
        // 异步加载图片
        setTimeout(async () => {
          try {
            const response = await listFile({ 
              root: dir, pageNum: 1, pageSize: 1000 
            })
            
            const files = response.rows || response.data || []
            console.log(`文件夹${dir}下的文件:`, files)
            
            // 筛选JPG文件
            const jpgFiles = files.filter(file => {
              const fileName = file.fileName || file.name || ''
              const fileType = file.fileType || file.type || ''
              return fileName.toLowerCase().endsWith('.jpg') || 
                     fileName.toLowerCase().endsWith('.jpeg') ||
                     fileType.toLowerCase().includes('jpeg') ||
                     fileType.toLowerCase().includes('jpg')
            })
            
            console.log(`文件夹${dir}下的JPG文件:`, jpgFiles)
            
            // 为每个JPG文件获取下载URL
            const imageUrls = []
            for (const file of jpgFiles) {
              try {
                const fileId = file.id || file.fileId
                if (fileId) {
                  const blob = await down(fileId)
                  const imageUrl = URL.createObjectURL(blob)
                  imageUrls.push({
                    url: imageUrl,
                    fileName: file.fileName || file.name || '未知文件',
                    fileSize: file.fileSize || 0,
                    createTime: file.createTime || file.uploadTime
                  })
                }
              } catch (error) {
                console.error(`下载文件失败:`, error)
              }
            }
            
            console.log(`文件夹${dir}的图片URL:`, imageUrls)
            
            // 存入缓存
            imageCache.value.set(dir, imageUrls)
            resolve(imageUrls)
          } catch (error) {
            console.error(`获取文件夹${dir}的文件列表失败:`, error)
            resolve([])
          }
        }, 0)
      })
    }

    // 清除所有图层
    const clearAllLayers = () => {
      Object.values(lineLayers).forEach(layer => {
        if (layer && map.hasLayer(layer)) {
          map.removeLayer(layer)
        }
      })
      Object.values(towerLayers).forEach(layer => {
        if (layer && map.hasLayer(layer)) {
          map.removeLayer(layer)
        }
      })
      lineLayers = {}
      towerLayers = {}
    }

    // 显示指定线路
    const showLine = (line) => {
      clearAllLayers()
      
      console.log('显示线路:', line.name, '包含塔数量:', line.towers.length)

      // 创建线路
      const lineCoordinates = line.towers.map(tower => 
        L.latLng(tower.coordinates[0], tower.coordinates[1])
      )
      
      const lineLayer = L.polyline(lineCoordinates, {
        color: line.color,
        weight: 6,
        opacity: 0.8,
        dashArray: line.status === '已停用' ? '10, 5' : null,
        lineJoin: 'round',
        className: 'tech-line'
      }).addTo(map)

      lineLayers[line.id] = lineLayer

      // 创建输电塔标记
      const towerLayer = L.layerGroup().addTo(map)
      
      line.towers.forEach(tower => {
        const { coordinates, status, name, id, dir } = tower
        const marker = L.marker([coordinates[0], coordinates[1]], {
          title: name,
          icon: createTowerIcon(status, name)
        }).addTo(towerLayer)
        
        // 构建弹出框内容（初始内容，包含图片加载占位符）
        let popupContent = `
          <div class="tech-popup">
            <div class="popup-header">
              <h3>${name}</h3>
              <span class="status-badge" style="background-color: ${statusColors[status]}">${statusText[status]}</span>
            </div>
            <div class="popup-content">
              <div class="popup-row">
                <span class="label">线路名称:</span>
                <span class="value">${line.name}</span>
              </div>
              <div class="popup-row">
                <span class="label">节点ID:</span>
                <span class="value">${id}</span>
              </div>
              <div class="popup-row">
                <span class="label">经纬度:</span>
                <span class="value">${coordinates[0].toFixed(4)}, ${coordinates[1].toFixed(4)}</span>
              </div>
              ${tower.voltage ? `<div class="popup-row"><span class="label">电压等级:</span><span class="value">${tower.voltage}</span></div>` : ''}
              ${tower.description ? `<div class="popup-row"><span class="label">描述信息:</span><span class="value">${tower.description}</span></div>` : ''}
              ${dir ? `<div class="popup-row">
                <span class="label">文件夹ID:</span>
                <span class="value">${dir}</span>
              </div>` : ''}
              
              <!-- 图片展示区域 -->
              <div class="images-section" id="images-section-${id}">
                <div class="images-loading">正在加载关联图片...</div>
              </div>
            </div>
          </div>
        `
        
        const popup = L.popup({
          className: 'tech-popup-wrapper',
          maxWidth: 400,
          maxHeight: 500,
          closeOnClick: false,  // 点击地图不关闭
          autoClose: false      // 不自动关闭
        }).setContent(popupContent)
        
        marker.bindPopup(popup)
        
        // 存储鼠标状态
        let isMouseOverMarker = false
        let isMouseOverPopup = false
        let closePopupTimer = null
        
        // 标记鼠标悬停事件 - 立即打开弹出框
        marker.on('mouseover', function() {
          isMouseOverMarker = true
          if (closePopupTimer) {
            clearTimeout(closePopupTimer)
            closePopupTimer = null
          }
          this.openPopup()
        })
        
        // 标记鼠标移出事件 - 延迟关闭弹出框
        marker.on('mouseout', function() {
          isMouseOverMarker = false
          if (closePopupTimer) {
            clearTimeout(closePopupTimer)
          }
          closePopupTimer = setTimeout(() => {
            if (!isMouseOverPopup) {
              this.closePopup()
            }
          }, 300) // 300ms延迟，给用户时间移动到弹出框
        })
        
        // 添加弹出框打开事件 - 异步加载图片
        marker.on('popupopen', async function() {
          const popupElement = this.getPopup().getElement()
          const imagesSection = popupElement.querySelector(`#images-section-${id}`)
          
          // 添加弹出框鼠标事件
          if (popupElement) {
            popupElement.addEventListener('mouseenter', () => {
              isMouseOverPopup = true
              if (closePopupTimer) {
                clearTimeout(closePopupTimer)
                closePopupTimer = null
              }
            })
            
            popupElement.addEventListener('mouseleave', () => {
              isMouseOverPopup = false
              if (closePopupTimer) {
                clearTimeout(closePopupTimer)
              }
              closePopupTimer = setTimeout(() => {
                if (!isMouseOverMarker) {
                  this.closePopup()
                }
              }, 300)
            })
          }
          
          if (imagesSection && dir) {
            // 异步加载图片，不阻塞弹出框显示
            setTimeout(async () => {
              try {
                // 获取文件夹下的图片
                const images = await getFolderImagesAsync(dir)
                
                if (images.length > 0) {
                  let imagesHTML = `<h4 class="images-title">关联图片 (${images.length}张)</h4>`
                  imagesHTML += '<div class="images-container">'
                  
                  images.forEach((image, index) => {
                    imagesHTML += `
                      <div class="image-item">
                        <div class="image-wrapper">
                          <img src="${image.url}" alt="${image.fileName}" 
                               class="node-image" 
                               loading="lazy"
                               onerror="this.onerror=null;this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPHJlY3Qgd2lkdGg9IjEwMCIgaGVpZ2h0PSIxMDAiIGZpbGw9IiMyMDI0MzYiLz4KICA8dGV4dCB4PSI1MCIgeT0iNTAiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxMiIgZmlsbD0iIzc1ZGVlZiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgYWxpZ25tZW50LWJhc2VsaW5lPSJtaWRkbGUiPmltYWdlPC90ZXh0Pgo8L3N2Zz4K'">
                        </div>
                        <div class="image-info">
                          <span class="image-name">${image.fileName}</span>
                          ${image.fileSize ? `<span class="image-size">${formatFileSize(image.fileSize)}</span>` : ''}
                        </div>
                      </div>
                    `
                  })
                  
                  imagesHTML += '</div>'
                  imagesSection.innerHTML = imagesHTML
                } else {
                  imagesSection.innerHTML = '<div class="no-images">暂无关联图片</div>'
                }
              } catch (error) {
                console.error('加载图片失败:', error)
                imagesSection.innerHTML = '<div class="images-error">加载图片失败</div>'
              }
            }, 0) // 使用setTimeout确保不阻塞UI
          } else if (!dir) {
            imagesSection.innerHTML = '<div class="no-folder">未关联文件夹</div>'
          }
        })
        
        // 清理对象URL和定时器
        marker.on('popupclose', function() {
          isMouseOverPopup = false
          if (closePopupTimer) {
            clearTimeout(closePopupTimer)
            closePopupTimer = null
          }
          // 这里可以清理对象URL，但为了性能考虑，我们只在组件卸载时清理
        })
      })

      towerLayers[line.id] = towerLayer

      // 自动适配线路范围
      setTimeout(() => {
        const group = new L.featureGroup([lineLayer, towerLayer])
        map.fitBounds(group.getBounds().pad(0.1), {
          duration: 1,
          maxZoom: 12
        })
      }, 100)
    }

    // 显示所有线路
    const showAllLines = () => {
      if (linesData.value.length === 0) {
        console.warn('没有线路数据可显示')
        return
      }
      
      clearAllLayers()
      console.log('显示所有线路')
      
      let allFeatures = []
      
      linesData.value.forEach(line => {
        // 创建线路
        const lineCoordinates = line.towers.map(tower => 
          L.latLng(tower.coordinates[0], tower.coordinates[1])
        )
        
        const lineLayer = L.polyline(lineCoordinates, {
          color: line.color,
          weight: 4,
          opacity: 0.7,
          dashArray: line.status === '已停用' ? '5, 3' : null,
          lineJoin: 'round',
          className: 'tech-line'
        }).addTo(map)

        lineLayers[line.id] = lineLayer
        allFeatures.push(lineLayer)

        // 创建输电塔标记
        const towerLayer = L.layerGroup().addTo(map)
        
        line.towers.forEach(tower => {
          const { coordinates, status, name, id, dir } = tower
          const marker = L.marker([coordinates[0], coordinates[1]], {
            title: name,
            icon: createTowerIcon(status, name)
          }).addTo(towerLayer)
          
          // 构建弹出框内容（初始内容，包含图片加载占位符）
          let popupContent = `
            <div class="tech-popup">
              <div class="popup-header">
                <h3>${name}</h3>
                <span class="status-badge" style="background-color: ${statusColors[status]}">${statusText[status]}</span>
              </div>
              <div class="popup-content">
                <div class="popup-row">
                  <span class="label">线路名称:</span>
                  <span class="value">${line.name}</span>
                </div>
                <div class="popup-row">
                  <span class="label">节点ID:</span>
                  <span class="value">${id}</span>
                </div>
                <div class="popup-row">
                  <span class="label">经纬度:</span>
                  <span class="value">${coordinates[0].toFixed(4)}, ${coordinates[1].toFixed(4)}</span>
                </div>
                ${tower.voltage ? `<div class="popup-row"><span class="label">电压等级:</span><span class="value">${tower.voltage}</span></div>` : ''}
                ${tower.description ? `<div class="popup-row"><span class="label">描述信息:</span><span class="value">${tower.description}</span></div>` : ''}
                ${dir ? `<div class="popup-row">
                  <span class="label">文件夹ID:</span>
                  <span class="value">${dir}</span>
                </div>` : ''}
                
                <!-- 图片展示区域 -->
                <div class="images-section" id="images-section-${id}">
                  <div class="images-loading">正在加载关联图片...</div>
                </div>
              </div>
            </div>
          `
          
          const popup = L.popup({
            className: 'tech-popup-wrapper',
            maxWidth: 400,
            maxHeight: 500,
            closeOnClick: false,  // 点击地图不关闭
            autoClose: false      // 不自动关闭
          }).setContent(popupContent)
          
          marker.bindPopup(popup)
          
          // 存储鼠标状态
          let isMouseOverMarker = false
          let isMouseOverPopup = false
          let closePopupTimer = null
          
          // 标记鼠标悬停事件 - 立即打开弹出框
          marker.on('mouseover', function() {
            isMouseOverMarker = true
            if (closePopupTimer) {
              clearTimeout(closePopupTimer)
              closePopupTimer = null
            }
            this.openPopup()
          })
          
          // 标记鼠标移出事件 - 延迟关闭弹出框
          marker.on('mouseout', function() {
            isMouseOverMarker = false
            if (closePopupTimer) {
              clearTimeout(closePopupTimer)
            }
            closePopupTimer = setTimeout(() => {
              if (!isMouseOverPopup) {
                this.closePopup()
              }
            }, 300) // 300ms延迟，给用户时间移动到弹出框
          })
          
          // 添加弹出框打开事件 - 异步加载图片
          marker.on('popupopen', async function() {
            const popupElement = this.getPopup().getElement()
            const imagesSection = popupElement.querySelector(`#images-section-${id}`)
            
            // 添加弹出框鼠标事件
            if (popupElement) {
              popupElement.addEventListener('mouseenter', () => {
                isMouseOverPopup = true
                if (closePopupTimer) {
                  clearTimeout(closePopupTimer)
                  closePopupTimer = null
                }
              })
              
              popupElement.addEventListener('mouseleave', () => {
                isMouseOverPopup = false
                if (closePopupTimer) {
                  clearTimeout(closePopupTimer)
                }
                closePopupTimer = setTimeout(() => {
                  if (!isMouseOverMarker) {
                    this.closePopup()
                  }
                }, 300)
              })
            }
            
            if (imagesSection && dir) {
              // 异步加载图片，不阻塞弹出框显示
              setTimeout(async () => {
                try {
                  // 获取文件夹下的图片
                  const images = await getFolderImagesAsync(dir)
                  
                  if (images.length > 0) {
                    let imagesHTML = `<h4 class="images-title">关联图片 (${images.length}张)</h4>`
                    imagesHTML += '<div class="images-container">'
                    
                    images.forEach((image, index) => {
                      imagesHTML += `
                        <div class="image-item">
                          <div class="image-wrapper">
                            <img src="${image.url}" alt="${image.fileName}" 
                                 class="node-image" 
                                 loading="lazy"
                                 onerror="this.onerror=null;this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPHJlY3Qgd2lkdGg9IjEwMCIgaGVpZ2h0PSIxMDAiIGZpbGw9IiMyMDI0MzYiLz4KICA8dGV4dCB4PSI1MCIgeT0iNTAiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxMiIgZmlsbD0iIzc1ZGVlZiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgYWxpZ25tZW50LWJhc2VsaW5lPSJtaWRkbGUiPmltYWdlPC90ZXh0Pgo8L3N2Zz4K'">
                          </div>
                          <div class="image-info">
                            <span class="image-name">${image.fileName}</span>
                            ${image.fileSize ? `<span class="image-size">${formatFileSize(image.fileSize)}</span>` : ''}
                          </div>
                        </div>
                      `
                    })
                    
                    imagesHTML += '</div>'
                    imagesSection.innerHTML = imagesHTML
                  } else {
                    imagesSection.innerHTML = '<div class="no-images">暂无关联图片</div>'
                  }
                } catch (error) {
                  console.error('加载图片失败:', error)
                  imagesSection.innerHTML = '<div class="images-error">加载图片失败</div>'
                }
              }, 0) // 使用setTimeout确保不阻塞UI
            } else if (!dir) {
              imagesSection.innerHTML = '<div class="no-folder">未关联文件夹</div>'
            }
          })
          
          // 清理对象URL和定时器
          marker.on('popupclose', function() {
            isMouseOverPopup = false
            if (closePopupTimer) {
              clearTimeout(closePopupTimer)
              closePopupTimer = null
            }
          })
        })

        towerLayers[line.id] = towerLayer
      })

      // 自动适配所有线路范围
      setTimeout(() => {
        if (allFeatures.length > 0) {
          const group = new L.featureGroup(allFeatures)
          map.fitBounds(group.getBounds().pad(0.1), {
            duration: 1,
            maxZoom: 10
          })
        }
      }, 200)
    }

    // 清除所有线路显示
    const clearAllLines = () => {
      clearAllLayers()
      console.log('清除所有线路显示')
    }

    // 格式化文件大小
    const formatFileSize = (bytes) => {
      if (bytes === 0) return '0 B'
      const k = 1024
      const sizes = ['B', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    }

    // Leaflet 相关变量
    let map = null
    let lineLayers = {}
    let towerLayers = {}

    // 初始化地图（使用国内可访问的底图）
    const initMap = () => {
      console.log('初始化地图...')
      
      const mapElement = document.getElementById('map')
      if (!mapElement) {
        console.error('地图容器未找到')
        return
      }

      // 初始化地图
      map = L.map('map').setView([40.1591, 124.4247], 11)
      console.log('地图实例创建成功')
      

      L.tileLayer('https://webst01.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}', {
        attribution: '&copy; <a href="https://www.高德地图.org/copyright">高德地图</a> contributors',
        maxZoom: 40,
      }).addTo(map)

      console.log('底图加载完成')

      // 初始显示所有线路
      showAllLines()
    }

    onMounted(() => {
      console.log('组件挂载完成')
      // 更新时间
      updateTime()
      setInterval(updateTime, 1000)
      
      setTimeout(() => {
        initMap()
        // 从后端获取数据
        fetchDataFromBackend()
        // 获取统计数据
        fetchStatistics()
      }, 100)
      
      // 监听窗口大小变化
      window.addEventListener('resize', resizeCharts)
    })

    onBeforeUnmount(() => {
      if (map) {
        map.remove()
        map = null
        console.log('地图清理完成')
      }
      charts.forEach(c => c.dispose())
      charts = []
      // 移除事件监听
      window.removeEventListener('resize', resizeCharts)
      
      // 清理所有对象URL
      imageCache.value.forEach(images => {
        images.forEach(image => {
          URL.revokeObjectURL(image.url)
        })
      })
      imageCache.value.clear()
    })

    return {
      allLines,
      statusColors,
      statusText,
      loading,
      statisticsData,
      currentTime,
      nodeStatusChart,
      fileTypeChart,
      showAllLines,
      clearAllLines,
      refreshData,
      getPercentage
    }
  }
}
</script>



<style scoped>
.dashboard-container {
  position: relative;
  display: flex;
  width: 100%;
  height: calc(100vh - 84px);
  overflow: hidden;
  background: linear-gradient(135deg, #03044A 0%, #090D2E 100%);
}

/* 地图容器样式 */
.map-container {
  flex: 1;
  position: relative;
  height: 100%;
  min-width: 0;
  display: flex;
  flex-direction: column;
  margin: 0;
}

/* 地图标题 */
.map-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: rgba(13, 19, 65, 0.6);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(96, 194, 212, 0.2);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.title-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  /* background: linear-gradient(135deg, #60C2D4 0%, #2C7BFE 100%); */
  display: flex;
  align-items: center;
  justify-content: center;
  /* box-shadow: 0 4px 15px rgba(96, 194, 212, 0.4); */
}

/* 标题图片样式适配容器 */
.title-img {
  width: 100%;
  height: 100%;
  object-fit: contain; /* 保持图片比例，不拉伸变形 */
  border: none; /* 去除默认边框（如果有） */
}

.title-icon i {
  font-size: 20px;
  color: #fff;
}

.header-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.map-title {
  margin: 0;
  font-size: 18px;
  font-weight: bold;
  color: #75deef;
  letter-spacing: 1px;
}

.map-subtitle {
  margin: 0;
  font-size: 12px;
  color: rgba(117, 222, 239, 0.8);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.time-display {
  font-size: 14px;
  color: #75deef;
  background: rgba(9, 16, 46, 0.5);
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid rgba(96, 194, 212, 0.3);
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
}

.indicator-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.indicator-dot.online {
  background-color: #69F262;
  box-shadow: 0 0 10px rgba(105, 242, 98, 0.8);
  animation: pulse 2s infinite;
}

.indicator-text {
  font-size: 14px;
  color: rgba(117, 222, 239, 0.9);
}

@keyframes pulse {
  0%, 100% {
    box-shadow: 0 0 5px rgba(105, 242, 98, 0.8);
  }
  50% {
    box-shadow: 0 0 15px rgba(105, 242, 98, 1);
  }
}

.map {
  flex: 1;
  background: #03044A;
  margin: 15px 15px 0 15px;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(96, 194, 212, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.map-legend {
  padding: 15px 20px;
  background: rgba(13, 19, 65, 0.7);
  backdrop-filter: blur(10px);
  font-size: 12px;
  border-radius: 8px;
  margin: 15px;
  border: 1px solid rgba(96, 194, 212, 0.3);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
}

.legend-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
}

.legend-icon {
  width: 24px;
  height: 24px;
  border-radius: 6px;
  background: linear-gradient(135deg, rgba(96, 194, 212, 0.2), rgba(44, 123, 254, 0.2));
  display: flex;
  align-items: center;
  justify-content: center;
}

.legend-icon i {
  font-size: 14px;
  color: #60C2D4;
}

.legend-title {
  font-size: 14px;
  font-weight: 600;
  color: #75deef;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.legend-items {
  display: flex;
  flex-wrap: wrap;
  gap: 15px 25px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 12px;
}

.legend-dot-wrapper {
  position: relative;
  width: 20px;
  height: 20px;
}

.legend-dot {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: block;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.3);
  box-shadow: 0 0 8px currentColor;
  z-index: 2;
}

.legend-pulse {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: block;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  opacity: 0.3;
  animation: pulse 2s infinite;
  z-index: 1;
}

.legend-text {
  font-weight: 500;
  color: rgba(117, 222, 239, 0.9);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
}

/* 右侧图表容器 */
.right-charts {
  width: 420px;
  min-width: 420px;
  height: 100%;
  padding: 20px;
  overflow-y: auto;
  background: rgba(13, 19, 65, 0.7);
  backdrop-filter: blur(15px);
  box-shadow: -4px 0 30px rgba(0, 0, 0, 0.4);
  border-left: 1px solid rgba(96, 194, 212, 0.2);
  z-index: 900;
  flex-shrink: 0;
}

/* 区域标题 */
.section-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.section-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  background: linear-gradient(135deg, rgba(96, 194, 212, 0.2), rgba(44, 123, 254, 0.2));
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgba(96, 194, 212, 0.3);
}

.section-icon i {
  font-size: 18px;
  color: #60C2D4;
}

.section-title {
  flex: 1;
}

.section-title h3 {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: bold;
  color: #fff;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.section-title p {
  margin: 0;
  font-size: 12px;
  color: rgba(117, 222, 239, 0.7);
}

/* 控制按钮区域 */
.control-section {
  background: rgba(13, 19, 65, 0.5);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid rgba(96, 194, 212, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(5px);
}

.control-buttons {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.btn-tech {
  position: relative;
  padding: 14px 16px;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  font-weight: 500;
  background: transparent;
  color: #fff;
  overflow: hidden;
}

.btn-tech:before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: 10px;
  padding: 2px;
  background: linear-gradient(135deg, rgba(96, 194, 212, 0.5), rgba(44, 123, 254, 0.5));
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  z-index: 1;
}

.btn-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(96, 194, 212, 0.1), rgba(44, 123, 254, 0.1));
  opacity: 0;
  transition: opacity 0.3s ease;
  border-radius: 10px;
}

.btn-icon {
  position: relative;
  z-index: 2;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-icon i {
  font-size: 16px;
}

.btn-text {
  position: relative;
  z-index: 2;
  flex: 1;
  text-align: left;
}

.btn-primary {
  background: linear-gradient(135deg, rgba(96, 194, 212, 0.1), rgba(44, 123, 254, 0.1));
}

.btn-primary:hover {
  background: linear-gradient(135deg, rgba(96, 194, 212, 0.2), rgba(44, 123, 254, 0.2));
}

.btn-primary:hover .btn-glow {
  opacity: 1;
}

.btn-primary .btn-icon i {
  color: #60C2D4;
}

.btn-secondary {
  background: linear-gradient(135deg, rgba(255, 107, 139, 0.1), rgba(162, 98, 242, 0.1));
}

.btn-secondary:hover {
  background: linear-gradient(135deg, rgba(255, 107, 139, 0.2), rgba(162, 98, 242, 0.2));
}

.btn-secondary:hover .btn-glow {
  opacity: 1;
}

.btn-secondary .btn-icon i {
  color: #FF6B8B;
}

.btn-refresh {
  background: linear-gradient(135deg, rgba(105, 242, 98, 0.1), rgba(44, 168, 254, 0.1));
}

.btn-refresh:hover {
  background: linear-gradient(135deg, rgba(105, 242, 98, 0.2), rgba(44, 168, 254, 0.2));
}

.btn-refresh:hover .btn-glow {
  opacity: 1;
}

.btn-refresh .btn-icon i {
  color: #69F262;
}

/* 统计卡片区域 */
.stats-section {
  background: rgba(13, 19, 65, 0.5);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid rgba(96, 194, 212, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(5px);
}

.stats-cards {
  margin-bottom: 0;
}

.stats-row {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
}

.stats-row:last-child {
  margin-bottom: 0;
}

.grid-content.card-tech {
  flex: 1;
  min-height: 140px;
  background: rgba(13, 19, 65, 0.4);
  border-radius: 12px;
  padding: 18px;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  border: 1px solid rgba(96, 194, 212, 0.2);
}

.card-corner {
  position: absolute;
  width: 20px;
  height: 20px;
}

.card-corner:before,
.card-corner:after {
  content: '';
  position: absolute;
  width: 8px;
  height: 8px;
  border: 2px solid #60C2D4;
}

.card-corner:nth-child(1) {
  top: 0;
  left: 0;
}

.card-corner:nth-child(1):before {
  top: 0;
  left: 0;
  border-right: none;
  border-bottom: none;
}

.card-corner:nth-child(1):after {
  bottom: 0;
  right: 0;
  border-left: none;
  border-top: none;
}

.card-corner:nth-child(2) {
  top: 0;
  right: 0;
}

.card-corner:nth-child(2):before {
  top: 0;
  right: 0;
  border-left: none;
  border-bottom: none;
}

.card-corner:nth-child(2):after {
  bottom: 0;
  left: 0;
  border-right: none;
  border-top: none;
}

.card-corner:nth-child(3) {
  bottom: 0;
  left: 0;
}

.card-corner:nth-child(3):before {
  bottom: 0;
  left: 0;
  border-right: none;
  border-top: none;
}

.card-corner:nth-child(3):after {
  top: 0;
  right: 0;
  border-left: none;
  border-bottom: none;
}

.card-corner:nth-child(4) {
  bottom: 0;
  right: 0;
}

.card-corner:nth-child(4):before {
  bottom: 0;
  right: 0;
  border-left: none;
  border-top: none;
}

.card-corner:nth-child(4):after {
  top: 0;
  left: 0;
  border-right: none;
  border-bottom: none;
}

.card-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at center, rgba(96, 194, 212, 0.1) 0%, transparent 70%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.grid-content.card-tech:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 40px rgba(96, 194, 212, 0.2);
  border-color: rgba(96, 194, 212, 0.4);
}

.grid-content.card-tech:hover .card-glow {
  opacity: 1;
}

.card-inner {
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
  z-index: 2;
}

.card-header {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
  gap: 15px;
}

.icon-wrapper {
  width: 45px;
  height: 45px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 1;
}

.icon-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: 10px;
  background: inherit;
  opacity: 0.5;
  filter: blur(5px);
  z-index: -1;
}

.icon-wrapper i {
  font-size: 22px;
  color: white;
}

.bg-blue-glow {
  background: linear-gradient(135deg, #60C2D4 0%, #2C7BFE 100%);
  box-shadow: 0 6px 20px rgba(96, 194, 212, 0.4);
}

.bg-green-glow {
  background: linear-gradient(135deg, #69F262 0%, #13c2c2 100%);
  box-shadow: 0 6px 20px rgba(105, 242, 98, 0.4);
}

.bg-orange-glow {
  background: linear-gradient(135deg, #FEDB5C 0%, #FF6B8B 100%);
  box-shadow: 0 6px 20px rgba(254, 219, 92, 0.4);
}

.bg-purple-glow {
  background: linear-gradient(135deg, #A262F2 0%, #722ed1 100%);
  box-shadow: 0 6px 20px rgba(162, 98, 242, 0.4);
}

.card-title {
  font-size: 13px;
  color: rgba(117, 222, 239, 0.9);
  font-weight: 500;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

.card-body {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.card-number {
  font-size: 28px;
  font-weight: bold;
  margin-bottom: 10px;
  text-shadow: 0 2px 10px rgba(39, 50, 205, 0.3);
  letter-spacing: 1px;
}

.card-progress {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 6px;
}

.progress-label {
  font-size: 11px;
  color: rgba(117, 222, 239, 0.7);
}

.progress-value {
  font-size: 12px;
  font-weight: bold;
  color: #69F262;
}

.progress-bar {
  position: relative;
  width: 100%;
  height: 6px;
  border-radius: 3px;
  margin-bottom: 8px;
  overflow: hidden;
}

.progress-track {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(117, 222, 239, 0.1);
  border-radius: 3px;
}

.progress-fill {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  background: linear-gradient(90deg, #60C2D4, #2C7BFE);
  border-radius: 3px;
  transition: width 1s ease;
  z-index: 1;
}

.progress-stats {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
}

.text-success {
  color: #69F262 !important;
  font-weight: 500;
}

.text-muted {
  color: rgba(117, 222, 239, 0.5) !important;
}

/* 图表区域 */
.chart-section {
  background: rgba(13, 19, 65, 0.5);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid rgba(96, 194, 212, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(5px);
}

.chart-section:last-child {
  margin-bottom: 0;
}

.chart-wrapper {
  padding: 0;
}

.chart-box {
  height: 240px;
  width: 100%;
}

/* 响应式设计 */
@media (max-width: 1600px) {
  .right-charts {
    width: 380px;
    min-width: 380px;
  }
  
  .map-container {
    max-width: calc(100vw - 410px);
  }
  
  .chart-box {
    height: 220px;
  }
}

@media (max-width: 1400px) {
  .right-charts {
    width: 350px;
    min-width: 350px;
  }
  
  .map-container {
    max-width: calc(100vw - 380px);
  }
  
  .chart-box {
    height: 200px;
  }
  
  .grid-content.card-tech {
    min-height: 130px;
    padding: 15px;
  }
  
  .card-number {
    font-size: 24px;
  }
}

@media (max-width: 1200px) {
  .right-charts {
    width: 320px;
    min-width: 320px;
  }
  
  .map-container {
    max-width: calc(100vw - 350px);
  }
  
  .chart-box {
    height: 180px;
  }
  
  .grid-content.card-tech {
    min-height: 120px;
  }
  
  .card-number {
    font-size: 22px;
  }
}

/* 在小屏幕上将右侧栏变为可切换的侧边栏 */
@media (max-width: 1024px) {
  .dashboard-container {
    position: relative;
  }
  
  .right-charts {
    position: absolute;
    right: 0;
    top: 0;
    bottom: 0;
    width: 320px;
    min-width: 320px;
    background: rgba(13, 19, 65, 0.95);
    backdrop-filter: blur(20px);
    transform: translateX(100%);
    transition: transform 0.3s ease;
    z-index: 1000;
  }
  
  .right-charts.show {
    transform: translateX(0);
  }
  
  .map-container {
    max-width: 100%;
  }
  
  .map {
    margin: 10px;
  }
  
  .map-legend {
    margin: 0 10px 10px 10px;
  }
  
  /* 添加切换按钮 */
  .toggle-charts-btn {
    position: absolute;
    right: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 24px;
    height: 60px;
    background: linear-gradient(135deg, #60C2D4 0%, #2C7BFE 100%);
    color: white;
    border: none;
    border-radius: 4px 0 0 4px;
    cursor: pointer;
    z-index: 999;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: -2px 0 8px rgba(96, 194, 212, 0.3);
  }
}

/* 滚动条样式 */
.right-charts::-webkit-scrollbar {
  width: 6px;
}

.right-charts::-webkit-scrollbar-track {
  background: rgba(96, 194, 212, 0.05);
  border-radius: 3px;
}

.right-charts::-webkit-scrollbar-thumb {
  background: linear-gradient(135deg, #60C2D4 0%, #2C7BFE 100%);
  border-radius: 3px;
}

.right-charts::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(135deg, #00CCFF 0%, #2C7BFE 100%);
}

/* 深度选择器 */
:deep(.tower-icon) {
  background: transparent !important;
  border: none !important;
}

:deep(.leaflet-popup-content) {
  margin: 0;
  min-width: 300px;
  max-height: 400px;
  overflow-y: auto;
}

:deep(.tech-popup-wrapper) {
  background: transparent;
  border: none;
  box-shadow: none;
}

:deep(.tech-popup) {
  background: rgba(13, 19, 65, 0.95);
  border-radius: 12px;
  border: 1px solid rgba(96, 194, 212, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(10px);
  padding: 20px;
}

:deep(.popup-header) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(96, 194, 212, 0.2);
}

:deep(.popup-header h3) {
  margin: 0;
  font-size: 16px;
  font-weight: bold;
  color: #fff;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

:deep(.status-badge) {
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  color: white;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

:deep(.popup-content) {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

:deep(.popup-row) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
}

:deep(.popup-row .label) {
  color: rgba(117, 222, 239, 0.7);
}

:deep(.popup-row .value) {
  color: #fff;
  font-weight: 500;
}

:deep(.leaflet-popup-tip) {
  background: rgba(13, 19, 65, 0.95);
  border: 1px solid rgba(96, 194, 212, 0.3);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

:deep(.leaflet-container) {
  font-family: inherit;
}

:deep(.tech-line) {
  filter: drop-shadow(0 0 8px rgba(96, 194, 212, 0.3));
}

/* 图片展示区域样式 */
:deep(.images-section) {
  margin-top: 15px;
  border-top: 1px solid rgba(96, 194, 212, 0.2);
  padding-top: 15px;
}

:deep(.images-title) {
  margin: 0 0 10px 0;
  font-size: 14px;
  font-weight: bold;
  color: #75deef;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

:deep(.images-container) {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
  gap: 10px;
  max-height: 200px;
  overflow-y: auto;
  padding: 5px;
}

:deep(.image-item) {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  transition: transform 0.2s ease;
}

:deep(.image-item:hover) {
  transform: translateY(-2px);
}

:deep(.image-wrapper) {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid rgba(96, 194, 212, 0.3);
  background: rgba(9, 16, 46, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}

:deep(.node-image) {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

:deep(.node-image:hover) {
  transform: scale(1.05);
}

:deep(.image-info) {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
}

:deep(.image-name) {
  font-size: 10px;
  color: rgba(117, 222, 239, 0.9);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
  text-align: center;
}

:deep(.image-size) {
  font-size: 9px;
  color: rgba(117, 222, 239, 0.5);
}

:deep(.images-loading),
:deep(.no-images),
:deep(.images-error),
:deep(.no-folder) {
  padding: 10px;
  text-align: center;
  font-size: 12px;
  color: rgba(117, 222, 239, 0.7);
  background: rgba(9, 16, 46, 0.3);
  border-radius: 6px;
  border: 1px solid rgba(96, 194, 212, 0.2);
}

:deep(.images-error) {
  color: #FF6B8B;
}

:deep(.no-folder) {
  color: #FEDB5C;
}

/* 图片容器滚动条 */
:deep(.images-container::-webkit-scrollbar) {
  width: 4px;
}

:deep(.images-container::-webkit-scrollbar-track) {
  background: rgba(96, 194, 212, 0.05);
  border-radius: 2px;
}

:deep(.images-container::-webkit-scrollbar-thumb) {
  background: rgba(96, 194, 212, 0.3);
  border-radius: 2px;
}

:deep(.images-container::-webkit-scrollbar-thumb:hover) {
  background: rgba(96, 194, 212, 0.5);
}

/* Match the inspection workspace while retaining Leaflet interactions. */
.dashboard-container { background: #12243e; }
.map-header { background: #13243c; border-bottom-color: #263b56; padding: 18px 20px; }
.title-icon { width: 34px; height: 34px; border-radius: 9px; }
.header-left { min-width: 0; gap: 12px; }
.map-title { color: #e8f1ff; font-weight: 600; letter-spacing: .3px; }
.map-subtitle, .section-title p { color: #87a0bf; }
.time-display { background: #1a304b; color: #adc2dc; border-color: #2c4563; font-size: 12px; }
.right-charts { background: #13243c; border-left-color: #263b56; box-shadow: none; padding: 18px; }
.control-section, .stats-section { background: #192e49; border-color: #2a425e; box-shadow: none; padding: 18px; }
.section-header { margin-bottom: 16px; }
.section-title h3 { text-shadow: none; font-size: 14px; font-weight: 600; }
.section-icon { background: #223d60; border-color: #345475; width: 30px; height: 30px; }
.grid-content.card-tech { background: #1e3552; border-color: #304a69; border-radius: 9px; }
.card-number { color: #edf4ff; text-shadow: none; }
.card-title { color: #acc3df; text-shadow: none; white-space: nowrap; }
.card-icon { box-shadow: none; }
.card-corner { display: none; }
.btn-tech { border-radius: 8px; padding: 12px 14px; transition: background .18s; }
.btn-tech:before { display: none; }
.map-legend { box-shadow: none; background: #192e49; border-color: #2a425e; border-radius: 9px; }
@media (max-width: 760px) { .map-header { padding: 12px 14px; } .map-title { font-size: 15px; } .header-right .time-display { display: none; } }

</style>
