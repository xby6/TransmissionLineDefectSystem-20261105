/*
 Navicat Premium Dump SQL

 Source Server         : ygypsql
 Source Server Type    : PostgreSQL
 Source Server Version : 150015 (150015)
 Source Host           : localhost:5432
 Source Catalog        : init
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 150015 (150015)
 File Encoding         : 65001

 Date: 09/04/2026 14:42:22
*/


-- ----------------------------
-- Sequence structure for container_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."container_id_seq";
CREATE SEQUENCE "public"."container_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for file_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."file_id_seq";
CREATE SEQUENCE "public"."file_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gen_table_column_column_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gen_table_column_column_id_seq";
CREATE SEQUENCE "public"."gen_table_column_column_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for gen_table_table_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."gen_table_table_id_seq";
CREATE SEQUENCE "public"."gen_table_table_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for node_info_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."node_info_id_seq";
CREATE SEQUENCE "public"."node_info_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_config_config_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_config_config_id_seq";
CREATE SEQUENCE "public"."sys_config_config_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dept_dept_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dept_dept_id_seq";
CREATE SEQUENCE "public"."sys_dept_dept_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dict_data_dict_code_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dict_data_dict_code_seq";
CREATE SEQUENCE "public"."sys_dict_data_dict_code_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_dict_type_dict_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_dict_type_dict_id_seq";
CREATE SEQUENCE "public"."sys_dict_type_dict_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_job_job_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_job_job_id_seq";
CREATE SEQUENCE "public"."sys_job_job_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_job_log_job_log_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_job_log_job_log_id_seq";
CREATE SEQUENCE "public"."sys_job_log_job_log_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_logininfor_info_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_logininfor_info_id_seq";
CREATE SEQUENCE "public"."sys_logininfor_info_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_menu_menu_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_menu_menu_id_seq";
CREATE SEQUENCE "public"."sys_menu_menu_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_notice_notice_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_notice_notice_id_seq";
CREATE SEQUENCE "public"."sys_notice_notice_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_oper_log_oper_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_oper_log_oper_id_seq";
CREATE SEQUENCE "public"."sys_oper_log_oper_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_post_post_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_post_post_id_seq";
CREATE SEQUENCE "public"."sys_post_post_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_role_role_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_role_role_id_seq";
CREATE SEQUENCE "public"."sys_role_role_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_user_user_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_user_user_id_seq";
CREATE SEQUENCE "public"."sys_user_user_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for task_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."task_id_seq";
CREATE SEQUENCE "public"."task_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Table structure for apscheduler_jobs
-- ----------------------------
DROP TABLE IF EXISTS "public"."apscheduler_jobs";
CREATE TABLE "public"."apscheduler_jobs" (
  "id" varchar(191) COLLATE "pg_catalog"."default" NOT NULL,
  "next_run_time" float8,
  "job_state" bytea NOT NULL
)
;

-- ----------------------------
-- Records of apscheduler_jobs
-- ----------------------------

-- ----------------------------
-- Table structure for container
-- ----------------------------
DROP TABLE IF EXISTS "public"."container";
CREATE TABLE "public"."container" (
  "id" int4 NOT NULL DEFAULT nextval('container_id_seq'::regclass),
  "name" varchar COLLATE "pg_catalog"."default" NOT NULL,
  "url" varchar COLLATE "pg_catalog"."default" NOT NULL,
  "type" varchar COLLATE "pg_catalog"."default",
  "create_time" timestamp(0),
  "dept" int4
)
;
COMMENT ON COLUMN "public"."container"."id" IS '容器唯一标识';
COMMENT ON COLUMN "public"."container"."name" IS '容器名称';
COMMENT ON COLUMN "public"."container"."url" IS '容器URL';
COMMENT ON COLUMN "public"."container"."type" IS '容器类型';
COMMENT ON COLUMN "public"."container"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."container"."dept" IS '所属部门ID';
COMMENT ON TABLE "public"."container" IS '容器表';

-- ----------------------------
-- Records of container
-- ----------------------------
INSERT INTO "public"."container" VALUES (20, 'test', 'http://10.43.12.149:4101', NULL, '2026-01-19 15:10:14', 100);

-- ----------------------------
-- Table structure for file
-- ----------------------------
DROP TABLE IF EXISTS "public"."file";
CREATE TABLE "public"."file" (
  "id" int4 NOT NULL DEFAULT nextval('file_id_seq'::regclass),
  "name" varchar COLLATE "pg_catalog"."default",
  "path" varchar COLLATE "pg_catalog"."default",
  "type" varchar COLLATE "pg_catalog"."default",
  "size" float8,
  "root" int4 NOT NULL,
  "upload_time" timestamp(0),
  "dept" int4
)
;
COMMENT ON COLUMN "public"."file"."id" IS '文件唯一标识';
COMMENT ON COLUMN "public"."file"."name" IS '文件名';
COMMENT ON COLUMN "public"."file"."path" IS '文件路径';
COMMENT ON COLUMN "public"."file"."type" IS '文件类型';
COMMENT ON COLUMN "public"."file"."size" IS '文件大小';
COMMENT ON COLUMN "public"."file"."root" IS '父文件ID, 用于文件夹结构';
COMMENT ON COLUMN "public"."file"."upload_time" IS '上传时间';
COMMENT ON COLUMN "public"."file"."dept" IS '所属小组ID';
COMMENT ON TABLE "public"."file" IS '文件表';

-- ----------------------------
-- Records of file
-- ----------------------------
INSERT INTO "public"."file" VALUES (21, '丹东东港电塔', NULL, 'dir', NULL, 0, '2026-01-19 15:02:43', 100);
INSERT INTO "public"."file" VALUES (22, '丹东凤城东汤镇石桥线69号电塔', NULL, 'dir', NULL, 0, '2026-01-19 15:03:09', 100);
INSERT INTO "public"."file" VALUES (23, '丹东孔安甲乙线', NULL, 'dir', NULL, 0, '2026-01-19 15:03:30', 100);
INSERT INTO "public"."file" VALUES (20, '丹东2号电力塔', NULL, 'dir', NULL, 0, '2026-01-19 15:00:51', 100);

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS "public"."gen_table";
CREATE TABLE "public"."gen_table" (
  "table_id" int8 NOT NULL DEFAULT nextval('gen_table_table_id_seq'::regclass),
  "table_name" varchar(200) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "table_comment" varchar(500) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "sub_table_name" varchar(64) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "sub_table_fk_name" varchar(64) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "class_name" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "tpl_category" varchar(200) COLLATE "pg_catalog"."default" DEFAULT 'crud'::character varying,
  "tpl_web_type" varchar(30) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "package_name" varchar(100) COLLATE "pg_catalog"."default",
  "module_name" varchar(30) COLLATE "pg_catalog"."default",
  "business_name" varchar(30) COLLATE "pg_catalog"."default",
  "function_name" varchar(50) COLLATE "pg_catalog"."default",
  "function_author" varchar(50) COLLATE "pg_catalog"."default",
  "gen_type" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "gen_path" varchar(200) COLLATE "pg_catalog"."default" DEFAULT '/'::character varying,
  "options" varchar(1000) COLLATE "pg_catalog"."default",
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."gen_table"."table_id" IS '编号';
COMMENT ON COLUMN "public"."gen_table"."table_name" IS '表名称';
COMMENT ON COLUMN "public"."gen_table"."table_comment" IS '表描述';
COMMENT ON COLUMN "public"."gen_table"."sub_table_name" IS '关联子表的表名';
COMMENT ON COLUMN "public"."gen_table"."sub_table_fk_name" IS '子表关联的外键名';
COMMENT ON COLUMN "public"."gen_table"."class_name" IS '实体类名称';
COMMENT ON COLUMN "public"."gen_table"."tpl_category" IS '使用的模板（crud单表操作 tree树表操作）';
COMMENT ON COLUMN "public"."gen_table"."tpl_web_type" IS '前端模板类型（element-ui模版 element-plus模版）';
COMMENT ON COLUMN "public"."gen_table"."package_name" IS '生成包路径';
COMMENT ON COLUMN "public"."gen_table"."module_name" IS '生成模块名';
COMMENT ON COLUMN "public"."gen_table"."business_name" IS '生成业务名';
COMMENT ON COLUMN "public"."gen_table"."function_name" IS '生成功能名';
COMMENT ON COLUMN "public"."gen_table"."function_author" IS '生成功能作者';
COMMENT ON COLUMN "public"."gen_table"."gen_type" IS '生成代码方式（0zip压缩包 1自定义路径）';
COMMENT ON COLUMN "public"."gen_table"."gen_path" IS '生成路径（不填默认项目路径）';
COMMENT ON COLUMN "public"."gen_table"."options" IS '其它生成选项';
COMMENT ON COLUMN "public"."gen_table"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."gen_table"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."gen_table"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."gen_table"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."gen_table"."remark" IS '备注';
COMMENT ON TABLE "public"."gen_table" IS '代码生成业务表';

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS "public"."gen_table_column";
CREATE TABLE "public"."gen_table_column" (
  "column_id" int8 NOT NULL DEFAULT nextval('gen_table_column_column_id_seq'::regclass),
  "table_id" int8,
  "column_name" varchar(200) COLLATE "pg_catalog"."default",
  "column_comment" varchar(500) COLLATE "pg_catalog"."default",
  "column_type" varchar(100) COLLATE "pg_catalog"."default",
  "python_type" varchar(500) COLLATE "pg_catalog"."default",
  "python_field" varchar(200) COLLATE "pg_catalog"."default",
  "is_pk" char(1) COLLATE "pg_catalog"."default",
  "is_increment" char(1) COLLATE "pg_catalog"."default",
  "is_required" char(1) COLLATE "pg_catalog"."default",
  "is_unique" char(1) COLLATE "pg_catalog"."default",
  "is_insert" char(1) COLLATE "pg_catalog"."default",
  "is_edit" char(1) COLLATE "pg_catalog"."default",
  "is_list" char(1) COLLATE "pg_catalog"."default",
  "is_query" char(1) COLLATE "pg_catalog"."default",
  "query_type" varchar(200) COLLATE "pg_catalog"."default" DEFAULT 'EQ'::character varying,
  "html_type" varchar(200) COLLATE "pg_catalog"."default",
  "dict_type" varchar(200) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "sort" int4,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0)
)
;
COMMENT ON COLUMN "public"."gen_table_column"."column_id" IS '编号';
COMMENT ON COLUMN "public"."gen_table_column"."table_id" IS '归属表编号';
COMMENT ON COLUMN "public"."gen_table_column"."column_name" IS '列名称';
COMMENT ON COLUMN "public"."gen_table_column"."column_comment" IS '列描述';
COMMENT ON COLUMN "public"."gen_table_column"."column_type" IS '列类型';
COMMENT ON COLUMN "public"."gen_table_column"."python_type" IS 'PYTHON类型';
COMMENT ON COLUMN "public"."gen_table_column"."python_field" IS 'PYTHON字段名';
COMMENT ON COLUMN "public"."gen_table_column"."is_pk" IS '是否主键（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_increment" IS '是否自增（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_required" IS '是否必填（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_unique" IS '是否唯一（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_insert" IS '是否为插入字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_edit" IS '是否编辑字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_list" IS '是否列表字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_query" IS '是否查询字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."query_type" IS '查询方式（等于、不等于、大于、小于、范围）';
COMMENT ON COLUMN "public"."gen_table_column"."html_type" IS '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）';
COMMENT ON COLUMN "public"."gen_table_column"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."gen_table_column"."sort" IS '排序';
COMMENT ON COLUMN "public"."gen_table_column"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."gen_table_column"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."gen_table_column"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."gen_table_column"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."gen_table_column" IS '代码生成业务表字段';

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for node_info
-- ----------------------------
DROP TABLE IF EXISTS "public"."node_info";
CREATE TABLE "public"."node_info" (
  "id" int4 NOT NULL DEFAULT nextval('node_info_id_seq'::regclass),
  "name" varchar COLLATE "pg_catalog"."default",
  "longitude" float8,
  "latitude" float8,
  "create_time" timestamp(6),
  "status" varchar COLLATE "pg_catalog"."default",
  "dir" int4
)
;
COMMENT ON COLUMN "public"."node_info"."id" IS 'ID';
COMMENT ON COLUMN "public"."node_info"."name" IS '节点名';
COMMENT ON COLUMN "public"."node_info"."longitude" IS '经度';
COMMENT ON COLUMN "public"."node_info"."latitude" IS '纬度';
COMMENT ON COLUMN "public"."node_info"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."node_info"."status" IS '状态';
COMMENT ON COLUMN "public"."node_info"."dir" IS '关联文件夹ID';

