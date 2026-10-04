<template>
  <header class="page-header">
    <div>
      <div v-if="eyebrow" class="page-eyebrow">{{ eyebrow }}</div>
      <h1>{{ title }}</h1>
      <p>{{ description }}</p>
    </div>
    <div v-if="$slots.default" class="page-header-actions"><slot /></div>
  </header>
</template>

<script setup>
defineProps({
  title: { type: String, required: true },
  description: { type: String, default: '' },
  eyebrow: { type: String, default: '' }
})
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: center; gap: 20px; margin-bottom: 26px; }
.page-eyebrow { color: var(--el-color-primary); font-size: 11px; font-weight: 700; letter-spacing: 2px; margin-bottom: 8px; }
h1 { color: var(--grid-text); font-size: 26px; font-weight: 650; line-height: 1.4; margin: 0; letter-spacing: -.5px; }
p { color: var(--grid-muted); font-size: 13px; line-height: 1.7; margin: 8px 0 0; }
.page-header-actions { display: flex; align-items: center; flex-wrap: wrap; gap: 10px; }
@media (max-width: 640px) { .page-header { align-items: flex-start; flex-direction: column; } h1 { font-size: 23px; } }
</style>
