"""Verify invalid parameters, real failure reporting, and cancellation."""
import os
import json
import time
from datetime import datetime
from pathlib import Path
import requests

base = 'http://127.0.0.1:9099'
s = requests.Session()
r = s.post(base + '/login', data={'username':'admin','password':os.environ['RESTORE_TEST_PASSWORD']}).json()
s.headers['Authorization'] = 'Bearer ' + r['token']
platform = next(p for p in s.get(base + '/container/container/list').json()['rows'] if p['url']=='http://127.0.0.1:8000')
sample = next(f for f in s.get(base + '/file/file/list',params={'root':20,'type':'image'}).json()['rows'] if f['name']=='恢复验收输入_184235.jpg')
created = []
report = []
tag = datetime.now().strftime('%H%M%S')

def create(name, algo, args):
    name += '_' + tag
    payload = dict(name=name,container=platform['id'],algo=algo,args=json.dumps({'args':args}),remark='任务状态专项验收临时数据')
    assert s.post(base + '/task/task',json=payload).json()['code']==200
    task = next(t for t in s.get(base + '/task/task/list',params={'name':name}).json()['rows'] if t['name']==name)
    created.append(task['id'])
    return task['id']

def state(task_id):
    return s.get(base + '/task/task/'+str(task_id)).json()['data']['state']

try:
    invalid = create('状态验收_空参数','去雾恢复',[])
    assert s.post(base+'/task/task/process',params={'task_id':invalid}).json()['code']!=200
    assert state(invalid)=='pending'
    report.append('Empty input rejected; pending state preserved')
    failed = create('状态验收_不存在算法','恢复验收不存在的算法',[{'file_ids':[sample['id']]}])
    assert s.post(base+'/task/task/process',params={'task_id':failed}).json()['code']==200
    deadline = time.monotonic()+30
    while state(failed)!='failed' and time.monotonic()<deadline: time.sleep(.5)
    assert state(failed)=='failed'
    report.append('Algorithm failure persisted as failed')
    cancel = create('状态验收_停止任务','去雾恢复',[{'file_ids':[sample['id']]} for _ in range(10)])
    assert s.post(base+'/task/task/process',params={'task_id':cancel}).json()['code']==200
    deadline=time.monotonic()+20
    while str(cancel) not in requests.get('http://127.0.0.1:8000/running-tasks').json()['running_tasks'] and time.monotonic()<deadline: time.sleep(.2)
    result=s.post(base+'/task/task/stop',params={'task_id':cancel},timeout=15).json()
    assert result['code']==200,result
    time.sleep(2)
    assert state(cancel)=='stop'
    report.append('Running task cancelled and stop state preserved')
finally:
    for task_id in created:
        if state(task_id) not in {'running','queued'}:
            s.delete(base+'/task/task/'+str(task_id))
Path('tmp/restoration/task-state-verification.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
for item in report: print(item)
