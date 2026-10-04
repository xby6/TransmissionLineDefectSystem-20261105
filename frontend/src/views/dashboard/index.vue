<template>
  <div class="dashboard-container">
    <!-- 背景层 -->
    <div class="background-layer"></div>
    
    <!-- 内容层 -->
    <div class="content-layer">
      <!-- 统计卡片区域 -->
      <el-row :gutter="20" class="mgb20">
        <el-col :span="6">
          <div class="stat-card">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="card-header">
              <i class="el-icon-s-data card-icon bg-blue"></i>
              <div class="card-title">任务总数</div>
            </div>
            <div class="card-body">
              <div class="card-number">{{ statisticsData.task_total || 0 }}</div>
              <div class="card-desc">
                <span class="text-success">运行中: {{ statisticsData.task_running || 0 }}</span>
              </div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="card-header">
              <i class="el-icon-document card-icon bg-green"></i>
              <div class="card-title">文件总数</div>
            </div>
            <div class="card-body">
              <div class="card-number">{{ statisticsData.file_total || 0 }}</div>
              <div class="card-desc">
                <span class="text-success">图像文件: {{ statisticsData.file_processed || 0 }}</span>
              </div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="card-header">
              <i class="el-icon-box card-icon bg-orange"></i>
              <div class="card-title">平台总数</div>
            </div>
            <div class="card-body">
              <div class="card-number">{{ statisticsData.container_total || 0 }}</div>
              <div class="card-desc">
                <span class="text-success">运行中: {{ statisticsData.container_running || 0 }}</span>
              </div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="card-header">
              <i class="el-icon-monitor card-icon bg-red"></i>
              <div class="card-title">节点总数</div>
            </div>
            <div class="card-body">
              <div class="card-number">{{ statisticsData.node_total || 0 }}</div>
              <div class="card-desc">
                <span class="text-success">在线: {{ statisticsData.node_online || 0 }}</span>
              </div>
            </div>
          </div>
        </el-col>
      </el-row>

      <!-- 主图表区域：左中右三列布局 -->
      <el-row :gutter="20" class="mgb20">
        <!-- 左侧列：任务状态分布、文件类型分布 -->
        <el-col :span="6">
          <div class="chart-card left-column">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="chart-header">
              <span class="title-text">任务状态分布</span>
            </div>
            <div class="chart-box left-chart-box" ref="taskStatusChart"></div>
          </div>
          
          <div class="chart-card left-column">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="chart-header">
              <span class="title-text">文件类型分布</span>
            </div>
            <div class="chart-box left-chart-box" ref="fileTypeChart"></div>
          </div>
        </el-col>

        <!-- 中间列：中国地图 -->
        <el-col :span="12">
          <div class="chart-card center-map">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="chart-header">
              <span class="title-text">全国节点分布</span>
            </div>
            <div class="chart-box map-box" ref="chinaMapChart"></div>
          </div>
        </el-col>

        <!-- 右侧列：节点状态分布、容器状态分布 -->
        <el-col :span="6">
          <div class="chart-card right-column">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="chart-header">
              <span class="title-text">节点状态分布</span>
            </div>
            <div class="chart-box right-chart-box" ref="nodeTypeChart"></div>
          </div>
          
          <div class="chart-card left-column">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="chart-header">
              <span class="title-text">平台状态分布</span>
            </div>
            <div class="chart-box left-chart-box" ref="containerStatusChart"></div>
          </div>
        </el-col>
      </el-row>

      <!-- 底部趋势图 -->
      <el-row :gutter="20">
        <el-col :span="24">
          <div class="chart-card trend-card">
            <span class="angle1"></span>
            <span class="angle2"></span>
            <span class="angle3"></span>
            <span class="angle4"></span>
            <div class="chart-header">
              <span class="title-text">最近7天任务趋势</span>
            </div>
            <div class="chart-box trend-box" ref="taskTrendChart"></div>
          </div>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup name="Dashboard">
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { getAllStatistics } from '@/api/statistics/statistics'
import * as echarts from 'echarts'
import chinaJson from '@/assets/china.json'

