# 数据库差异比较脚本 ✨`(๑•̀ㅂ•́)و✧`

## 介绍
这是一个用于比较 dev 和 prod 环境中 MySQL 表结构差异的脚本。  
它能够自动分析两个环境中的表结构差异，并生成以下内容：

- **差异比较文本**（prod 与 dev 的结构差异）
- **建表 SQL**（让 prod 新建 dev 中存在但 prod 中不存在的表）
- **字段属性修改 SQL**（让 prod 的字段属性向 dev 对齐）

让你轻松保持两个环境的结构一致 `(｡•̀ᴗ-)✧`

## 使用方法

使用前请先安装 `PyMySQL` 库：

```bash
pip install PyMySQL
```

然后运行脚本：
```bash
python db_diff.py
```

运行后会生成以下两个文件：
- diff_report.txt — 表结构差异的详细文本报告
- fix_changes.sql — 修改prod原有字段，靠近dev
- create_missing_tables.sql 创建缺失表 
让你一键掌握差异，一键修复结构`(≧▽≦)/`
