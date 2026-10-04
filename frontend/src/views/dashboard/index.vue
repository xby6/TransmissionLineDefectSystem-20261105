<template>
  <div class="inspection-overview">
    <PageHeader title="巡检总览" description="掌握巡检任务、数据资源与输电节点运行概况。" eyebrow="TRANSMISSION LINE INSPECTION">
      <el-button :loading="loading" :icon="Refresh" @click="fetchStatistics">刷新数据</el-button>
      <el-button type="primary" :icon="Plus" @click="router.push('/task')">检测任务</el-button>
    </PageHeader>
    <el-alert v-if="loadError" title="统计数据暂时无法加载，请稍后刷新重试。" type="warning" show-icon :closable="false" class="overview-alert" />
    <div class="overview-meta"><span class="meta-dot"></span>巡检资源概况<span class="updated-at">{{ updatedAt ? `更新于 ${updatedAt}` : '正在读取数据' }}</span></div>
    <section class="metrics-grid" aria-label="巡检统计">
      <article v-for="metric in metrics" :key="metric.label" class="metric-card">
        <div class="metric-top"><span>{{ metric.label }}</span><el-icon class="metric-icon" :class="metric.tone"><component :is="metric.icon" /></el-icon></div>
        <div class="metric-value">{{ loading && !updatedAt ? '—' : metric.value.toLocaleString() }}<span>{{ metric.unit }}</span></div>
        <div class="metric-detail"><span class="detail-dot" :class="metric.tone"></span>{{ loading && !updatedAt ? '正在读取数据' : metric.detail }}</div>
      </article>
    </section>
    <section class="chart-grid" aria-label="巡检数据分析">
      <div class="side-charts">
        <article class="analysis-panel"><header><h2>任务状态分布</h2><span>执行概况</span></header><div ref="taskStatusChart" class="small-chart"></div></article>
        <article class="analysis-panel"><header><h2>文件类型分布</h2><span>资源结构</span></header><div ref="fileTypeChart" class="small-chart"></div></article>
      </div>
      <article class="analysis-panel map-panel">
        <header><div><span class="map-eyebrow">NODE DISTRIBUTION</span><h2>全国输电节点分布</h2></div><el-button text class="map-link" @click="router.push('/map')">进入监测地图 <el-icon><ArrowRight /></el-icon></el-button></header>
        <div ref="chinaMapChart" class="map-chart"></div>
        <footer><span class="map-legend-dot"></span>已登记输电节点<span class="map-count">{{ raw.nodes?.total || 0 }} 个节点</span></footer>
      </article>
      <div class="side-charts">
        <article class="analysis-panel"><header><h2>节点状态分布</h2><span>设备状态</span></header><div ref="nodeTypeChart" class="small-chart"></div></article>
        <article class="analysis-panel"><header><h2>算力平台状态</h2><span>运行资源</span></header><div ref="containerStatusChart" class="small-chart"></div></article>
      </div>
    </section>
    <article class="analysis-panel trend-panel"><header><div><h2>最近 7 天任务趋势</h2><p>每日创建任务数量</p></div><span class="period-label">近 7 天</span></header><div ref="taskTrendChart" class="trend-chart"></div></article>
  </div>
</template>