-- ----------------------------
-- Records of node_info
-- ----------------------------
INSERT INTO "public"."node_info" VALUES (1, '丹东2号电力塔', 124.24, 40.07, '2026-01-19 15:00:51.236884', '0', 20);
INSERT INTO "public"."node_info" VALUES (2, '丹东东港电塔', 124.454, 39.8378, '2026-01-19 15:02:42.540802', '0', 21);
INSERT INTO "public"."node_info" VALUES (3, '丹东凤城东汤镇石桥线69号电塔', 124.2101, 40.3098, '2026-01-19 15:03:09.402921', '0', 22);
INSERT INTO "public"."node_info" VALUES (4, '丹东孔安甲乙线', 124.3631, 40.166, '2026-01-19 15:03:29.84169', '0', 23);

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_config";
CREATE TABLE "public"."sys_config" (
  "config_id" int4 NOT NULL DEFAULT nextval('sys_config_config_id_seq'::regclass),
  "config_name" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "config_key" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "config_value" varchar(500) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "config_type" char(1) COLLATE "pg_catalog"."default" DEFAULT 'N'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_config"."config_id" IS '参数主键';
COMMENT ON COLUMN "public"."sys_config"."config_name" IS '参数名称';
COMMENT ON COLUMN "public"."sys_config"."config_key" IS '参数键名';
COMMENT ON COLUMN "public"."sys_config"."config_value" IS '参数键值';
COMMENT ON COLUMN "public"."sys_config"."config_type" IS '系统内置（Y是 N否）';
COMMENT ON COLUMN "public"."sys_config"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_config"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_config"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_config"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_config"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_config" IS '参数配置表';

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO "public"."sys_config" VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-01-14 12:35:27', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO "public"."sys_config" VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-01-14 12:35:27', '', NULL, '初始化密码 123456');
INSERT INTO "public"."sys_config" VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-01-14 12:35:27', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO "public"."sys_config" VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'false', 'Y', 'admin', '2026-01-14 12:35:27', '', NULL, '是否开启验证码功能（true开启，false关闭）');
INSERT INTO "public"."sys_config" VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-01-14 12:35:27', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO "public"."sys_config" VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-01-14 12:35:27', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dept";
CREATE TABLE "public"."sys_dept" (
  "dept_id" int8 NOT NULL DEFAULT nextval('sys_dept_dept_id_seq'::regclass),
  "parent_id" int8 DEFAULT 0,
  "ancestors" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dept_name" varchar(30) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "order_num" int4 DEFAULT 0,
  "leader" varchar(20) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "phone" varchar(11) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "email" varchar(50) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "del_flag" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0)
)
;
COMMENT ON COLUMN "public"."sys_dept"."dept_id" IS '小组id';
COMMENT ON COLUMN "public"."sys_dept"."parent_id" IS '父小组id';
COMMENT ON COLUMN "public"."sys_dept"."ancestors" IS '祖级列表';
COMMENT ON COLUMN "public"."sys_dept"."dept_name" IS '小组名称';
COMMENT ON COLUMN "public"."sys_dept"."order_num" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_dept"."leader" IS '负责人';
COMMENT ON COLUMN "public"."sys_dept"."phone" IS '联系电话';
COMMENT ON COLUMN "public"."sys_dept"."email" IS '邮箱';
COMMENT ON COLUMN "public"."sys_dept"."status" IS '小组状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dept"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_dept"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dept"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dept"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dept"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."sys_dept" IS '小组表';

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO "public"."sys_dept" VALUES (100, 0, '0', '项目组', 0, '负责人', '15888888888', 'niangao@qq.com', '0', '0', 'admin', '2026-01-14 12:35:27', '', NULL);
INSERT INTO "public"."sys_dept" VALUES (101, 100, '0,100', '小组1', 1, '小组1负责人', '15888888888', 'niangao@qq.com', '0', '0', 'admin', '2026-01-14 12:35:27', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dict_data";
CREATE TABLE "public"."sys_dict_data" (
  "dict_code" int8 NOT NULL DEFAULT nextval('sys_dict_data_dict_code_seq'::regclass),
  "dict_sort" int4 DEFAULT 0,
  "dict_label" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dict_value" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dict_type" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "css_class" varchar(100) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "list_class" varchar(100) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "is_default" char(1) COLLATE "pg_catalog"."default" DEFAULT 'N'::bpchar,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_dict_data"."dict_code" IS '字典编码';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_sort" IS '字典排序';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_label" IS '字典标签';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_value" IS '字典键值';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."sys_dict_data"."css_class" IS '样式属性（其他样式扩展）';
COMMENT ON COLUMN "public"."sys_dict_data"."list_class" IS '表格回显样式';
COMMENT ON COLUMN "public"."sys_dict_data"."is_default" IS '是否默认（Y是 N否）';
COMMENT ON COLUMN "public"."sys_dict_data"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dict_data"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dict_data"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dict_data"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dict_data"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dict_data"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_dict_data" IS '字典数据表';

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO "public"."sys_dict_data" VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '性别男');
INSERT INTO "public"."sys_dict_data" VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '性别女');
INSERT INTO "public"."sys_dict_data" VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '性别未知');
INSERT INTO "public"."sys_dict_data" VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '显示菜单');
INSERT INTO "public"."sys_dict_data" VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '隐藏菜单');
INSERT INTO "public"."sys_dict_data" VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '正常状态');
INSERT INTO "public"."sys_dict_data" VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '停用状态');
INSERT INTO "public"."sys_dict_data" VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '正常状态');
INSERT INTO "public"."sys_dict_data" VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '停用状态');
INSERT INTO "public"."sys_dict_data" VALUES (10, 1, '默认', 'default', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '默认分组');
INSERT INTO "public"."sys_dict_data" VALUES (11, 2, '数据库', 'sqlalchemy', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '数据库分组');
INSERT INTO "public"."sys_dict_data" VALUES (12, 3, 'redis', 'redis', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, 'reids分组');
INSERT INTO "public"."sys_dict_data" VALUES (13, 1, '默认', 'default', 'sys_job_executor', '', '', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '线程池');
INSERT INTO "public"."sys_dict_data" VALUES (14, 2, '进程池', 'processpool', 'sys_job_executor', '', '', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '进程池');
INSERT INTO "public"."sys_dict_data" VALUES (15, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '系统默认是');
INSERT INTO "public"."sys_dict_data" VALUES (16, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '系统默认否');
INSERT INTO "public"."sys_dict_data" VALUES (17, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '通知');
INSERT INTO "public"."sys_dict_data" VALUES (18, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '公告');
INSERT INTO "public"."sys_dict_data" VALUES (19, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '正常状态');
INSERT INTO "public"."sys_dict_data" VALUES (20, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '关闭状态');
INSERT INTO "public"."sys_dict_data" VALUES (21, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '其他操作');
INSERT INTO "public"."sys_dict_data" VALUES (22, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '新增操作');
INSERT INTO "public"."sys_dict_data" VALUES (23, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '修改操作');
INSERT INTO "public"."sys_dict_data" VALUES (24, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '删除操作');
INSERT INTO "public"."sys_dict_data" VALUES (25, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '授权操作');
INSERT INTO "public"."sys_dict_data" VALUES (26, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '导出操作');
INSERT INTO "public"."sys_dict_data" VALUES (27, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '导入操作');
INSERT INTO "public"."sys_dict_data" VALUES (28, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '强退操作');
INSERT INTO "public"."sys_dict_data" VALUES (29, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '生成操作');
INSERT INTO "public"."sys_dict_data" VALUES (30, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '清空操作');
INSERT INTO "public"."sys_dict_data" VALUES (31, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '正常状态');
INSERT INTO "public"."sys_dict_data" VALUES (32, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '停用状态');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dict_type";
CREATE TABLE "public"."sys_dict_type" (
  "dict_id" int8 NOT NULL DEFAULT nextval('sys_dict_type_dict_id_seq'::regclass),
  "dict_name" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dict_type" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_dict_type"."dict_id" IS '字典主键';
COMMENT ON COLUMN "public"."sys_dict_type"."dict_name" IS '字典名称';
COMMENT ON COLUMN "public"."sys_dict_type"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."sys_dict_type"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dict_type"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dict_type"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dict_type"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dict_type"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dict_type"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_dict_type" IS '字典类型表';

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO "public"."sys_dict_type" VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '用户性别列表');
INSERT INTO "public"."sys_dict_type" VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '菜单状态列表');
INSERT INTO "public"."sys_dict_type" VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '系统开关列表');
INSERT INTO "public"."sys_dict_type" VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '任务状态列表');
INSERT INTO "public"."sys_dict_type" VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '任务分组列表');
INSERT INTO "public"."sys_dict_type" VALUES (6, '任务执行器', 'sys_job_executor', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '任务执行器列表');
INSERT INTO "public"."sys_dict_type" VALUES (7, '系统是否', 'sys_yes_no', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '系统是否列表');
INSERT INTO "public"."sys_dict_type" VALUES (8, '通知类型', 'sys_notice_type', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '通知类型列表');
INSERT INTO "public"."sys_dict_type" VALUES (9, '通知状态', 'sys_notice_status', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '通知状态列表');
INSERT INTO "public"."sys_dict_type" VALUES (10, '操作类型', 'sys_oper_type', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '操作类型列表');
INSERT INTO "public"."sys_dict_type" VALUES (11, '系统状态', 'sys_common_status', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '登录状态列表');

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_job";
CREATE TABLE "public"."sys_job" (
  "job_id" int8 NOT NULL DEFAULT nextval('sys_job_job_id_seq'::regclass),
  "job_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::character varying,
  "job_group" varchar(64) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'default'::character varying,
  "job_executor" varchar(64) COLLATE "pg_catalog"."default" DEFAULT 'default'::character varying,
  "invoke_target" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "job_args" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "job_kwargs" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "cron_expression" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "misfire_policy" varchar(20) COLLATE "pg_catalog"."default" DEFAULT '3'::character varying,
  "concurrent" char(1) COLLATE "pg_catalog"."default" DEFAULT '1'::bpchar,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT ''::character varying
)
;
COMMENT ON COLUMN "public"."sys_job"."job_id" IS '任务ID';
COMMENT ON COLUMN "public"."sys_job"."job_name" IS '任务名称';
COMMENT ON COLUMN "public"."sys_job"."job_group" IS '任务组名';
COMMENT ON COLUMN "public"."sys_job"."job_executor" IS '任务执行器';
COMMENT ON COLUMN "public"."sys_job"."invoke_target" IS '调用目标字符串';
COMMENT ON COLUMN "public"."sys_job"."job_args" IS '位置参数';
COMMENT ON COLUMN "public"."sys_job"."job_kwargs" IS '关键字参数';
COMMENT ON COLUMN "public"."sys_job"."cron_expression" IS 'cron执行表达式';
COMMENT ON COLUMN "public"."sys_job"."misfire_policy" IS '计划执行错误策略（1立即执行 2执行一次 3放弃执行）';
COMMENT ON COLUMN "public"."sys_job"."concurrent" IS '是否并发执行（0允许 1禁止）';
COMMENT ON COLUMN "public"."sys_job"."status" IS '状态（0正常 1暂停）';
COMMENT ON COLUMN "public"."sys_job"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_job"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_job"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_job"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_job"."remark" IS '备注信息';
COMMENT ON TABLE "public"."sys_job" IS '定时任务调度表';

