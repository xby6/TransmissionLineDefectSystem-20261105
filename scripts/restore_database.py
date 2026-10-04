"""恢复说明书菜单及本地算法平台；执行前完整备份，不重建业务表。"""
import argparse
from datetime import datetime
from pathlib import Path
import os
import shutil
import subprocess
import psycopg2
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--env', default='dev')
    args = parser.parse_args()
    cfg = dotenv_values(ROOT / 'backend' / f'.env.{args.env}')
    connection = dict(host=cfg['DB_HOST'], port=cfg['DB_PORT'], user=cfg['DB_USERNAME'],
                      password=cfg['DB_PASSWORD'], dbname=cfg['DB_DATABASE'])
    backup = ROOT / 'restoration-backups' / datetime.now().strftime('%Y%m%d-%H%M%S')
    backup.mkdir(parents=True, exist_ok=True)
    pg_dump = shutil.which('pg_dump')
    if not pg_dump:
        raise RuntimeError('请将 PostgreSQL bin 目录加入 PATH，确保 pg_dump 可用')
    env = os.environ.copy()
    env['PGPASSWORD'] = connection['password']
    subprocess.run([pg_dump, '-h', connection['host'], '-p', str(connection['port']), '-U', connection['user'],
                    '-d', connection['dbname'], '-Fc', '-f', str(backup / 'database-before-restoration.dump')],
                   env=env, check=True)
    menus = [
        (5, '算力平台', 'container', 'container/container/index', 1),
        (4, '遥感数据管理', 'file', 'file/file/index', 2),
        (6, '任务管理', 'task', 'task/task/index', 3),
        (2001, '节点管理', 'node', 'node/node/index', 4),
        (2000, '监测平台', 'map', 'map/index', 5),
        (107, '通知公告', 'notice', 'system/notice/index', 6),
    ]
    with psycopg2.connect(**connection) as db:
        with db.cursor() as cur:
            cur.execute("UPDATE sys_user SET avatar='' WHERE user_name='admin' AND avatar='/profile/avatar/2026/04/14/avatar_20260414145027A144.png'")
            cur.execute('ALTER TABLE task ALTER COLUMN result DROP NOT NULL')
            cur.execute("ALTER TABLE task ALTER COLUMN state SET DEFAULT 'pending'")
            cur.execute("UPDATE task SET state='pending' WHERE state IS NULL")
            for menu_id, name, route, component, order in menus:
                cur.execute("UPDATE sys_menu SET menu_name=%s,path=%s,component=%s,order_num=%s,visible='0',status='0' WHERE menu_id=%s",
                            (name, route, component, order, menu_id))
                if cur.rowcount != 1:
                    raise RuntimeError(f'缺少原始菜单 {menu_id}，请先在空数据库导入 init.sql')
            cur.execute("UPDATE sys_menu SET visible='1' WHERE component LIKE 'phenotype/%%'")
            # 只恢复已知被改名的四条原始示例，不覆盖用户新增或重新命名的数据。
            originals = [
                (1, '玉米试验地块A', '丹东2号电力塔', 124.24, 40.07, 20, '东北玉米主产区'),
                (2, '玉米试验地块B', '丹东东港电塔', 124.454, 39.8378, 21, '华北平原玉米区'),
                (3, '玉米试验地块C', '丹东凤城东汤镇石桥线69号电塔', 124.2101, 40.3098, 22, '黄淮海区中心谷地'),
                (4, '玉米试验地块D', '丹东孔安甲乙线', 124.3631, 40.166, 23, '西南山区玉米区'),
            ]
            for node_id, old_name, name, longitude, latitude, folder_id, old_folder in originals:
                cur.execute('UPDATE node_info SET name=%s,longitude=%s,latitude=%s WHERE id=%s AND name=%s',
                            (name, longitude, latitude, node_id, old_name))
                cur.execute('UPDATE file SET name=%s WHERE id=%s AND name=%s AND type=%s',
                            (name, folder_id, old_folder, 'dir'))
            cur.execute("SELECT menu_id FROM sys_menu WHERE perms='node:node:import'")
            row = cur.fetchone()
            if row:
                import_id = row[0]
            else:
                cur.execute('SELECT COALESCE(MAX(menu_id),0)+1 FROM sys_menu')
                import_id = cur.fetchone()[0]
                cur.execute("INSERT INTO sys_menu(menu_id,menu_name,parent_id,order_num,path,is_frame,is_cache,menu_type,visible,status,perms,icon,create_by,create_time) VALUES (%s,'节点导入',2001,6,'#',1,0,'F','0','0','node:node:import','#','admin',NOW())", (import_id,))
            cur.execute("INSERT INTO sys_role_menu(role_id,menu_id) SELECT DISTINCT role_id,%s FROM sys_role_menu WHERE menu_id=2001 ON CONFLICT DO NOTHING", (import_id,))
            cur.execute("SELECT id FROM container WHERE url='http://127.0.0.1:8000'")
            if not cur.fetchone():
                cur.execute('SELECT COALESCE(MAX(id),0)+1 FROM container')
                platform_id = cur.fetchone()[0]
                cur.execute("INSERT INTO container(id,name,url,type,create_time,dept) VALUES (%s,'本地输电线路算法平台','http://127.0.0.1:8000','local',NOW(),100)", (platform_id,))
            for table, column in [('container', 'id'), ('file', 'id'), ('node_info', 'id'), ('task', 'id')]:
                cur.execute('SELECT pg_get_serial_sequence(%s,%s)', (table, column))
                seq = cur.fetchone()[0]
                if seq:
                    cur.execute(f'SELECT MAX({column}) FROM {table}')
                    maximum = cur.fetchone()[0]
                    if maximum is not None:
                        cur.execute('SELECT setval(%s, %s, true)', (seq, maximum))
    print(f'恢复完成，数据库备份：{backup}')


if __name__ == '__main__':
    main()