<script setup name="Dashboard">
import { ref, computed, onMounted, onActivated, onBeforeUnmount, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { DataAnalysis, Document, Cpu, Location, Refresh, Plus, ArrowRight } from '@element-plus/icons-vue'
import PageHeader from '@/components/PageHeader/index.vue'
import { getAllStatistics } from '@/api/statistics/statistics'
import * as echarts from 'echarts'
import chinaJson from '@/assets/china.json'

const router = useRouter()
const raw = ref({})
const loading = ref(false)
const loadError = ref(false)
const updatedAt = ref('')
const taskStatusChart = ref(null)
const fileTypeChart = ref(null)
const containerStatusChart = ref(null)
const nodeTypeChart = ref(null)
const chinaMapChart = ref(null)
const taskTrendChart = ref(null)
const charts = []
let resizeObserver
let themeObserver
let disposed = false
const count = (items, statuses) => (items || []).reduce((n, item) => n + (statuses.includes(String(item.status).toLowerCase()) ? Number(item.count) || 0 : 0), 0)
const metrics = computed(() => [
  { label: '检测任务', value: raw.value.tasks?.total || 0, unit: '项', detail: `${count(raw.value.tasks?.by_status, ['success', 'completed'])} 项已完成 · ${count(raw.value.tasks?.by_status, ['running', 'queued'])} 项执行中`, icon: DataAnalysis, tone: 'blue' },
  { label: '数据文件', value: raw.value.files?.total || 0, unit: '个', detail: `${raw.value.files?.image_total || 0} 个图像文件`, icon: Document, tone: 'teal' },
  { label: '算力平台', value: raw.value.containers?.total || 0, unit: '个', detail: `${count(raw.value.containers?.by_status, ['running'])} 个平台运行中`, icon: Cpu, tone: 'violet' },
  { label: '输电节点', value: raw.value.nodes?.total || 0, unit: '个', detail: `${count(raw.value.nodes?.by_status, ['online', '健康', '0'])} 个节点在线`, icon: Location, tone: 'amber' }
])
const names = { pending: '待执行', queued: '排队中', running: '运行中', success: '已完成', completed: '已完成', failed: '失败', stop: '已停止', stopped: '已停止', exited: '已停止', online: '在线', offline: '离线', '0': '在线', '1': '异常', jpg: '图像 JPG', jpeg: '图像 JPEG', png: '图像 PNG', dir: '文件夹', txt: '文本' }
const statusColor = { success: '#14b8a6', completed: '#14b8a6', running: '#3b82f6', queued: '#818cf8', pending: '#94a3b8', failed: '#ef6b73', stop: '#94a3b8', stopped: '#94a3b8', online: '#14b8a6', offline: '#ef6b73', '0': '#14b8a6', '1': '#ef6b73' }
const palette = ['#3b82f6', '#14b8a6', '#8b9cf7', '#f3b45f', '#94a3b8']
const displayName = key => names[String(key).toLowerCase().replace(/^\./, '')] || key || '未知'
const colors = () => {
  const dark = document.documentElement.classList.contains('dark')
  return { text: dark ? '#a3b2c8' : '#738198', line: dark ? '#2b3b53' : '#e9eef5', surface: dark ? '#19263a' : '#fff', foreground: dark ? '#e2ebf8' : '#172b4d' }
}
const tooltip = () => ({ backgroundColor: colors().surface, borderColor: colors().line, textStyle: { color: colors().foreground }, extraCssText: 'border-radius:8px;box-shadow:0 8px 28px rgba(15,35,65,.12);padding:12px;' })
function makeChart(el, option) {
  if (!el) return
  const chart = echarts.init(el)
  chart.setOption(option)
  charts.push(chart)
}
function makeDonut(el, list, key) {
  const data = (list || []).map((item, i) => ({ name: displayName(item[key]), value: Number(item.count) || 0, itemStyle: { color: statusColor[String(item[key]).toLowerCase()] || palette[i % palette.length] } }))
  makeChart(el, {
    tooltip: { ...tooltip(), trigger: 'item' },
    legend: { type: 'scroll', bottom: 8, left: 'center', icon: 'circle', itemWidth: 7, itemHeight: 7, itemGap: 14, textStyle: { color: colors().text, fontSize: 11 } },
    graphic: data.some(item => item.value > 0) ? [] : [{ type: 'text', left: 'center', top: '45%', style: { text: '暂无数据', fill: colors().text, fontSize: 12 } }],
    series: [{ type: 'pie', radius: ['48%', '65%'], center: ['50%', '43%'], avoidLabelOverlap: true, minAngle: 5, label: { show: false }, emphasis: { scaleSize: 4, label: { show: true, formatter: '{b}\n{c}', color: colors().foreground, fontSize: 12 } }, itemStyle: { borderColor: colors().surface, borderWidth: 3, borderRadius: 5 }, data }]
  })
}
function initCharts() {
  if (disposed) return
  charts.splice(0).forEach(chart => chart.dispose())
  makeDonut(taskStatusChart.value, raw.value.tasks?.by_status, 'status')
  makeDonut(fileTypeChart.value, raw.value.files?.by_type, 'type')
  makeDonut(containerStatusChart.value, raw.value.containers?.by_status, 'status')
  const nodes = raw.value.nodes?.by_status || []
  makeChart(nodeTypeChart.value, {
    tooltip: { ...tooltip(), trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { top: 28, left: 32, right: 22, bottom: 32, containLabel: true },
    xAxis: { type: 'category', data: nodes.map(item => displayName(item.status)), axisTick: { show: false }, axisLine: { show: false }, axisLabel: { color: colors().text, fontSize: 11 } },
    yAxis: { type: 'value', minInterval: 1, axisLabel: { color: colors().text, fontSize: 10 }, splitLine: { lineStyle: { color: colors().line, type: 'dashed' } } },
    series: [{ type: 'bar', barMaxWidth: 42, data: nodes.map(item => ({ value: item.count || 0, itemStyle: { color: statusColor[item.status] || '#3b82f6', borderRadius: [5, 5, 0, 0] } })), label: { show: true, position: 'top', color: colors().foreground } }]
  })
  if (!echarts.getMap('china')) echarts.registerMap('china', chinaJson)
  makeChart(chinaMapChart.value, {
    tooltip: { trigger: 'item', backgroundColor: '#1b304f', borderColor: '#304765', textStyle: { color: '#eef6ff' } },
    geo: { map: 'china', roam: false, top: '10%', bottom: '12%', left: '6%', right: '6%', label: { show: true, color: '#85a4c8', fontSize: 9 }, itemStyle: { areaColor: '#1e3b5b', borderColor: '#315575', borderWidth: .8 }, emphasis: { label: { color: '#fff' }, itemStyle: { areaColor: '#2a5276' } } },
    series: [{ name: '输电节点', type: 'scatter', coordinateSystem: 'geo', symbolSize: 9, itemStyle: { color: '#4dd9c6', borderColor: '#cffafe', borderWidth: 1.5, shadowBlur: 12, shadowColor: '#14b8a6' }, data: (raw.value.nodes?.locations || []).filter(item => item.longitude != null && item.latitude != null).map(item => ({ name: item.name, value: [item.longitude, item.latitude] })) }]
  })
  const counts = new Map((raw.value.tasks?.by_date || []).map(item => [item.date, item.count]))
  const days = Array.from({ length: 7 }, (_, i) => {
    const day = new Date()
    day.setDate(day.getDate() - (6 - i))
    const key = `${day.getFullYear()}-${String(day.getMonth() + 1).padStart(2, '0')}-${String(day.getDate()).padStart(2, '0')}`
    return { key, count: counts.get(key) || 0 }
  })
  makeChart(taskTrendChart.value, {
    tooltip: { ...tooltip(), trigger: 'axis' },
    grid: { left: 24, right: 24, top: 14, bottom: 18, containLabel: true },
    xAxis: { type: 'category', boundaryGap: false, data: days.map(day => day.key.slice(5)), axisTick: { show: false }, axisLine: { show: false }, axisLabel: { color: colors().text, fontSize: 11 } },
    yAxis: { type: 'value', minInterval: 1, axisLabel: { color: colors().text, fontSize: 11 }, splitLine: { lineStyle: { color: colors().line, type: 'dashed' } } },
    series: [{ name: '创建任务', type: 'line', smooth: .25, symbol: 'circle', symbolSize: 7, itemStyle: { color: '#3b82f6', borderWidth: 2, borderColor: colors().surface }, lineStyle: { width: 3 }, areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: 'rgba(59,130,246,.16)' }, { offset: 1, color: 'rgba(59,130,246,0)' }]) }, data: days.map(day => day.count) }]
  })
}
async function fetchStatistics() {
  if (loading.value) return
  loading.value = true
  loadError.value = false
  try {
    const result = await getAllStatistics()
    const data = result?.data || result
    if (!data || !data.tasks || !data.nodes) throw new Error('Invalid statistics response')
    if (disposed) return
    raw.value = data
    updatedAt.value = new Date().toLocaleTimeString('zh-CN', { hour12: false })
    await nextTick()
    initCharts()
  } catch {
    if (!disposed) loadError.value = true
  } finally { loading.value = false }
}
function resizeCharts() { charts.forEach(chart => chart.resize()) }
onMounted(() => {
  fetchStatistics()
  resizeObserver = new ResizeObserver(resizeCharts)
  ;[taskStatusChart, fileTypeChart, containerStatusChart, nodeTypeChart, chinaMapChart, taskTrendChart].forEach(el => { if (el.value) resizeObserver.observe(el.value) })
  themeObserver = new MutationObserver(initCharts)
  themeObserver.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] })
})
onActivated(() => nextTick(resizeCharts))
onBeforeUnmount(() => {
  disposed = true
  resizeObserver?.disconnect()
  themeObserver?.disconnect()
  charts.splice(0).forEach(chart => chart.dispose())
})
</script>

