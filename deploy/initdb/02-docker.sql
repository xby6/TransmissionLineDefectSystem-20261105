-- Runs once, on an EMPTY PostgreSQL volume, after the original schema.
-- Existing deployments and restored databases are not reinitialized.
BEGIN;

DELETE FROM container;
INSERT INTO container (id, name, url, type, create_time, dept)
VALUES (1, '输电线路算法平台', 'http://algo-server:8000', 'docker', CURRENT_TIMESTAMP, 100);
SELECT setval('container_id_seq', 1, true);

ALTER TABLE task ALTER COLUMN result DROP NOT NULL;
ALTER TABLE task ALTER COLUMN state SET DEFAULT 'pending';
UPDATE sys_menu AS menu
SET menu_name=restored.title, path=restored.path, component=restored.component,
    order_num=restored.position, visible='0', status='0'
FROM (VALUES
    (5, '算力平台', 'container', 'container/container/index', 1),
    (4, '遥感数据管理', 'file', 'file/file/index', 2),
    (6, '任务管理', 'task', 'task/task/index', 3),
    (2001, '节点管理', 'node', 'node/node/index', 4),
    (2000, '监测平台', 'map', 'map/index', 5),
    (107, '通知公告', 'notice', 'system/notice/index', 6)
) AS restored(id, title, path, component, position)
WHERE menu.menu_id=restored.id;
UPDATE sys_menu SET visible='1' WHERE component LIKE 'phenotype/%';
INSERT INTO sys_menu
    (menu_id, menu_name, parent_id, order_num, path, is_frame, is_cache,
     menu_type, visible, status, perms, icon, create_by, create_time)
SELECT (SELECT COALESCE(MAX(menu_id), 0)+1 FROM sys_menu), '节点导入', 2001, 6,
       '#', 1, 0, 'F', '0', '0', 'node:node:import', '#', 'admin', CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE perms='node:node:import');
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT DISTINCT roles.role_id, imports.menu_id
FROM sys_role_menu roles CROSS JOIN sys_menu imports
WHERE roles.menu_id=2001 AND imports.perms='node:node:import'
ON CONFLICT DO NOTHING;
SELECT setval('sys_menu_menu_id_seq', (SELECT MAX(menu_id) FROM sys_menu), true);

CREATE TABLE docker_bootstrap (
    id integer PRIMARY KEY CHECK (id=1),
    admin_password_pending boolean NOT NULL
);
INSERT INTO docker_bootstrap VALUES (1, true);
COMMIT;
