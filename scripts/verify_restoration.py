"""本机真实服务验收。测试图片和成功任务保留为可预览样例。"""
from pathlib import Path
from datetime import datetime
import io
import json
import os
import time
import requests
from PIL import Image
from openpyxl import load_workbook, Workbook

ROOT = Path(__file__).resolve().parents[1]
BASE = 'http://127.0.0.1:9099'
OUT = ROOT / 'tmp' / 'restoration'
OUT.mkdir(parents=True, exist_ok=True)
report = []
session = requests.Session()


def api(method, path, **kwargs):
    response = session.request(method, BASE + path, timeout=30, **kwargs)
    response.raise_for_status()
    data = response.json()
    assert data.get('code') == 200, (path, data)
    return data


def passed(name, **details):
    report.append(dict(check=name, status='passed', **details))
    (OUT / 'verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(name, 'OK', flush=True)


def main():
    password = os.environ['RESTORE_TEST_PASSWORD']
    token = api('POST', '/login', data={'username': 'admin', 'password': password})['token']
    session.headers['Authorization'] = 'Bearer ' + token
    passed('登录')
    menus = api('GET', '/getRouters')['data']
    def menu_titles(items):
        return [title for item in items for title in
                ([item['meta']['title']] if item.get('meta') else []) + menu_titles(item.get('children') or [])]
    titles = menu_titles(menus)
    assert all(name in titles for name in ['算力平台', '遥感数据管理', '任务管理', '节点管理', '监测平台'])
    passed('输电线路菜单', titles=titles)
    for path in ['/system/user/list', '/system/role/list', '/system/menu/list', '/system/dept/list',
                 '/system/post/list', '/system/dict/type/list', '/system/config/list', '/system/notice/list',
                 '/monitor/online/list', '/monitor/server', '/monitor/operlog/list', '/monitor/logininfor/list',
                 '/monitor/job/list', '/monitor/cache']:
        api('GET', path)
    passed('系统管理与监控接口')
    platforms = api('GET', '/container/container/list', params={'pageSize': 100})['rows']
    platform = next(item for item in platforms if item['url'] == 'http://127.0.0.1:8000')
    algorithms = api('GET', '/container/container/algorithm/list', params={'container_id': platform['id']})['data']
    models = api('GET', '/container/container/model/list', params={'container_id': platform['id']})['data']
    assert '电气设备语义分割模型.pt' in models and 'best.pt' in models
    passed('算法与模型列表', algorithms=list(algorithms), models=list(models))
    name = '曝光校正与细节恢复'
    original = algorithms[name]
    api('POST', '/container/container/algorithm/metadata', data=dict(container_id=platform['id'], original_name=name,
        algo_name=name, args=original['args'], args_intro=original['args_intro'], intro=original['intro'] + ' [验收]'))
    assert api('GET', '/container/container/algorithm/list', params={'container_id': platform['id']})['data'][name]['intro'].endswith('[验收]')
    api('POST', '/container/container/algorithm/metadata', data=dict(container_id=platform['id'], original_name=name,
        algo_name=name, args=original['args'], args_intro=original['args_intro'], intro=original['intro']))
    model = 'best.pt'
    api('POST', '/container/container/model/metadata', data=dict(container_id=platform['id'], original_name=model,
        model_name=model, intro=models[model]['intro'] + ' [验收]'))
    assert api('GET', '/container/container/model/list', params={'container_id': platform['id']})['data'][model]['intro'].endswith('[验收]')
    api('POST', '/container/container/model/metadata', data=dict(container_id=platform['id'], original_name=model,
        model_name=model, intro=models[model]['intro']))
    passed('算法和模型编辑持久化')
    template = session.post(BASE + '/node/node/importTemplate', timeout=30)
    template.raise_for_status()
    headers = list(next(load_workbook(io.BytesIO(template.content)).active.values))
    assert headers == ['节点名称', '经度', '纬度', '文件夹号']
    tag = datetime.now().strftime('%H%M%S')
    node_name = '恢复验收节点_' + tag
    wb = Workbook()
    wb.active.append(headers)
    wb.active.append([node_name, 124.4, 40.1, 20])
    stream = io.BytesIO()
    wb.save(stream)
    api('POST', '/node/node/importData', files={'file': ('nodes.xlsx', stream.getvalue())})
    node = api('GET', '/node/node/list', params={'name': node_name})['rows'][0]
    assert node['dir'] == 20 and node['longitude'] == 124.4
    api('PUT', '/node/node', json=dict(id=node['id'], name=node_name, longitude=124.5, latitude=40.2, dir=20, status='0'))
    exported = session.post(BASE + '/node/node/export', data={'name': node_name}, timeout=30)
    assert load_workbook(io.BytesIO(exported.content)).active.max_row >= 2
    api('DELETE', '/node/node/' + str(node['id']))
    passed('节点导入模板、批量导入、编辑与导出')
    image = Image.open(ROOT / 'frontend/src/assets/images/login-background.jpeg').convert('RGB')
    image.thumbnail((800, 800))
    stream = io.BytesIO()
    image.save(stream, 'JPEG')
    input_name = '恢复验收输入_' + tag + '.jpg'
    api('POST', '/file/file', data=dict(name=input_name, type='image', root=20), files={'file': (input_name, stream.getvalue(), 'image/jpeg')})
    files = api('GET', '/file/file/list', params={'root': 20, 'type': 'image'})['rows']
    sample = next(item for item in files if item['name'] == input_name)
    assert sample['type'] == '.jpg'
    downloaded = session.get(BASE + '/file/file/' + str(sample['id']), timeout=30)
    assert downloaded.content == stream.getvalue()
    assert api('GET', '/file/file/list', params={'root': 0})['rows'] != files
    passed('图片上传、文件夹过滤、图像筛选及下载', file_id=sample['id'])
    jobs = [
        ('去雾恢复', {'omega': 0.95, 'size': 15}),
        ('去雨后增强处理', {'strength': 0.3}),
        ('曝光校正与细节恢复', {}),
        ('电气设备缺陷检测模型算法', {'model_name': 'best.pt', 'input_conf': 0.5}),
        ('电气设备语义分割模型算法', {'model_name': '电气设备语义分割模型.pt'}),
    ]
    for algo, parameters in jobs:
        task_name = f'恢复验收_{algo}_{tag}'
        args = {'args': [dict(parameters, file_ids=[sample['id']])]}
        api('POST', '/task/task', json=dict(name=task_name, container=platform['id'], algo=algo,
            args=json.dumps(args, ensure_ascii=False), remark='系统恢复后的真实执行验收样例'))
        task = api('GET', '/task/task/list', params={'name': task_name})['rows'][0]
        api('POST', '/task/task/process', params={'task_id': task['id']})
        deadline = time.monotonic() + 180
        while time.monotonic() < deadline:
            task = api('GET', '/task/task/' + str(task['id']))['data']
            if task['state'] in {'success', 'failed'}:
                break
            time.sleep(2)
        assert task['state'] == 'success', (algo, task['state'])
        outputs = api('GET', '/file/file/list', params={'root': task['result']})['rows']
        result_image = next(item for item in outputs if item['name'].endswith('.jpg'))
        content = session.get(BASE + '/file/file/' + str(result_image['id']), timeout=30).content
        Image.open(io.BytesIO(content)).verify()
        (OUT / (algo + '.jpg')).write_bytes(content)
        passed('任务执行：' + algo, task_id=task['id'], result_folder=task['result'], outputs=[item['name'] for item in outputs])
    stats = api('GET', '/statistics/all')['data']
    assert stats['nodes']['total'] == len(api('GET', '/node/node/list', params={'pageSize': 1000})['rows'])
    assert stats['files']['image_total'] > 0
    assert sum(item['count'] for item in stats['tasks']['by_date']) >= len(jobs)
    passed('真实首页统计', statistics=stats)


if __name__ == '__main__':
    main()