<style scoped lang="scss">
.inspection-overview { padding: 28px; max-width: 1920px; margin: 0 auto; }
.overview-alert { margin-bottom: 20px; }
.overview-meta { display: flex; align-items: center; gap: 7px; color: var(--grid-muted); font-size: 12px; margin: 0 0 12px; }
.meta-dot { width: 5px; height: 5px; background: #3b82f6; border-radius: 50%; }
.updated-at { margin-left: auto; font-size: 11px; }
.metrics-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 18px; margin-bottom: 24px; }
.metric-card { background: var(--grid-surface); border: 1px solid var(--grid-border); border-radius: 12px; padding: 20px 22px; box-shadow: var(--grid-shadow); }
.metric-top { display: flex; justify-content: space-between; align-items: center; color: var(--grid-muted); font-size: 13px; }
.metric-icon { width: 36px; height: 36px; border-radius: 9px; font-size: 19px; }
.blue { color: #3b82f6; background: #eff6ff; }.teal { color: #14b8a6; background: #eafaf6; }.violet { color: #8b7ee0; background: #f2efff; }.amber { color: #d9a045; background: #fff7e8; }
.metric-value { color: var(--grid-text); font-size: 34px; line-height: 1.5; font-weight: 650; font-variant-numeric: tabular-nums; letter-spacing: -1px; margin-top: 5px; span { font-size: 12px; font-weight: 400; letter-spacing: 0; color: var(--grid-muted); margin-left: 8px; } }
.metric-detail { display: flex; gap: 6px; align-items: center; margin-top: 8px; font-size: 11px; color: var(--grid-muted); }
.detail-dot { width: 5px; height: 5px; border-radius: 50%; background: currentColor; }
.chart-grid { display: grid; grid-template-columns: minmax(210px, 1fr) minmax(360px, 2fr) minmax(210px, 1fr); gap: 18px; margin-bottom: 24px; }
.side-charts { display: grid; gap: 18px; }
.analysis-panel { background: var(--grid-surface); border: 1px solid var(--grid-border); border-radius: 12px; min-width: 0; overflow: hidden; box-shadow: var(--grid-shadow); header { display: flex; justify-content: space-between; align-items: center; gap: 8px; padding: 20px 20px 4px; } h2 { font-size: 14px; color: var(--grid-text); margin: 0; font-weight: 600; } header > span, header p { color: var(--grid-muted); font-size: 10px; margin: 6px 0 0; } }
.small-chart { height: 210px; }
.map-panel { display: flex; flex-direction: column; background: #12243e; border-color: #12243e; header { padding: 22px 22px 0; align-items: flex-start; } h2 { color: #e8f1ff; margin-top: 9px; font-size: 15px; } .map-eyebrow { color: #7d9aba; font-size: 9px; letter-spacing: 1.8px; } .map-link { color: #8cacca; font-size: 11px; padding: 0; height: 20px; &:hover { background: transparent; color: #fff; } } footer { color: #8cacca; font-size: 11px; border-top: 1px solid #233953; margin: 0 22px; padding: 16px 0; display: flex; gap: 7px; align-items: center; } }
.map-chart { flex: 1; min-height: 350px; }
.map-count { margin-left: auto; }
.map-legend-dot { width: 6px; height: 6px; border-radius: 50%; background: #4dd9c6; }
.trend-panel header { padding-bottom: 15px; .period-label { background: var(--grid-soft); border: 1px solid var(--grid-border); border-radius: 5px; padding: 6px 10px; } }
.trend-chart { height: 210px; }
@media (max-width: 1300px) { .chart-grid { grid-template-columns: minmax(180px, 1fr) minmax(320px, 1.65fr) minmax(180px, 1fr); } .metric-card { padding: 18px; } .analysis-panel header { padding: 18px 16px 4px; } .analysis-panel header > span { display: none; } .map-panel header { flex-direction: column; gap: 12px; } }
@media (max-width: 1100px) { .chart-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); } .map-panel { order: -1; grid-column: 1 / -1; .map-chart { height: 380px; flex: auto; } header { flex-direction: row; } } .metrics-grid { gap: 12px; } .metric-detail { line-height: 1.6; } }
@media (max-width: 760px) { .inspection-overview { padding: 20px 14px; } .metrics-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); } .metric-value { font-size: 30px; } .chart-grid { gap: 12px; } .analysis-panel header { align-items: flex-start; } .small-chart { height: 210px; } }
@media (max-width: 420px) { .chart-grid { grid-template-columns: 1fr; } .map-panel { grid-column: 1; } .metric-card { padding: 14px; } .metric-icon { width: 28px; height: 28px; font-size: 16px; } }
</style>