-- ----------------------------
-- Records of sys_job
-- ----------------------------

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_job_log";
CREATE TABLE "public"."sys_job_log" (
  "job_log_id" int8 NOT NULL DEFAULT nextval('sys_job_log_job_log_id_seq'::regclass),
  "job_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "job_group" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "job_executor" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "invoke_target" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
  "job_args" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "job_kwargs" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "job_trigger" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "job_message" varchar(500) COLLATE "pg_catalog"."default",
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "exception_info" varchar(2000) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0)
)
;
COMMENT ON COLUMN "public"."sys_job_log"."job_log_id" IS '任务日志ID';
COMMENT ON COLUMN "public"."sys_job_log"."job_name" IS '任务名称';
COMMENT ON COLUMN "public"."sys_job_log"."job_group" IS '任务组名';
COMMENT ON COLUMN "public"."sys_job_log"."job_executor" IS '任务执行器';
COMMENT ON COLUMN "public"."sys_job_log"."invoke_target" IS '调用目标字符串';
COMMENT ON COLUMN "public"."sys_job_log"."job_args" IS '位置参数';
COMMENT ON COLUMN "public"."sys_job_log"."job_kwargs" IS '关键字参数';
COMMENT ON COLUMN "public"."sys_job_log"."job_trigger" IS '任务触发器';
COMMENT ON COLUMN "public"."sys_job_log"."job_message" IS '日志信息';
COMMENT ON COLUMN "public"."sys_job_log"."status" IS '执行状态（0正常 1失败）';
COMMENT ON COLUMN "public"."sys_job_log"."exception_info" IS '异常信息';
COMMENT ON COLUMN "public"."sys_job_log"."create_time" IS '创建时间';
COMMENT ON TABLE "public"."sys_job_log" IS '定时任务调度日志表';

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_logininfor";
CREATE TABLE "public"."sys_logininfor" (
  "info_id" int8 NOT NULL DEFAULT nextval('sys_logininfor_info_id_seq'::regclass),
  "user_name" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "ipaddr" varchar(128) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "login_location" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "browser" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "os" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "msg" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "login_time" timestamp(0)
)
;
COMMENT ON COLUMN "public"."sys_logininfor"."info_id" IS '访问ID';
COMMENT ON COLUMN "public"."sys_logininfor"."user_name" IS '用户账号';
COMMENT ON COLUMN "public"."sys_logininfor"."ipaddr" IS '登录IP地址';
COMMENT ON COLUMN "public"."sys_logininfor"."login_location" IS '登录地点';
COMMENT ON COLUMN "public"."sys_logininfor"."browser" IS '浏览器类型';
COMMENT ON COLUMN "public"."sys_logininfor"."os" IS '操作系统';
COMMENT ON COLUMN "public"."sys_logininfor"."status" IS '登录状态（0成功 1失败）';
COMMENT ON COLUMN "public"."sys_logininfor"."msg" IS '提示消息';
COMMENT ON COLUMN "public"."sys_logininfor"."login_time" IS '访问时间';
COMMENT ON TABLE "public"."sys_logininfor" IS '系统访问记录';

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO "public"."sys_logininfor" VALUES (100, 'admin', '', '未知', 'Edge 143', 'Windows 10', '1', 'password cannot be longer than 72 bytes, truncate manually if necessary (e.g. my_password[:72])', '2026-01-15 14:36:41');
INSERT INTO "public"."sys_logininfor" VALUES (101, 'admin', '', '未知', 'Edge 143', 'Windows 10', '1', 'password cannot be longer than 72 bytes, truncate manually if necessary (e.g. my_password[:72])', '2026-01-15 14:36:47');
INSERT INTO "public"."sys_logininfor" VALUES (102, 'admin', '', '未知', 'Edge 143', 'Windows 10', '1', 'password cannot be longer than 72 bytes, truncate manually if necessary (e.g. my_password[:72])', '2026-01-15 14:39:35');
INSERT INTO "public"."sys_logininfor" VALUES (103, 'admin', '', '未知', 'Edge 143', 'Windows 10', '1', 'password cannot be longer than 72 bytes, truncate manually if necessary (e.g. my_password[:72])', '2026-01-15 14:40:12');
INSERT INTO "public"."sys_logininfor" VALUES (104, 'admin', '', '未知', 'Edge 143', 'Windows 10', '1', 'password cannot be longer than 72 bytes, truncate manually if necessary (e.g. my_password[:72])', '2026-01-15 15:03:46');
INSERT INTO "public"."sys_logininfor" VALUES (105, 'admin', '', '未知', 'Edge 143', 'Windows 10', '0', '登录成功', '2026-01-15 15:07:41');
INSERT INTO "public"."sys_logininfor" VALUES (106, 'admin', '', '未知', 'Edge 143', 'Windows 10', '0', '登录成功', '2026-01-15 16:15:08');
INSERT INTO "public"."sys_logininfor" VALUES (107, 'admin', '', '未知', 'Edge 143', 'Windows 10', '0', '登录成功', '2026-01-16 12:03:39');
INSERT INTO "public"."sys_logininfor" VALUES (108, 'admin', '', '未知', 'Edge 143', 'Windows 10', '0', '登录成功', '2026-01-16 12:04:48');
INSERT INTO "public"."sys_logininfor" VALUES (109, 'admin', '', '未知', 'Edge 143', 'Windows 10', '0', '登录成功', '2026-01-16 12:24:04');
INSERT INTO "public"."sys_logininfor" VALUES (110, 'admin', '', '未知', 'Edge 144', 'Windows 10', '0', '登录成功', '2026-01-17 13:02:18');
INSERT INTO "public"."sys_logininfor" VALUES (111, 'admin', '', '未知', 'Edge 144', 'Windows 10', '0', '登录成功', '2026-01-19 13:37:19');
INSERT INTO "public"."sys_logininfor" VALUES (112, 'admin', '', '未知', 'Edge 144', 'Windows 10', '0', '登录成功', '2026-01-19 18:37:26');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_menu";
CREATE TABLE "public"."sys_menu" (
  "menu_id" int8 NOT NULL DEFAULT nextval('sys_menu_menu_id_seq'::regclass),
  "menu_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "parent_id" int8 DEFAULT 0,
  "order_num" int4 DEFAULT 0,
  "path" varchar(200) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "component" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "query" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "route_name" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "is_frame" int4 DEFAULT 1,
  "is_cache" int4 DEFAULT 0,
  "menu_type" char(1) COLLATE "pg_catalog"."default" DEFAULT ''::bpchar,
  "visible" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "perms" varchar(100) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying,
  "icon" varchar(100) COLLATE "pg_catalog"."default" DEFAULT '#'::character varying,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT ''::character varying
)
;
COMMENT ON COLUMN "public"."sys_menu"."menu_id" IS '菜单ID';
COMMENT ON COLUMN "public"."sys_menu"."menu_name" IS '菜单名称';
COMMENT ON COLUMN "public"."sys_menu"."parent_id" IS '父菜单ID';
COMMENT ON COLUMN "public"."sys_menu"."order_num" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_menu"."path" IS '路由地址';
COMMENT ON COLUMN "public"."sys_menu"."component" IS '组件路径';
COMMENT ON COLUMN "public"."sys_menu"."query" IS '路由参数';
COMMENT ON COLUMN "public"."sys_menu"."route_name" IS '路由名称';
COMMENT ON COLUMN "public"."sys_menu"."is_frame" IS '是否为外链（0是 1否）';
COMMENT ON COLUMN "public"."sys_menu"."is_cache" IS '是否缓存（0缓存 1不缓存）';
COMMENT ON COLUMN "public"."sys_menu"."menu_type" IS '菜单类型（M目录 C菜单 F按钮）';
COMMENT ON COLUMN "public"."sys_menu"."visible" IS '菜单状态（0显示 1隐藏）';
COMMENT ON COLUMN "public"."sys_menu"."status" IS '菜单状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_menu"."perms" IS '权限标识';
COMMENT ON COLUMN "public"."sys_menu"."icon" IS '菜单图标';
COMMENT ON COLUMN "public"."sys_menu"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_menu"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_menu"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_menu"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_menu"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_menu" IS '菜单权限表';

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO "public"."sys_menu" VALUES (1, '系统管理', 0, 4, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-01-14 12:35:27', '', NULL, '系统管理目录');
INSERT INTO "public"."sys_menu" VALUES (2, '系统监控', 0, 5, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-01-14 12:35:27', '', NULL, '系统监控目录');
INSERT INTO "public"."sys_menu" VALUES (3, '系统工具', 0, 6, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-01-14 12:35:27', '', NULL, '系统工具目录');
INSERT INTO "public"."sys_menu" VALUES (118, '文件查询', 4, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'file:file:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (119, '文件新增', 4, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'file:file:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (120, '文件修改', 4, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'file:file:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (121, '文件删除', 4, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'file:file:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (122, '文件导出', 4, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'file:file:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (124, '容器查询', 5, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'container:container:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (125, '容器新增', 5, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'container:container:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (126, '容器修改', 5, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'container:container:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (127, '容器删除', 5, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'container:container:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (128, '容器导出', 5, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'container:container:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (130, '任务查询', 6, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'task:task:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (131, '任务新增', 6, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'task:task:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (132, '任务修改', 6, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'task:task:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (133, '任务删除', 6, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'task:task:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (134, '任务导出', 6, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'task:task:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-01-14 12:35:27', '', NULL, '用户管理菜单');
INSERT INTO "public"."sys_menu" VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-01-14 12:35:27', '', NULL, '角色管理菜单');
INSERT INTO "public"."sys_menu" VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-01-14 12:35:27', '', NULL, '菜单管理菜单');
INSERT INTO "public"."sys_menu" VALUES (103, '小组管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-01-14 12:35:27', '', NULL, '小组管理菜单');
INSERT INTO "public"."sys_menu" VALUES (104, '职责管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-01-14 12:35:27', '', NULL, '职责管理菜单');
INSERT INTO "public"."sys_menu" VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-01-14 12:35:27', '', NULL, '字典管理菜单');
INSERT INTO "public"."sys_menu" VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-01-14 12:35:27', '', NULL, '参数设置菜单');
INSERT INTO "public"."sys_menu" VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-01-14 12:35:27', '', NULL, '日志管理菜单');
INSERT INTO "public"."sys_menu" VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-01-14 12:35:27', '', NULL, '在线用户菜单');
INSERT INTO "public"."sys_menu" VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-01-14 12:35:27', '', NULL, '定时任务菜单');
INSERT INTO "public"."sys_menu" VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-01-14 12:35:27', '', NULL, '服务监控菜单');
INSERT INTO "public"."sys_menu" VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2026-01-14 12:35:27', '', NULL, '缓存监控菜单');
INSERT INTO "public"."sys_menu" VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2026-01-14 12:35:27', '', NULL, '缓存列表菜单');
INSERT INTO "public"."sys_menu" VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2026-01-14 12:35:27', '', NULL, '表单构建菜单');
INSERT INTO "public"."sys_menu" VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-01-14 12:35:27', '', NULL, '代码生成菜单');
INSERT INTO "public"."sys_menu" VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2026-01-14 12:35:27', '', NULL, '系统接口菜单');
INSERT INTO "public"."sys_menu" VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2026-01-14 12:35:27', '', NULL, '操作日志菜单');
INSERT INTO "public"."sys_menu" VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-01-14 12:35:27', '', NULL, '登录日志菜单');
INSERT INTO "public"."sys_menu" VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (5, '算力平台', 0, 1, 'container', 'container/container/index', '', '', 1, 0, 'C', '0', '0', 'container:container:list', 'server', 'admin', '2026-01-14 12:35:27', 'admin', '2026-01-19 15:06:30', '容器菜单');
INSERT INTO "public"."sys_menu" VALUES (6, '任务管理', 0, 3, 'task', 'task/task/index', '', '', 1, 0, 'C', '0', '0', 'task:task:list', 'list', 'admin', '2026-01-14 12:35:27', 'admin', '2026-01-16 12:45:29', '任务菜单');
INSERT INTO "public"."sys_menu" VALUES (107, '通知公告', 0, 3, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-01-14 12:35:27', 'admin', '2026-01-19 20:00:24', '通知公告菜单');
INSERT INTO "public"."sys_menu" VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1016, '小组查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1017, '小组新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1018, '小组修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1019, '小组删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1020, '职责查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1021, '职责新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1022, '职责修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1023, '职责删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1024, '职责导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-01-14 12:35:27', '', NULL, '');
INSERT INTO "public"."sys_menu" VALUES (4, '遥感数据管理', 0, 1, 'file', 'file/file/index', '', '', 1, 0, 'C', '0', '0', 'file:file:list', 'documentation', 'admin', '2026-01-14 12:35:27', 'admin', '2026-01-16 12:44:54', '文件菜单');
INSERT INTO "public"."sys_menu" VALUES (2000, '监测平台', 0, 2, 'map', 'map/index', NULL, '', 1, 0, 'C', '0', '0', '', 'druid', 'admin', '2026-01-16 12:47:35', 'admin', '2026-01-19 14:37:12', '');
INSERT INTO "public"."sys_menu" VALUES (2001, '节点管理', 0, 1, 'node', 'node/node/index', NULL, '', 1, 0, 'C', '0', '0', 'node:node:list', 'slider', 'admin', '2026-01-19 14:34:15', 'admin', '2026-01-19 14:37:02', '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_notice";
CREATE TABLE "public"."sys_notice" (
  "notice_id" int4 NOT NULL DEFAULT nextval('sys_notice_notice_id_seq'::regclass),
  "notice_title" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "notice_type" char(1) COLLATE "pg_catalog"."default" NOT NULL,
  "notice_content" bytea,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(255) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_notice"."notice_id" IS '公告ID';
COMMENT ON COLUMN "public"."sys_notice"."notice_title" IS '公告标题';
COMMENT ON COLUMN "public"."sys_notice"."notice_type" IS '公告类型（1通知 2公告）';
COMMENT ON COLUMN "public"."sys_notice"."notice_content" IS '公告内容';
COMMENT ON COLUMN "public"."sys_notice"."status" IS '公告状态（0正常 1关闭）';
COMMENT ON COLUMN "public"."sys_notice"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_notice"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_notice"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_notice"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_notice"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_notice" IS '通知公告表';

-- ----------------------------
-- Records of sys_notice
-- ----------------------------

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_oper_log";
CREATE TABLE "public"."sys_oper_log" (
  "oper_id" int8 NOT NULL DEFAULT nextval('sys_oper_log_oper_id_seq'::regclass),
  "title" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "business_type" int4 DEFAULT 0,
  "method" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "request_method" varchar(10) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "operator_type" int4 DEFAULT 0,
  "oper_name" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "dept_name" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_url" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_ip" varchar(128) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_location" varchar(255) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_param" varchar(2000) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "json_result" varchar(2000) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "status" int4 DEFAULT 0,
  "error_msg" varchar(2000) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "oper_time" timestamp(0),
  "cost_time" int8 DEFAULT 0
)
;
COMMENT ON COLUMN "public"."sys_oper_log"."oper_id" IS '日志主键';
COMMENT ON COLUMN "public"."sys_oper_log"."title" IS '模块标题';
COMMENT ON COLUMN "public"."sys_oper_log"."business_type" IS '业务类型（0其它 1新增 2修改 3删除）';
COMMENT ON COLUMN "public"."sys_oper_log"."method" IS '方法名称';
COMMENT ON COLUMN "public"."sys_oper_log"."request_method" IS '请求方式';
COMMENT ON COLUMN "public"."sys_oper_log"."operator_type" IS '操作类别（0其它 1后台用户 2手机端用户）';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_name" IS '操作人员';
COMMENT ON COLUMN "public"."sys_oper_log"."dept_name" IS '小组名称';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_url" IS '请求URL';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_ip" IS '主机地址';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_location" IS '操作地点';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_param" IS '请求参数';
COMMENT ON COLUMN "public"."sys_oper_log"."json_result" IS '返回参数';
COMMENT ON COLUMN "public"."sys_oper_log"."status" IS '操作状态（0正常 1异常）';
COMMENT ON COLUMN "public"."sys_oper_log"."error_msg" IS '错误消息';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_time" IS '操作时间';
COMMENT ON TABLE "public"."sys_oper_log" IS '操作日志记录';

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO "public"."sys_oper_log" VALUES (100, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 4, "menuName": "预测数据管理", "parentId": 0, "orderNum": 1, "path": "file", "component": "file/file/index", "query": "", "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "file:file:list", "icon": "documentation", "createBy": "admin", "createTime": "2026-01-14T12:35:27", "updateBy": "", "updateTime": null, "remark": "文件菜单"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-16T12:44:53.923208"}', 0, '', '2026-01-16 12:44:54', 1);
INSERT INTO "public"."sys_oper_log" VALUES (101, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 5, "menuName": "预测平台管理", "parentId": 0, "orderNum": 2, "path": "container", "component": "container/container/index", "query": "", "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "container:container:list", "icon": "server", "createBy": "admin", "createTime": "2026-01-14T12:35:27", "updateBy": "", "updateTime": null, "remark": "容器菜单"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-16T12:45:05.661056"}', 0, '', '2026-01-16 12:45:06', 1);
INSERT INTO "public"."sys_oper_log" VALUES (102, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 6, "menuName": "任务管理", "parentId": 0, "orderNum": 3, "path": "task", "component": "task/task/index", "query": "", "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "task:task:list", "icon": "list", "createBy": "admin", "createTime": "2026-01-14T12:35:27", "updateBy": "", "updateTime": null, "remark": "任务菜单"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-16T12:45:29.362089"}', 0, '', '2026-01-16 12:45:29', 1);
INSERT INTO "public"."sys_oper_log" VALUES (103, '菜单管理', 1, 'module_admin.controller.menu_controller.add_system_menu()', 'POST', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"parentId": 0, "menuName": "设备监控", "icon": "druid", "menuType": "M", "orderNum": 2, "isFrame": 1, "isCache": 0, "visible": "0", "status": "0", "path": "tool"}', '{"code": 200, "msg": "新增成功", "success": true, "time": "2026-01-16T12:47:35.467266"}', 0, '', '2026-01-16 12:47:35', 1);
INSERT INTO "public"."sys_oper_log" VALUES (104, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": null, "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-16T12:47:35", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-16T12:51:13.284007"}', 0, '', '2026-01-16 12:51:13', 0);
INSERT INTO "public"."sys_oper_log" VALUES (105, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 0, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": null, "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-16T12:51:13", "remark": ""}', '{"code": 500, "msg": "修改菜单设备监控失败，地址必须以http(s)://开头", "success": false, "time": "2026-01-16T12:51:32.066053"}', 1, '修改菜单设备监控失败，地址必须以http(s)://开头', '2026-01-16 12:51:32', 1);
INSERT INTO "public"."sys_oper_log" VALUES (106, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 5, "menuName": "预测平台管理", "parentId": 0, "orderNum": 2, "path": "container", "component": "container/container/index", "query": "", "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "container:container:list", "icon": "server", "createBy": "admin", "createTime": "2026-01-14T12:35:27", "updateBy": "admin", "updateTime": "2026-01-16T12:45:06", "remark": "容器菜单"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-16T12:51:49.041195"}', 0, '', '2026-01-16 12:51:49', 0);
INSERT INTO "public"."sys_oper_log" VALUES (107, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": null, "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-16T12:51:13", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-16T12:52:03.458211"}', 0, '', '2026-01-16 12:52:03', 1);
INSERT INTO "public"."sys_oper_log" VALUES (108, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "map:map:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-16T12:52:03", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-16T12:52:43.340883"}', 0, '', '2026-01-16 12:52:43', 1);
INSERT INTO "public"."sys_oper_log" VALUES (109, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "map:map:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-16T12:52:43", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-16T12:53:03.668745"}', 0, '', '2026-01-16 12:53:04', 1);
INSERT INTO "public"."sys_oper_log" VALUES (110, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "map:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-16T12:53:04", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:09:01.031103"}', 0, '', '2026-01-19 14:09:01', 2);
INSERT INTO "public"."sys_oper_log" VALUES (111, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "map:map:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:09:01", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:10:08.860559"}', 0, '', '2026-01-19 14:10:09', 0);
INSERT INTO "public"."sys_oper_log" VALUES (114, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "/map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "map:map:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:13:32", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:17:01.882978"}', 0, '', '2026-01-19 14:17:02', 1);
INSERT INTO "public"."sys_oper_log" VALUES (123, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2001, "menuName": "节点管理", "parentId": 0, "orderNum": 1, "path": "node", "component": "node/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "slider", "createBy": "admin", "createTime": "2026-01-19T14:34:15", "updateBy": "admin", "updateTime": "2026-01-19T14:34:15", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:34:58.941965"}', 0, '', '2026-01-19 14:34:59', 1);
INSERT INTO "public"."sys_oper_log" VALUES (112, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "map:map:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:10:09", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:12:49.933941"}', 0, '', '2026-01-19 14:12:50', 0);
INSERT INTO "public"."sys_oper_log" VALUES (113, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "map:map:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:12:50", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:13:31.899271"}', 0, '', '2026-01-19 14:13:32', 1);
INSERT INTO "public"."sys_oper_log" VALUES (115, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "/map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:17:02", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:20:41.232282"}', 0, '', '2026-01-19 14:20:41', 0);
INSERT INTO "public"."sys_oper_log" VALUES (116, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:20:41", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:21:15.717850"}', 0, '', '2026-01-19 14:21:16', 0);
INSERT INTO "public"."sys_oper_log" VALUES (117, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:21:16", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:22:50.283252"}', 0, '', '2026-01-19 14:22:50', 1);
INSERT INTO "public"."sys_oper_log" VALUES (118, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "node", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:22:50", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:28:43.606641"}', 0, '', '2026-01-19 14:28:44', 1);
INSERT INTO "public"."sys_oper_log" VALUES (119, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "node", "component": "node/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:28:44", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:29:56.171923"}', 0, '', '2026-01-19 14:29:56', 0);
INSERT INTO "public"."sys_oper_log" VALUES (120, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "node", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:29:56", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:30:27.544055"}', 0, '', '2026-01-19 14:30:28', 1);
INSERT INTO "public"."sys_oper_log" VALUES (121, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:30:28", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:32:35.253987"}', 0, '', '2026-01-19 14:32:35', 0);
INSERT INTO "public"."sys_oper_log" VALUES (122, '菜单管理', 1, 'module_admin.controller.menu_controller.add_system_menu()', 'POST', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"parentId": 0, "menuName": "节点管理", "icon": "slider", "menuType": "C", "orderNum": 1, "isFrame": 1, "isCache": 0, "visible": "0", "status": "0", "path": "node", "perms": "node:node:list", "component": "node/node/index"}', '{"code": 200, "msg": "新增成功", "success": true, "time": "2026-01-19T14:34:14.866937"}', 0, '', '2026-01-19 14:34:15', 1);
INSERT INTO "public"."sys_oper_log" VALUES (124, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2001, "menuName": "节点管理", "parentId": 0, "orderNum": 1, "path": "/node", "component": "node/node/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "slider", "createBy": "admin", "createTime": "2026-01-19T14:34:15", "updateBy": "admin", "updateTime": "2026-01-19T14:34:59", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:35:28.544412"}', 0, '', '2026-01-19 14:35:29', 1);
INSERT INTO "public"."sys_oper_log" VALUES (125, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2001, "menuName": "节点管理", "parentId": 0, "orderNum": 1, "path": "node", "component": "node/node/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "slider", "createBy": "admin", "createTime": "2026-01-19T14:34:15", "updateBy": "admin", "updateTime": "2026-01-19T14:35:29", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:35:48.505543"}', 0, '', '2026-01-19 14:35:48', 6);
INSERT INTO "public"."sys_oper_log" VALUES (126, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2001, "menuName": "节点管理", "parentId": 0, "orderNum": 1, "path": "node", "component": "node/node/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "node:node:list", "icon": "slider", "createBy": "admin", "createTime": "2026-01-19T14:34:15", "updateBy": "admin", "updateTime": "2026-01-19T14:35:48", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:37:02.220767"}', 0, '', '2026-01-19 14:37:02', 0);
INSERT INTO "public"."sys_oper_log" VALUES (127, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 2000, "menuName": "设备监控", "parentId": 0, "orderNum": 2, "path": "map", "component": "map/index", "query": null, "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "", "icon": "druid", "createBy": "admin", "createTime": "2026-01-16T12:47:35", "updateBy": "admin", "updateTime": "2026-01-19T14:32:35", "remark": ""}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T14:37:11.912535"}', 0, '', '2026-01-19 14:37:12', 1);
INSERT INTO "public"."sys_oper_log" VALUES (128, '节点', 1, 'module_algo.node.controller.node_controller.add_node_node()', 'POST', 1, 'admin', '项目组', '/dev-api/node/node', '', '未知', '{"name": "6", "longitude": "124.24", "latitude": "40.07", "dir": null, "status": "0"}', '{"code": 200, "msg": "新增成功", "success": true, "time": "2026-01-19T15:00:51.252938"}', 0, '', '2026-01-19 15:00:51', 30);
INSERT INTO "public"."sys_oper_log" VALUES (129, '节点', 2, 'module_algo.node.controller.node_controller.edit_node_node()', 'PUT', 1, 'admin', '项目组', '/dev-api/node/node', '', '未知', '{"id": 1, "name": "丹东2号电力塔", "longitude": 124.24, "latitude": 40.07, "dir": 20, "status": "0"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T15:01:16.959679"}', 0, '', '2026-01-19 15:01:17', 1);
INSERT INTO "public"."sys_oper_log" VALUES (130, '节点', 1, 'module_algo.node.controller.node_controller.add_node_node()', 'POST', 1, 'admin', '项目组', '/dev-api/node/node', '', '未知', '{"name": "丹东东港电塔", "longitude": "124.454", "latitude": "39.8378", "dir": null, "status": "0"}', '{"code": 200, "msg": "新增成功", "success": true, "time": "2026-01-19T15:02:42.553241"}', 0, '', '2026-01-19 15:02:43', 1);
INSERT INTO "public"."sys_oper_log" VALUES (131, '节点', 1, 'module_algo.node.controller.node_controller.add_node_node()', 'POST', 1, 'admin', '项目组', '/dev-api/node/node', '', '未知', '{"name": "丹东凤城东汤镇石桥线69号电塔", "longitude": "124.2101", "latitude": "40.3098", "dir": null, "status": "0"}', '{"code": 200, "msg": "新增成功", "success": true, "time": "2026-01-19T15:03:09.406626"}', 0, '', '2026-01-19 15:03:09', 0);
INSERT INTO "public"."sys_oper_log" VALUES (132, '节点', 1, 'module_algo.node.controller.node_controller.add_node_node()', 'POST', 1, 'admin', '项目组', '/dev-api/node/node', '', '未知', '{"name": "丹东孔安甲乙线", "longitude": "124.3631", "latitude": "40.166", "dir": null, "status": "0"}', '{"code": 200, "msg": "新增成功", "success": true, "time": "2026-01-19T15:03:29.847108"}', 0, '', '2026-01-19 15:03:30', 0);
INSERT INTO "public"."sys_oper_log" VALUES (133, '文件', 2, 'module_algo.file.controller.file_controller.edit_file_file()', 'PUT', 1, 'admin', '项目组', '/dev-api/file/file', '', '未知', '{"id": 20, "name": "丹东2号电力塔", "type": "dir", "root": "0", "size": 0, "uploadTime": "2026-01-19T15:00:51"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T15:05:49.930794"}', 0, '', '2026-01-19 15:05:50', 1);
INSERT INTO "public"."sys_oper_log" VALUES (134, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 5, "menuName": "预测平台管理", "parentId": 0, "orderNum": 1, "path": "container", "component": "container/container/index", "query": "", "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "container:container:list", "icon": "server", "createBy": "admin", "createTime": "2026-01-14T12:35:27", "updateBy": "admin", "updateTime": "2026-01-16T12:51:49", "remark": "容器菜单"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T15:06:30.178111"}', 0, '', '2026-01-19 15:06:30', 1);
INSERT INTO "public"."sys_oper_log" VALUES (135, '容器', 1, 'module_algo.container.controller.container_controller.add_container_container()', 'POST', 1, 'admin', '项目组', '/dev-api/container/container', '', '未知', '{"id": null, "name": "test", "url": "http://10.43.12.149:4101", "type": null, "create_time": null, "dept": null}', '{"code": 200, "msg": "新增成功", "success": true, "time": "2026-01-19T15:10:14.212913"}', 0, '', '2026-01-19 15:10:14', 1);
INSERT INTO "public"."sys_oper_log" VALUES (136, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 107, "menuName": "通知公告", "parentId": 1, "orderNum": 3, "path": "notice", "component": "system/notice/index", "query": "", "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "system:notice:list", "icon": "message", "createBy": "admin", "createTime": "2026-01-14T12:35:27", "updateBy": "", "updateTime": null, "remark": "通知公告菜单"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T19:59:47.494719"}', 0, '', '2026-01-19 19:59:47', 2);
INSERT INTO "public"."sys_oper_log" VALUES (137, '菜单管理', 2, 'module_admin.controller.menu_controller.edit_system_menu()', 'PUT', 1, 'admin', '项目组', '/dev-api/system/menu', '', '未知', '{"menuId": 107, "menuName": "通知公告", "parentId": 0, "orderNum": 3, "path": "notice", "component": "system/notice/index", "query": "", "routeName": "", "isFrame": 1, "isCache": 0, "menuType": "C", "visible": "0", "status": "0", "perms": "system:notice:list", "icon": "message", "createBy": "admin", "createTime": "2026-01-14T12:35:27", "updateBy": "admin", "updateTime": "2026-01-19T19:59:47", "remark": "通知公告菜单"}', '{"code": 200, "msg": "更新成功", "success": true, "time": "2026-01-19T20:00:23.936965"}', 0, '', '2026-01-19 20:00:24', 0);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_post";
CREATE TABLE "public"."sys_post" (
  "post_id" int8 NOT NULL DEFAULT nextval('sys_post_post_id_seq'::regclass),
  "post_code" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "post_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "post_sort" int4 NOT NULL,
  "status" char(1) COLLATE "pg_catalog"."default" NOT NULL,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_post"."post_id" IS '职责ID';
COMMENT ON COLUMN "public"."sys_post"."post_code" IS '职责编码';
COMMENT ON COLUMN "public"."sys_post"."post_name" IS '职责名称';
COMMENT ON COLUMN "public"."sys_post"."post_sort" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_post"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_post"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_post"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_post"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_post"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_post"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_post" IS '职责信息表';

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO "public"."sys_post" VALUES (1, 'ld', '负责人', 1, '0', 'admin', '2026-01-14 12:35:27', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role";
CREATE TABLE "public"."sys_role" (
  "role_id" int8 NOT NULL DEFAULT nextval('sys_role_role_id_seq'::regclass),
  "role_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "role_key" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "role_sort" int4 NOT NULL,
  "data_scope" char(1) COLLATE "pg_catalog"."default" DEFAULT '1'::bpchar,
  "menu_check_strictly" int2 DEFAULT 1,
  "dept_check_strictly" int2 DEFAULT 1,
  "status" char(1) COLLATE "pg_catalog"."default" NOT NULL,
  "del_flag" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_role"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role"."role_name" IS '角色名称';
COMMENT ON COLUMN "public"."sys_role"."role_key" IS '角色权限字符串';
COMMENT ON COLUMN "public"."sys_role"."role_sort" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_role"."data_scope" IS '数据范围（1：全部数据权限 2：自定数据权限 3：本小组数据权限 4：本小组及以下数据权限）';
COMMENT ON COLUMN "public"."sys_role"."menu_check_strictly" IS '菜单树选择项是否关联显示';
COMMENT ON COLUMN "public"."sys_role"."dept_check_strictly" IS '小组树选择项是否关联显示';
COMMENT ON COLUMN "public"."sys_role"."status" IS '角色状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_role"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_role"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_role"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_role"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_role"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_role"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_role" IS '角色信息表';

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO "public"."sys_role" VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-01-14 12:35:27', '', NULL, '超级管理员');

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role_dept";
CREATE TABLE "public"."sys_role_dept" (
  "role_id" int8 NOT NULL,
  "dept_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_role_dept"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role_dept"."dept_id" IS '小组ID';
COMMENT ON TABLE "public"."sys_role_dept" IS '角色和小组关联表';

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role_menu";
CREATE TABLE "public"."sys_role_menu" (
  "role_id" int8 NOT NULL,
  "menu_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_role_menu"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role_menu"."menu_id" IS '菜单ID';
COMMENT ON TABLE "public"."sys_role_menu" IS '角色和菜单关联表';

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user";
CREATE TABLE "public"."sys_user" (
  "user_id" int8 NOT NULL DEFAULT nextval('sys_user_user_id_seq'::regclass),
  "dept_id" int8,
  "user_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "nick_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
  "user_type" varchar(2) COLLATE "pg_catalog"."default" DEFAULT '00'::character varying,
  "email" varchar(50) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "phonenumber" varchar(11) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "sex" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "avatar" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "password" varchar(100) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "status" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "del_flag" char(1) COLLATE "pg_catalog"."default" DEFAULT '0'::bpchar,
  "login_ip" varchar(128) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "login_date" timestamp(0),
  "create_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "create_time" timestamp(0),
  "update_by" varchar(64) COLLATE "pg_catalog"."default" DEFAULT ''::character varying,
  "update_time" timestamp(0),
  "remark" varchar(500) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;
COMMENT ON COLUMN "public"."sys_user"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user"."dept_id" IS '小组ID';
COMMENT ON COLUMN "public"."sys_user"."user_name" IS '用户账号';
COMMENT ON COLUMN "public"."sys_user"."nick_name" IS '用户昵称';
COMMENT ON COLUMN "public"."sys_user"."user_type" IS '用户类型（00系统用户）';
COMMENT ON COLUMN "public"."sys_user"."email" IS '用户邮箱';
COMMENT ON COLUMN "public"."sys_user"."phonenumber" IS '手机号码';
COMMENT ON COLUMN "public"."sys_user"."sex" IS '用户性别（0男 1女 2未知）';
COMMENT ON COLUMN "public"."sys_user"."avatar" IS '头像地址';
COMMENT ON COLUMN "public"."sys_user"."password" IS '密码';
COMMENT ON COLUMN "public"."sys_user"."status" IS '帐号状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_user"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_user"."login_ip" IS '最后登录IP';
COMMENT ON COLUMN "public"."sys_user"."login_date" IS '最后登录时间';
COMMENT ON COLUMN "public"."sys_user"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_user"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_user"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_user"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_user"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_user" IS '用户信息表';

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO "public"."sys_user" VALUES (1, 100, 'admin', '超级管理员', '00', 'niangao@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-01-19 18:37:26', 'admin', '2026-01-14 12:35:27', '', NULL, '管理员');

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_post";
CREATE TABLE "public"."sys_user_post" (
  "user_id" int8 NOT NULL,
  "post_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_user_post"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user_post"."post_id" IS '职责ID';
COMMENT ON TABLE "public"."sys_user_post" IS '用户与职责关联表';

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO "public"."sys_user_post" VALUES (1, 1);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_role";
CREATE TABLE "public"."sys_user_role" (
  "user_id" int8 NOT NULL,
  "role_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_user_role"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user_role"."role_id" IS '角色ID';
COMMENT ON TABLE "public"."sys_user_role" IS '用户和角色关联表';

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO "public"."sys_user_role" VALUES (1, 1);
INSERT INTO "public"."sys_user_role" VALUES (2, 2);

-- ----------------------------
-- Table structure for task
-- ----------------------------
DROP TABLE IF EXISTS "public"."task";
CREATE TABLE "public"."task" (
  "id" int4 NOT NULL DEFAULT nextval('task_id_seq'::regclass),
  "name" varchar COLLATE "pg_catalog"."default" NOT NULL,
  "container" int4 NOT NULL,
  "algo" varchar COLLATE "pg_catalog"."default" NOT NULL,
  "args" varchar COLLATE "pg_catalog"."default" NOT NULL,
  "remark" varchar COLLATE "pg_catalog"."default",
  "state" varchar COLLATE "pg_catalog"."default",
  "result" int4,
  "init_time" timestamp(0),
  "end_time" timestamp(0),
  "dept" int4
)
;
COMMENT ON COLUMN "public"."task"."id" IS '任务唯一标识';
COMMENT ON COLUMN "public"."task"."name" IS '任务名称';
COMMENT ON COLUMN "public"."task"."container" IS '执行容器ID';
COMMENT ON COLUMN "public"."task"."algo" IS '算法名称';
COMMENT ON COLUMN "public"."task"."args" IS '任务参数';
COMMENT ON COLUMN "public"."task"."remark" IS '备注信息';
COMMENT ON COLUMN "public"."task"."state" IS '任务状态';
COMMENT ON COLUMN "public"."task"."result" IS '任务结果文件ID';
COMMENT ON COLUMN "public"."task"."init_time" IS '任务初始化时间';
COMMENT ON COLUMN "public"."task"."end_time" IS '任务结束时间';
COMMENT ON COLUMN "public"."task"."dept" IS '所属部门ID';
COMMENT ON TABLE "public"."task" IS '任务表';

-- ----------------------------
-- Records of task
-- ----------------------------

-- ----------------------------
-- Function structure for find_in_set
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."find_in_set"(int8, varchar);
CREATE OR REPLACE FUNCTION "public"."find_in_set"(int8, varchar)
  RETURNS "pg_catalog"."bool" AS $BODY$
DECLARE
    STR ALIAS FOR $1;
    STRS ALIAS FOR $2;
    POS INTEGER;
    STATUS BOOLEAN;
BEGIN
    SELECT POSITION( ','||STR||',' IN ','||STRS||',') INTO POS;
    IF POS > 0 THEN
        STATUS = TRUE;
    ELSE
        STATUS = FALSE;
    END IF;
    RETURN STATUS;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for substring_index
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."substring_index"(varchar, varchar, int4);
CREATE OR REPLACE FUNCTION "public"."substring_index"(varchar, varchar, int4)
  RETURNS "pg_catalog"."varchar" AS $BODY$
DECLARE
tokens varchar[];
length integer ;
indexnum integer;
BEGIN
tokens := pg_catalog.string_to_array($1, $2);
length := pg_catalog.array_upper(tokens, 1);
indexnum := length - ($3 * -1) + 1;
IF $3 >= 0 THEN
RETURN pg_catalog.array_to_string(tokens[1:$3], $2);
ELSE
RETURN pg_catalog.array_to_string(tokens[indexnum:length], $2);
END IF;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE STRICT
  COST 100;

-- ----------------------------
-- View structure for list_column
-- ----------------------------
DROP VIEW IF EXISTS "public"."list_column";
CREATE VIEW "public"."list_column" AS  SELECT c.relname AS table_name,
    a.attname AS column_name,
    d.description AS column_comment,
        CASE
            WHEN a.attnotnull AND con.conname IS NULL THEN '1'::text
            ELSE '0'::text
        END AS is_required,
        CASE
            WHEN con.conname IS NOT NULL THEN '1'::text
            ELSE '0'::text
        END AS is_pk,
    a.attnum AS sort,
        CASE
            WHEN "position"(pg_get_expr(ad.adbin, ad.adrelid), ((c.relname::text || '_'::text) || a.attname::text) || '_seq'::text) > 0 THEN '1'::text
            ELSE '0'::text
        END AS is_increment,
    btrim(
        CASE
            WHEN t.typelem <> 0::oid AND t.typlen = '-1'::integer THEN 'ARRAY'::text
            ELSE
            CASE
                WHEN t.typtype = 'd'::"char" THEN format_type(t.typbasetype, NULL::integer)
                ELSE format_type(a.atttypid, NULL::integer)
            END
        END, '"'::text) AS column_type
   FROM pg_attribute a
     JOIN (pg_class c
     JOIN pg_namespace n ON c.relnamespace = n.oid) ON a.attrelid = c.oid
     LEFT JOIN pg_description d ON d.objoid = c.oid AND a.attnum = d.objsubid
     LEFT JOIN pg_constraint con ON con.conrelid = c.oid AND (a.attnum = ANY (con.conkey))
     LEFT JOIN pg_attrdef ad ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum
     LEFT JOIN pg_type t ON a.atttypid = t.oid
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND a.attnum > 0 AND n.nspname = 'public'::name AND NOT a.attisdropped
  ORDER BY c.relname, a.attnum;

-- ----------------------------
-- View structure for list_table
-- ----------------------------
DROP VIEW IF EXISTS "public"."list_table";
CREATE VIEW "public"."list_table" AS  SELECT c.relname AS table_name,
    obj_description(c.oid) AS table_comment,
    CURRENT_TIMESTAMP AS create_time,
    CURRENT_TIMESTAMP AS update_time
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND c.relname !~~ 'spatial_%'::text AND n.nspname = 'public'::name AND n.nspname <> ''::name;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."container_id_seq"
OWNED BY "public"."container"."id";
SELECT setval('"public"."container_id_seq"', 20, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."file_id_seq"
OWNED BY "public"."file"."id";
SELECT setval('"public"."file_id_seq"', 23, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gen_table_column_column_id_seq"
OWNED BY "public"."gen_table_column"."column_id";
SELECT setval('"public"."gen_table_column_column_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."gen_table_table_id_seq"
OWNED BY "public"."gen_table"."table_id";
SELECT setval('"public"."gen_table_table_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."node_info_id_seq"
OWNED BY "public"."node_info"."id";
SELECT setval('"public"."node_info_id_seq"', 4, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_config_config_id_seq"
OWNED BY "public"."sys_config"."config_id";
SELECT setval('"public"."sys_config_config_id_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dept_dept_id_seq"
OWNED BY "public"."sys_dept"."dept_id";
SELECT setval('"public"."sys_dept_dept_id_seq"', 200, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dict_data_dict_code_seq"
OWNED BY "public"."sys_dict_data"."dict_code";
SELECT setval('"public"."sys_dict_data_dict_code_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_dict_type_dict_id_seq"
OWNED BY "public"."sys_dict_type"."dict_id";
SELECT setval('"public"."sys_dict_type_dict_id_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_job_job_id_seq"
OWNED BY "public"."sys_job"."job_id";
SELECT setval('"public"."sys_job_job_id_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_job_log_job_log_id_seq"
OWNED BY "public"."sys_job_log"."job_log_id";
SELECT setval('"public"."sys_job_log_job_log_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_logininfor_info_id_seq"
OWNED BY "public"."sys_logininfor"."info_id";
SELECT setval('"public"."sys_logininfor_info_id_seq"', 112, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_menu_menu_id_seq"
OWNED BY "public"."sys_menu"."menu_id";
SELECT setval('"public"."sys_menu_menu_id_seq"', 2001, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_notice_notice_id_seq"
OWNED BY "public"."sys_notice"."notice_id";
SELECT setval('"public"."sys_notice_notice_id_seq"', 10, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_oper_log_oper_id_seq"
OWNED BY "public"."sys_oper_log"."oper_id";
SELECT setval('"public"."sys_oper_log_oper_id_seq"', 137, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_post_post_id_seq"
OWNED BY "public"."sys_post"."post_id";
SELECT setval('"public"."sys_post_post_id_seq"', 5, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_role_role_id_seq"
OWNED BY "public"."sys_role"."role_id";
SELECT setval('"public"."sys_role_role_id_seq"', 3, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_user_user_id_seq"
OWNED BY "public"."sys_user"."user_id";
SELECT setval('"public"."sys_user_user_id_seq"', 100, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."task_id_seq"
OWNED BY "public"."task"."id";
SELECT setval('"public"."task_id_seq"', 20, false);

-- ----------------------------
-- Indexes structure for table apscheduler_jobs
-- ----------------------------
CREATE INDEX "ix_apscheduler_jobs_next_run_time" ON "public"."apscheduler_jobs" USING btree (
  "next_run_time" "pg_catalog"."float8_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table apscheduler_jobs
-- ----------------------------
ALTER TABLE "public"."apscheduler_jobs" ADD CONSTRAINT "apscheduler_jobs_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table container
-- ----------------------------
ALTER TABLE "public"."container" ADD CONSTRAINT "container_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table file
-- ----------------------------
ALTER TABLE "public"."file" ADD CONSTRAINT "file_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table gen_table
-- ----------------------------
ALTER TABLE "public"."gen_table" ADD CONSTRAINT "gen_table_pkey" PRIMARY KEY ("table_id");

-- ----------------------------
-- Primary Key structure for table gen_table_column
-- ----------------------------
ALTER TABLE "public"."gen_table_column" ADD CONSTRAINT "gen_table_column_pkey" PRIMARY KEY ("column_id");

-- ----------------------------
-- Primary Key structure for table node_info
-- ----------------------------
ALTER TABLE "public"."node_info" ADD CONSTRAINT "node_info_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_config
-- ----------------------------
ALTER TABLE "public"."sys_config" ADD CONSTRAINT "sys_config_pkey" PRIMARY KEY ("config_id");

-- ----------------------------
-- Primary Key structure for table sys_dept
-- ----------------------------
ALTER TABLE "public"."sys_dept" ADD CONSTRAINT "sys_dept_pkey" PRIMARY KEY ("dept_id");

-- ----------------------------
-- Primary Key structure for table sys_dict_data
-- ----------------------------
ALTER TABLE "public"."sys_dict_data" ADD CONSTRAINT "sys_dict_data_pkey" PRIMARY KEY ("dict_code");

-- ----------------------------
-- Uniques structure for table sys_dict_type
-- ----------------------------
ALTER TABLE "public"."sys_dict_type" ADD CONSTRAINT "sys_dict_type_dict_type_key" UNIQUE ("dict_type");

-- ----------------------------
-- Primary Key structure for table sys_dict_type
-- ----------------------------
ALTER TABLE "public"."sys_dict_type" ADD CONSTRAINT "sys_dict_type_pkey" PRIMARY KEY ("dict_id");

-- ----------------------------
-- Primary Key structure for table sys_job
-- ----------------------------
ALTER TABLE "public"."sys_job" ADD CONSTRAINT "sys_job_pkey" PRIMARY KEY ("job_id", "job_name", "job_group");

-- ----------------------------
-- Primary Key structure for table sys_job_log
-- ----------------------------
ALTER TABLE "public"."sys_job_log" ADD CONSTRAINT "sys_job_log_pkey" PRIMARY KEY ("job_log_id");

-- ----------------------------
-- Indexes structure for table sys_logininfor
-- ----------------------------
CREATE INDEX "idx_sys_logininfor_lt" ON "public"."sys_logininfor" USING btree (
  "login_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_sys_logininfor_s" ON "public"."sys_logininfor" USING btree (
  "status" COLLATE "pg_catalog"."default" "pg_catalog"."bpchar_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_logininfor
-- ----------------------------
ALTER TABLE "public"."sys_logininfor" ADD CONSTRAINT "sys_logininfor_pkey" PRIMARY KEY ("info_id");

-- ----------------------------
-- Primary Key structure for table sys_menu
-- ----------------------------
ALTER TABLE "public"."sys_menu" ADD CONSTRAINT "sys_menu_pkey" PRIMARY KEY ("menu_id");

-- ----------------------------
-- Primary Key structure for table sys_notice
-- ----------------------------
ALTER TABLE "public"."sys_notice" ADD CONSTRAINT "sys_notice_pkey" PRIMARY KEY ("notice_id");

-- ----------------------------
-- Indexes structure for table sys_oper_log
-- ----------------------------
CREATE INDEX "idx_sys_oper_log_bt" ON "public"."sys_oper_log" USING btree (
  "business_type" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_sys_oper_log_ot" ON "public"."sys_oper_log" USING btree (
  "oper_time" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_sys_oper_log_s" ON "public"."sys_oper_log" USING btree (
  "status" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_oper_log
-- ----------------------------
ALTER TABLE "public"."sys_oper_log" ADD CONSTRAINT "sys_oper_log_pkey" PRIMARY KEY ("oper_id");

-- ----------------------------
-- Primary Key structure for table sys_post
-- ----------------------------
ALTER TABLE "public"."sys_post" ADD CONSTRAINT "sys_post_pkey" PRIMARY KEY ("post_id");

-- ----------------------------
-- Primary Key structure for table sys_role
-- ----------------------------
ALTER TABLE "public"."sys_role" ADD CONSTRAINT "sys_role_pkey" PRIMARY KEY ("role_id");

-- ----------------------------
-- Primary Key structure for table sys_role_dept
-- ----------------------------
ALTER TABLE "public"."sys_role_dept" ADD CONSTRAINT "sys_role_dept_pkey" PRIMARY KEY ("role_id", "dept_id");

-- ----------------------------
-- Primary Key structure for table sys_role_menu
-- ----------------------------
ALTER TABLE "public"."sys_role_menu" ADD CONSTRAINT "sys_role_menu_pkey" PRIMARY KEY ("role_id", "menu_id");

-- ----------------------------
-- Primary Key structure for table sys_user
-- ----------------------------
ALTER TABLE "public"."sys_user" ADD CONSTRAINT "sys_user_pkey" PRIMARY KEY ("user_id");

-- ----------------------------
-- Primary Key structure for table sys_user_post
-- ----------------------------
ALTER TABLE "public"."sys_user_post" ADD CONSTRAINT "sys_user_post_pkey" PRIMARY KEY ("user_id", "post_id");

-- ----------------------------
-- Primary Key structure for table sys_user_role
-- ----------------------------
ALTER TABLE "public"."sys_user_role" ADD CONSTRAINT "sys_user_role_pkey" PRIMARY KEY ("user_id", "role_id");

-- ----------------------------
-- Primary Key structure for table task
-- ----------------------------
ALTER TABLE "public"."task" ADD CONSTRAINT "task_pkey" PRIMARY KEY ("id");
