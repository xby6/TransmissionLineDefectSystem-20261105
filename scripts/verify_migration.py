"""Read-only service checks and isolated Git bundle recovery verification."""
from pathlib import Path
import hashlib, io, json, os, subprocess
from datetime import datetime
import requests
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    backup = Path(os.environ['MIGRATION_BACKUP_DIR']).resolve()
    original = Path(os.environ['MIGRATION_ORIGINAL_DIR']).resolve()
    report = {'time': datetime.now().isoformat(), 'project': str(ROOT), 'checks': []}
    def passed(check, **details):
        report['checks'].append(dict(check=check, status='passed', **details))
        print(check, 'OK', flush=True)
    s = requests.Session()
    s.trust_env = False
    for port, path in ((8000, '/list'), (9099, '/docs'), (8088, '/index')):
        s.get(f'http://127.0.0.1:{port}{path}', timeout=30).raise_for_status()
    passed('New checkout services')
    response = s.post('http://127.0.0.1:9099/login', data={'username':'admin','password':os.environ['RESTORE_TEST_PASSWORD']}, timeout=30)
    response.raise_for_status()
    login = response.json()
    assert login['code'] == 200
    s.headers['Authorization'] = 'Bearer '+login['token']
    def api(path, **kwargs):
        r = s.get('http://127.0.0.1:9099'+path, timeout=30, **kwargs)
        r.raise_for_status()
        data = r.json()
        assert data['code'] == 200, path
        return data
    menus = api('/getRouters')['data']
    passed('Login and menus', top_level_menus=len(menus))
    tasks = api('/task/task/list', params={'pageSize':100})['rows']
    assert len(tasks) == 6 and all(t['state'] == 'success' for t in tasks)
    passed('Existing six successful tasks', tasks=[{'id':t['id'],'state':t['state']} for t in tasks])
    nodes = api('/node/node/list')['rows']
    assert len(nodes) == 4
    passed('Four preserved power tower nodes')
    files = api('/file/file/list', params={'type':'image','pageSize':1000})['rows']
    assert files
    for file in files:
        r = s.get('http://127.0.0.1:9099/file/file/'+str(file['id']), timeout=30)
        r.raise_for_status()
        Image.open(io.BytesIO(r.content)).verify()
    passed('Image download from relocated data', count=len(files))
    models = ROOT/'Intelligent Detection System for Transmission Line Defects-server/model'
    hashes = {}
    for p in models.glob('*.pt'):
        assert sha(p) == sha(original/p.relative_to(ROOT))
        hashes[p.name] = sha(p)
    assert len(hashes) == 2
    passed('Original model weight hashes', sha256=hashes)
    bundle = backup/'restored-system.git.bundle'
    subprocess.run(['git','bundle','verify',str(bundle)], cwd=ROOT, check=True, capture_output=True)
    subprocess.run(['git','fsck','--full'], cwd=ROOT, check=True, capture_output=True)
    probe = backup/'recovery-test'
    if probe.exists():
        raise RuntimeError('Recovery probe already exists; choose a fresh backup directory')
    subprocess.run(['git','clone','-q','-c','core.autocrlf=false',str(bundle),str(probe)], check=True)
    subprocess.run(['git','checkout','-q','pdf-restored-v1.2.0-clean'], cwd=probe, check=True)
    passed('Whole repository recovered from external bundle')
    sample = probe/'backend/server.py'
    before = sha(sample)
    assert sample.resolve().is_relative_to(probe.resolve())
    sample.unlink()
    assert not sample.exists()
    subprocess.run(['git','restore','--source=pdf-restored-v1.2.0-clean','--','backend/server.py'], cwd=probe, check=True)
    assert sha(sample) == before == sha(ROOT/'backend/server.py')
    for p in models.glob('*.pt'):
        assert sha(probe/p.relative_to(ROOT)) == hashes[p.name]
    passed('Deleted code restored exactly, models also recovered', sha256=before)
    report['clean_commit'] = subprocess.check_output(['git','rev-parse','pdf-restored-v1.2.0-clean^{commit}'], cwd=ROOT, text=True).strip()
    (backup/'migration-verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2),encoding='utf-8')
    print('All migration checks passed', flush=True)

if __name__ == '__main__':
    main()
