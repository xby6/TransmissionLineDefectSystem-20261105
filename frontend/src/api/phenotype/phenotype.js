import request from '@/utils/request'

// 查询玉米表型数据列表
export function listPhenotype(query) {
  return request({
    url: '/phenotype/phenotype/list',
    method: 'get',
    params: query
  })
}

// 查询玉米表型数据详细
export function getPhenotype(phenotypeId) {
  return request({
    url: '/phenotype/phenotype/' + phenotypeId,
    method: 'get'
  })
}

// 新增玉米表型数据
export function addPhenotype(data) {
  return request({
    url: '/phenotype/phenotype',
    method: 'post',
    data
  })
}

// 修改玉米表型数据
export function updatePhenotype(data) {
  return request({
    url: '/phenotype/phenotype',
    method: 'put',
    data
  })
}

// 删除玉米表型数据
export function delPhenotype(phenotypeId) {
  return request({
    url: '/phenotype/phenotype/' + phenotypeId,
    method: 'delete'
  })
}

// 导入玉米表型Excel数据
export function importPhenotypeData(data) {
  return request({
    url: '/phenotype/phenotype/importData',
    method: 'post',
    data,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}