// 数据定义
const statisticsData = ref({})
const rawStatisticsData = ref({})

// 图表DOM引用
const taskStatusChart = ref(null)
const fileTypeChart = ref(null)
const containerStatusChart = ref(null)
const nodeTypeChart = ref(null)
const chinaMapChart = ref(null)
const taskTrendChart = ref(null)

let charts = []
const getCount = (list, keyName, value) => {
  if (!list || !Array.isArray(list)) return 0
  const valStr = String(value).toLowerCase()
  // 查找匹配项
  const target = list.find(item => String(item[keyName]).toLowerCase() === valStr)
  return target ? target.count : 0
}

const fetchStatistics = async () => {
  try {
    const res = await getAllStatistics()
    console.log('完整API响应:', res)
    let finalData = null
    if (res && res.data && typeof res.data === 'object') {
      // 标准结构，res.data包含统计数据
      finalData = res.data
    } else if (res && res.tasks) {
      // 如果res直接包含tasks，说明已经是解包后的数据
      finalData = res
    } else if (res) {
      // 如果res本身就是数据对象
      finalData = res
    }
    
    if (!finalData) {
      console.warn('收到响应但数据格式不匹配，无法解析:', res)
      // 设置默认数据用于展示
      finalData = {
        tasks: { total: 0, by_status: [], by_date: [] },
        files: { total: 0, by_type: [], by_root: [] },
        containers: { total: 0, by_status: [] },
        nodes: { total: 0, by_status: [] }
      }
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

    nextTick(() => {
      initCharts()
    })
    
  } catch (error) {
    console.error('获取统计数据失败:', error)
    // 设置默认数据
    rawStatisticsData.value = {
      tasks: { total: 0, by_status: [], by_date: [] },
      files: { total: 0, by_type: [], by_root: [] },
      containers: { total: 0, by_status: [] },
      nodes: { total: 0, by_status: [] }
    }
    statisticsData.value = {
      task_total: 0,
      task_running: 0,
      file_total: 0,
      file_processed: 0,
      container_total: 0,
      container_running: 0,
      node_total: 0,
      node_online: 0
    }
    
    nextTick(() => {
      initCharts()
    })
  }
}

// 统一图表初始化
const initCharts = () => {
  // 清理旧图表
  charts.forEach(c => {
    if (c && c.dispose) {
      c.dispose()
    }
  })
  charts = []

  // 1. 左侧：任务状态 (饼图)
  if (taskStatusChart.value) {
    createPieChart(
      taskStatusChart, 
      '任务状态', 
      rawStatisticsData.value.tasks?.by_status || [], 
      'status'
    )
  }

  // 2. 左侧：文件类型 (玫瑰图)
  if (fileTypeChart.value) {
    createRoseChart(
      fileTypeChart, 
      '文件类型', 
      rawStatisticsData.value.files?.by_type || [], 
      'type'
    )
  }

  // 3. 左侧：容器状态 (饼图)
  if (containerStatusChart.value) {
    createPieChart(
      containerStatusChart, 
      '容器状态', 
      rawStatisticsData.value.containers?.by_status || [], 
      'status'
    )
  }

  // 4. 右侧：节点状态 (柱状图)
  if (nodeTypeChart.value) {
    createBarChart(
      nodeTypeChart, 
      '节点状态', 
      rawStatisticsData.value.nodes?.by_status || [], 
      'status'
    )
  }

  // 5. 中间：中国地图
  if (chinaMapChart.value) {
    initChinaMap()
  }

  // 6. 底部：趋势图
  if (taskTrendChart.value) {
    initTrendChart()
  }
}
const initChinaMap = () => {
  if (!chinaMapChart.value) return
  
  try {
    // 1. 确保地图已注册
    if (!echarts.getMap('china')) {
      console.log('注册中国地图...')
      echarts.registerMap('china', chinaJson)
    }
    
    const chart = echarts.init(chinaMapChart.value)
    
    // 丹东市坐标（经度, 纬度）
    const nodeLocations = (rawStatisticsData.value.nodes?.locations || [])
      .filter(node => node.longitude != null && node.latitude != null)
      .map(node => ({ name: node.name, value: [node.longitude, node.latitude], status: node.status }))
    
    chart.setOption({
      backgroundColor: 'transparent',
      tooltip: {
        trigger: 'item',
        backgroundColor: 'rgba(7, 19, 50, 0.95)',
        borderColor: '#1a3c58',
        borderWidth: 1,
        textStyle: {
          color: '#75deef',
          fontSize: 12
        },
        formatter: function(params) {
          if (params.seriesName === '节点位置') {
            return params.name + '<br/>节点位置'
          }
          return params.name
        }
      },
      geo: {
        map: 'china',
        roam: false,
        zoom: 1,
        label: {
          show: true,
          color: '#75deef',
          fontSize: 10
        },
        itemStyle: {
          areaColor: 'rgba(13, 36, 81, 0.8)',
          borderColor: '#1a3c58',
          borderWidth: 1,
          shadowColor: 'rgba(0, 0, 0, 0.5)',
          shadowBlur: 10
        },
        emphasis: {
          label: {
            show: true,
            color: '#fff'
          },
          itemStyle: {
            areaColor: 'rgba(96, 194, 212, 0.3)',
            borderWidth: 1.5,
            borderColor: '#60C2D4'
          }
        }
      },
      series: [
        {
          name: '地图',
          type: 'map',
          map: 'china',
          geoIndex: 0,
          aspectScale: 0.75,
          showLegendSymbol: false,
          label: {
            show: true,
            color: '#75deef',
            fontSize: 10
          },
          itemStyle: {
            areaColor: 'rgba(13, 36, 81, 0.5)',
            borderColor: '#1a3c58',
            borderWidth: 1
          },
          emphasis: {
            label: {
              color: '#fff',
              fontWeight: 'bold'
            },
            itemStyle: {
              areaColor: 'rgba(96, 194, 212, 0.3)'
            }
          }
        },
        {
          name: '节点位置',
          type: 'scatter',
          coordinateSystem: 'geo',
          data: nodeLocations,
          symbol: 'circle',
          symbolSize: 8,
          itemStyle: {
            color: '#ff4444',
            borderColor: '#ffffff',
            borderWidth: 1
          },
          emphasis: {
            itemStyle: {
              color: '#ff0000',
              borderColor: '#ffffff',
              borderWidth: 2
            }
          }
        }
      ]
    })
    
    charts.push(chart)
    
    // 测试：检查地图是否成功加载
    setTimeout(() => {
      const option = chart.getOption()
      console.log('地图option配置:', option)
    }, 100)
    
  } catch (error) {
    console.error('初始化地图失败:', error)
    
    // 显示错误信息
    if (chinaMapChart.value) {
      const errorDiv = document.createElement('div')
      errorDiv.style.cssText = `
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #ff6b6b;
        font-size: 14px;
      `
      errorDiv.textContent = `地图加载失败: ${error.message}`
      chinaMapChart.value.appendChild(errorDiv)
    }
  }
}

// 初始化趋势图
const initTrendChart = () => {
  if (!taskTrendChart.value) return
  
  try {
    const chart = echarts.init(taskTrendChart.value)
    
    // 获取趋势数据
    let trendData = []
    
    // 检查是否有数据
    if (rawStatisticsData.value.tasks?.by_date && Array.isArray(rawStatisticsData.value.tasks.by_date)) {
      trendData = rawStatisticsData.value.tasks.by_date
      console.log('趋势图数据:', trendData)
    }
    
    // 空日期补零，保持最近七天的真实趋势。
    const counts = new Map(trendData.map(item => [item.date, item.count]))
    trendData = Array.from({ length: 7 }, (_, i) => {
      const date = new Date()
      date.setDate(date.getDate() - (6 - i))
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
      return { date: key, count: counts.get(key) || 0 }
    })

    // 确保日期格式正确
    const xAxisData = trendData.map(item => {
      const dateStr = item.date
      if (dateStr.includes('-')) {
        return dateStr.substring(5) // MM-DD格式
      }
      return dateStr
    })
    
    const seriesData = trendData.map(item => item.count || 0)
    
    chart.setOption({
      backgroundColor: 'transparent',
      tooltip: { 
        trigger: 'axis',
        backgroundColor: 'rgba(7, 19, 50, 0.95)',
        borderColor: '#1a3c58',
        borderWidth: 1,
        textStyle: { 
          color: '#75deef',
          fontSize: 11
        },
        formatter: function(params) {
          const dateIndex = params[0].dataIndex
          const date = trendData[dateIndex]?.date || ''
          let result = `<div style="font-size:12px;color:#75deef">${date}</div>`
          params.forEach(item => {
            result += `<div style="display:flex;align-items:center;margin-top:4px">
              <span style="display:inline-block;width:8px;height:8px;background:${item.color};border-radius:50%;margin-right:6px"></span>
              <span>${item.seriesName}: <span style="color:#fff;font-weight:bold">${item.value}</span></span>
            </div>`
          })
          return result
        }
      },
      grid: { 
        left: '5%', 
        right: '5%', 
        bottom: '15%', 
        top: '15%', 
        containLabel: true 
      },
      xAxis: { 
        type: 'category', 
        boundaryGap: false,
        axisLine: { 
          lineStyle: { 
            color: '#1a3c58'
          } 
        },
        axisTick: {
          show: false
        },
        axisLabel: { 
          color: '#75deef',
          fontSize: 11,
          interval: 0
        },
        data: xAxisData
      },
      yAxis: { 
        type: 'value',
        axisLine: { 
          lineStyle: { 
            color: '#1a3c58'
          } 
        },
        axisLabel: { 
          color: '#75deef',
          fontSize: 11
        },
        splitLine: { 
          lineStyle: { 
            color: 'rgba(13, 36, 81, 0.8)', 
            type: 'dashed' 
          } 
        },
        min: 0
      },
      series: [{
        name: '任务量',
        type: 'line',
        smooth: true,
        lineStyle: { 
          width: 3, 
          color: '#60C2D4'
        },
        itemStyle: { 
          color: '#60C2D4'
        },
        symbol: 'circle',
        symbolSize: 6,
        areaStyle: { 
          opacity: 0.3, 
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(96, 194, 212, 0.5)' },
            { offset: 1, color: 'rgba(96, 194, 212, 0.1)' }
          ])
        },
        data: seriesData
      }]
    })
    
    charts.push(chart)
  } catch (error) {
    console.error('初始化趋势图失败:', error)
  }
}

