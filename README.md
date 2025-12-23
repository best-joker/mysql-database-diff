# 数据库差异比较脚本

## 介绍
这是一个用于比较我现在有一个脚本用于比较dev和prod环境中MySQL的表结构的差异，能够生成会比较prod和dev的数据库中表结构的差异，然后给出比较结果的文本和建表、改字段属性的sql，让prod向dev靠齐。

## 使用方法

使用前下载`PyMySQL`库，然后运行脚本

```python
python db_diff.py
```

会生成`diff_report.txt` `fix_changes.sql` `db_diff.py`

分别包含差异比较的文本，新建与dev中表结构中一样的新table、以及原有prod字段中属性修改的sql语句。