// 创建饼图的通用函数
const createPieChart = (domRef, title, dataList, nameKey) => {
  if (!domRef.value) return
  
  try {
    const chart = echarts.init(domRef.value)
    
    // 转换数据格式
    let seriesData = []
    
    if (dataList && Array.isArray(dataList) && dataList.length > 0) {
      seriesData = dataList.map(item => ({
        value: item.count || 0,
        name: item[nameKey] || '未知'
      }))
    } else {
      // 如果没有数据，显示占位数据
      seriesData = [
        { value: 0, name: '暂无数据' }
      ]
    }

    // 格式化函数
    const formatter = function(name) {
      if (name === 'running') return '运行中'
      if (name === 'stopped') return '已停止'
      if (name === 'queued') return '排队中'
      if (name === 'success') return '已完成'
      if (name === 'completed') return '已完成'
      if (name === 'failed') return '失败'
      if (name === 'online') return '在线'
      if (name === 'offline') return '离线'
      if (name === 'healthy') return '健康'
      if (name === 'unhealthy') return '异常'
      if (name === 'pending') return '等待中'
      return name
    }

    // 颜色方案
    const colorPalette = [
      ' #60C2D4', '#00CCFF', '#2C7BFE', '#A262F2', '#FF6B8B',
      '#FEDB5C', '#FE672C', '#69F262', '#2CA8FE', '#C0232A'
    ]

    chart.setOption({
      backgroundColor: 'transparent',
      tooltip: { 
        trigger: 'item',
        backgroundColor: 'rgba(7, 19, 50, 0.95)',
        borderColor: '#1a3c58',
        borderWidth: 1,
        textStyle: { 
          color: '#75deef',
          fontSize: 11
        },
        formatter: function(params) {
          const name = formatter(params.name)
          const value = params.value || 0
          const percent = params.percent || 0
          return `${title}<br/>${name}: ${value} (${percent}%)`
        }
      },
      legend: { 
        orient: 'vertical',
        right: '5%',
        top: 'center',
        textStyle: { 
          color: '#75deef',
          fontSize: 11
        },
        itemWidth: 10,
        itemHeight: 10,
        formatter: function(name) {
          const target = seriesData.find(item => item.name === name)
          const count = target ? target.value : 0
          return `${formatter(name)}: ${count}`
        }
      },
      color: colorPalette,
      series: [{
        name: title,
        type: 'pie',
        radius: ['40%', '60%'],
        center: ['35%', '50%'],
        avoidLabelOverlap: true,
        itemStyle: { 
          borderRadius: 3, 
          borderColor: '#03044A', 
          borderWidth: 1
        },
        label: { 
          show: false
        },
        labelLine: { 
          show: false
        },
        emphasis: { 
          scale: true,
          scaleSize: 5
        },
        data: seriesData
      }]
    })
    
    charts.push(chart)
  } catch (error) {
    console.error(`初始化${title}饼图失败:`, error)
  }
}

// 创建玫瑰图函数（文件类型分布）
const createRoseChart = (domRef, title, dataList, nameKey) => {
  if (!domRef.value) return
  
  try {
    const chart = echarts.init(domRef.value)
    
    // 转换数据格式
    const seriesData = (dataList || []).map(item => ({ value: item.count || 0, name: item[nameKey] || '未知' }))

    // 格式化函数
    const formatter = function(name) {
      const map = {
        'image': '图片',
        'file': '文件',
        'dir': '目录',
        'pdf': 'PDF',
        'txt': '文本',
        'video': '视频',
        'audio': '音频',
        'archive': '压缩包',
        'doc': '文档',
        'xls': '表格',
        'ppt': '演示',
        'code': '代码',
        'config': '配置',
        'log': '日志'
      }
      return map[name] || name
    }

    // 玫瑰图专用颜色方案
    const colorPalette = [
      '#00FFFF', '', 'rgb(0, 166, 255)', 'DodgerBlue', 'rgba(255, 255, 177, 1)',
      '#69F262', '#FF3D71', '#00D68F', '#FFAA00', '#3366FF'
    ]

    chart.setOption({
      backgroundColor: 'transparent',
      tooltip: { 
        trigger: 'item',
        backgroundColor: 'rgba(7, 19, 50, 0.95)',
        borderColor: '#1a3c58',
        borderWidth: 1,
        textStyle: { 
          color: '#75deef',
          fontSize: 11
        },
        formatter: function(params) {
          const name = formatter(params.name)
          const value = params.value || 0
          const percent = params.percent || 0
          return `${title}<br/>${name}: ${value} (${percent}%)`
        }
      },
      legend: { 
        orient: 'vertical',
        right: '5%',
        top: 'center',
        textStyle: { 
          color: '#75deef',
          fontSize: 11
        },
        itemWidth: 10,
        itemHeight: 10,
        formatter: function(name) {
          const target = seriesData.find(item => item.name === name)
          const count = target ? target.value : 0
          return `${formatter(name)}: ${count}`
        }
      },
      color: colorPalette,
      series: [{
        name: title,
        type: 'pie',
        radius: ['15%', '70%'],
        center: ['35%', '50%'],
        roseType: 'area',
        avoidLabelOverlap: true,
        itemStyle: { 
          borderRadius: 5, 
          borderColor: '#03044A', 
          borderWidth: 1
        },
        label: { 
          show: false
        },
        labelLine: { 
          show: false
        },
        emphasis: {
          scale: true,
          scaleSize: 5,
          itemStyle: {
            shadowBlur: 10,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        },
        data: seriesData
      }]
    })
    
    charts.push(chart)
  } catch (error) {
    console.error(`初始化${title}玫瑰图失败:`, error)
  }
}

// 创建柱状图函数（节点状态分布）
const createBarChart = (domRef, title, dataList, nameKey) => {
  if (!domRef.value) return
  
  try {
    const chart = echarts.init(domRef.value)
    
    // 转换数据格式
    let xAxisData = []
    let seriesData = []
    
    if (dataList && Array.isArray(dataList) && dataList.length > 0) {
      dataList.forEach(item => {
        const name = item[nameKey] || '未知'
        // 格式化显示名称
        let displayName = name
        if (name === 'online') displayName = '在线'
        else if (name === 'offline') displayName = '离线'
        else if (name === 'maintenance') displayName = '维护中'
        else if (name === 'healthy') displayName = '健康'
        else if (name === 'unhealthy') displayName = '异常'
        else if (name === 'running') displayName = '运行中'
        else if (name === 'stopped') displayName = '已停止'
        
        xAxisData.push(displayName)
        seriesData.push(item.count || 0)
      })
    } else {
      // 如果没有数据，显示示例
      xAxisData = ['在线', '离线', '维护中', '异常']
      seriesData = [0, 0, 0, 0]
    }
    
    // 柱状图颜色配置
    const barColors = xAxisData.map((name, index) => {
      if (name === '在线' || name === '健康' || name === '运行中') {
        return new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#60C2D4' },
          { offset: 1, color: '#2C7BFE' }
        ])
      } else if (name === '离线' || name === '异常' || name === '失败') {
        return new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#FF6B8B' },
          { offset: 1, color: '#FF3D71' }
        ])
      } else {
        return new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgb(0, 196, 255)' },
          { offset: 1, color: '#FE672C' }
        ])
      }
    })

    chart.setOption({
      backgroundColor: 'transparent',
      tooltip: { 
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        },
        backgroundColor: 'rgba(7, 19, 50, 0.95)',
        borderColor: '#1a3c58',
        borderWidth: 1,
        textStyle: { 
          color: '#75deef',
          fontSize: 11
        },
        formatter: function(params) {
          let result = `<div style="font-size:12px;color:#75deef">${params[0].name}</div>`
          params.forEach(item => {
            result += `<div style="display:flex;align-items:center;margin-top:4px">
              <span style="display:inline-block;width:8px;height:8px;background:${item.color};border-radius:2px;margin-right:6px"></span>
              <span>${item.seriesName}: <span style="color:#fff;font-weight:bold">${item.value}</span></span>
            </div>`
          })
          return result
        }
      },
      grid: { 
        left: '10%', 
        right: '10%', 
        bottom: '15%', 
        top: '10%', 
        containLabel: true 
      },
      xAxis: { 
        type: 'category',
        data: xAxisData,
        axisLine: { 
          lineStyle: { 
            color: '#1a3c58'
          } 
        },
        axisTick: {
          show: false
        },
        axisLabel: { 
          color: '#75deef',
          fontSize: 11,
          interval: 0
        }
      },
      yAxis: { 
        type: 'value',
        axisLine: { 
          lineStyle: { 
            color: '#1a3c58'
          } 
        },
        axisLabel: { 
          color: '#75deef',
          fontSize: 11
        },
        splitLine: { 
          lineStyle: { 
            color: 'rgba(13, 36, 81, 0.8)', 
            type: 'dashed' 
          } 
        }
      },
      series: [{
        name: title,
        type: 'bar',
        barWidth: '60%',
        itemStyle: {
          color: function(params) {
            return barColors[params.dataIndex] || '#60C2D4'
          },
          borderRadius: [2, 2, 0, 0]
        },
        label: {
          show: true,
          position: 'top',
          color: '#75deef',
          fontSize: 11,
          formatter: '{c}'
        },
        emphasis: {
          itemStyle: {
            shadowColor: 'rgba(0, 0, 0, 0.7)',
            shadowBlur: 10
          }
        },
        data: seriesData
      }]
    })
    
    charts.push(chart)
  } catch (error) {
    console.error(`初始化${title}柱状图失败:`, error)
  }
}

const resizeHandler = () => {
  charts.forEach(c => {
    if (c && c.resize) {
      c.resize()
    }
  })
}

onMounted(async () => {
  // 先确保地图文件加载完成
  try {
    if (!echarts.getMap('china')) {
      // 如果还没注册，先注册地图
      echarts.registerMap('china', chinaJson)
      console.log('地图注册成功')
    }
  } catch (mapError) {
    console.warn('地图注册失败，尝试备用方案:', mapError)
  }
  
  // 然后获取数据
  await fetchStatistics()
  
  // 确保DOM更新后初始化图表
  nextTick(() => {
    // 特别关注地图的初始化
    if (chinaMapChart.value) {
      console.log('地图容器尺寸:', {
        width: chinaMapChart.value.offsetWidth,
        height: chinaMapChart.value.offsetHeight
      })
    }
  })
  
  window.addEventListener('resize', resizeHandler)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', resizeHandler)
  charts.forEach(c => {
    if (c && c.dispose) {
      c.dispose()
    }
  })
})
</script>

<style lang="scss" scoped>
.dashboard-container {
  position: relative;
  padding: 20px;
  min-height: calc(100vh - 84px);
  height: 100%;
  width: 100%;
  overflow: auto;

  .mgb20 { margin-bottom: 20px; }

  // 背景层
  .background-layer {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: -1;
    background: 
      linear-gradient(135deg, rgba(10, 10, 42, 0.95) 0%, rgba(3, 4, 74, 0.95) 100%);
  }

  // 内容层
  .content-layer {
    position: relative;
    z-index: 1;
  }

  .stat-card {
    position: relative;
    display: flex;
    align-items: center;
    height: 120px;
    background: rgba(13, 19, 65, 0.7);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(96, 194, 212, 0.3);
    border-radius: 8px;
    padding: 0 20px;
    overflow: hidden;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    transition: all 0.3s ease;

    // 角标样式
    .angle1, .angle2, .angle3, .angle4 {
      position: absolute;
      width: 12px;
      height: 12px;
    }

    .angle1 {
      top: 0;
      left: 0;
      border-top: 2px solid #60C2D4;
      border-left: 2px solid #60C2D4;
    }

    .angle2 {
      top: 0;
      right: 0;
      border-top: 2px solid #60C2D4;
      border-right: 2px solid #60C2D4;
    }

    .angle3 {
      bottom: 0;
      left: 0;
      border-bottom: 2px solid #60C2D4;
      border-left: 2px solid #60C2D4;
    }

    .angle4 {
      bottom: 0;
      right: 0;
      border-bottom: 2px solid #60C2D4;
      border-right: 2px solid #60C2D4;
    }

    .card-header {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-right: 20px;
      .card-icon { 
        font-size: 32px; 
        margin-bottom: 10px; 
        padding: 12px; 
        border-radius: 8px; 
        color: #fff; 
        background: linear-gradient(135deg, currentColor 0%, rgba(255,255,255,0.8) 100%);
        box-shadow: 0 0 15px currentColor;
        transition: all 0.3s ease;
      }
      .card-title { 
        font-size: 14px; 
        color: #75deef;
        font-weight: 500;
        letter-spacing: 1px;
        text-shadow: 0 0 5px rgba(117, 222, 239, 0.5);
      }
      .bg-blue { color: #409EFF; }
      .bg-green { color: #67C23A; }
      .bg-orange { color: #E6A23C; }
      .bg-red { color: #F56C6C; }
    }

    .card-body {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: center;
      .card-number { 
        font-size: 28px; 
        font-weight: bold; 
        color: white; 
        margin-bottom: 5px;
        text-shadow: 0 0 10px rgba(117, 222, 239, 0.5);
        letter-spacing: 1px;
       
      }
      .card-desc { 
        font-size: 13px; 
        color: #a0a0a0; 
        .text-success { 
          color: #67C23A;
          font-weight: 500;
          text-shadow: 0 0 5px rgba(103, 194, 58, 0.5);
        }
      }
    }

    &:hover {
      border-color: #60C2D4;
      box-shadow: 0 0 20px rgba(96, 194, 212, 0.3);
      transform: translateY(-2px);
      background: rgba(13, 19, 65, 0.9);
      
      .card-icon {
        transform: scale(1.1);
      }
    }
  }

  .chart-card {
    position: relative;
    background: rgba(13, 19, 65, 0.7);
    backdrop-filter: blur(10px);
    padding: 15px;
    border: 1px solid rgba(96, 194, 212, 0.3);
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    transition: all 0.3s ease;

    // 角标样式
    .angle1, .angle2, .angle3, .angle4 {
      position: absolute;
      width: 12px;
      height: 12px;
    }

    .angle1 {
      top: 0;
      left: 0;
      border-top: 2px solid #60C2D4;
      border-left: 2px solid #60C2D4;
    }

    .angle2 {
      top: 0;
      right: 0;
      border-top: 2px solid #60C2D4;
      border-right: 2px solid #60C2D4;
    }

    .angle3 {
      bottom: 0;
      left: 0;
      border-bottom: 2px solid #60C2D4;
      border-left: 2px solid #60C2D4;
    }

    .angle4 {
      bottom: 0;
      right: 0;
      border-bottom: 2px solid #60C2D4;
      border-right: 2px solid #60C2D4;
    }

    .chart-header { 
      font-size: 16px; 
      font-weight: bold; 
      color: #fff; 
      margin-bottom: 15px; 
      padding-left: 10px; 
      border-left: 4px solid #60C2D4; 
      display: flex;
      align-items: center;
      justify-content: space-between;
      
      .title-text {
        position: relative;
        font-size: 14px;
        color: #6EDDF1;
        border: 2px solid #6EDDF1;
        height: 22px;
        padding: 0 10px;
        display: inline-block;
        background: rgba(9, 16, 46, 0.8);
        
        &::before {
          content: '';
          position: absolute;
          top: -2px;
          left: -2px;
          right: -2px;
          bottom: -2px;
          background: rgba(9, 16, 46, 0.5);
          z-index: -1;
        }
      }
      
      .map-legend {
        display: flex;
        gap: 15px;
        .legend-item {
          font-size: 12px;
          color: #75deef;
          display: flex;
          align-items: center;
          .legend-dot {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 5px;
            &.low { background: #60C2D4; }
            &.medium { background: #2C7BFE; }
            &.high { background: #FF6B8B; }
          }
        }
      }
    }

    // 左侧列样式
    &.left-column {
      margin-bottom: 20px;
      height: 280px;
      .chart-box {
        height: 220px;
      }
    }
    
    // 中间地图样式
    &.center-map {
      height: 580px;
      .chart-box {
        height: 520px;
      }
    }
    
    // 右侧列样式
    &.right-column {
      margin-bottom: 20px;
      height: 280px;
      .chart-box {
        height: 220px;
      }
    }
    
    // 底部趋势图样式
    &.trend-card {
      height: 280px;
      .chart-box {
        height: 220px;
      }
    }

    .chart-box { 
      width: 100%;
    }

    &:hover {
      border-color: #60C2D4;
      box-shadow: 0 0 25px rgba(96, 194, 212, 0.2);
      transform: translateY(-2px);
      background: rgba(13, 19, 65, 0.9);
    }
  }
}

// 全局echarts深色主题覆盖
:deep(.echarts-tooltip) {
  background: rgba(7, 19, 50, 0.95) !important;
  border: 1px solid #1a3c58 !important;
  box-shadow: 0 0 15px rgba(96, 194, 212, 0.2) !important;
  backdrop-filter: blur(5px) !important;
}

:deep(.echarts-legend-item) {
  color: #75deef !important;
  text-shadow: 0 0 5px rgba(117, 222, 239, 0.5) !important;
}

:deep(.echarts-axis-line),
:deep(.echarts-axis-tick-line) {
  stroke: #1a3c58 !important;
}

:deep(.echarts-grid-line) {
  stroke: rgba(26, 60, 88, 0.5) !important;
}
</style>