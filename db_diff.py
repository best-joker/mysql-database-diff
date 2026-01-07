import pymysql
import sys

def get_db_structure(conn):
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    cursor.execute("SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'")
    tables = [list(row.values())[0] for row in cursor.fetchall()]

    structure = {}
    for table in tables:
        try:
            cursor.execute(f"DESCRIBE `{table}`")
            structure[table] = {row['Field']: row for row in cursor.fetchall()}
        except Exception as e:
            print(f"警告: 跳过表 {table}: {e}")
            continue

    cursor.close()
    return structure

def get_create_table(conn, table):
    cursor = conn.cursor()
    cursor.execute(f"SHOW CREATE TABLE `{table}`")
    create_sql = cursor.fetchone()[1]
    cursor.close()
    return create_sql + ";\n"

def get_table_indices(conn, table):
    """获取表的索引信息"""
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    cursor.execute(f"SHOW INDEX FROM `{table}`")
    indices = cursor.fetchall()
    cursor.close()

    # 按索引名分组，包含的列和唯一性
    index_dict = {}
    for idx in indices:
        key_name = idx['Key_name']
        if key_name not in index_dict:
            index_dict[key_name] = {
                'columns': [],
                'unique': not idx['Non_unique'],
                'primary': key_name == 'PRIMARY'
            }
        index_dict[key_name]['columns'].append(idx['Column_name'])
    return index_dict

def compare_dbs():
    print("--- 数据库结构比对工具 ---")

    dev_host = input("Dev IP: ")
    dev_pwd = input("Dev 密码: ")
    prod_host = input("Prod IP: ")
    prod_pwd = input("Prod 密码: ")
    db_name = input("数据库名称: ")
    port = input("Docker 映射出的端口 (默认 3306): ") or "3306"

    try:
        dev_conn = pymysql.connect(
            host=dev_host,
            user="root",
            password=dev_pwd,
            database=db_name,
            port=int(port),
            charset="utf8mb4",
            autocommit=True
        )

        prod_conn = pymysql.connect(
            host=prod_host,
            user="root",
            password=prod_pwd,
            database=db_name,
            port=int(port),
            charset="utf8mb4",
            autocommit=True
        )
    except Exception as e:
        print(f"数据库连接失败: {e}")
        sys.exit(1)

    print("正在获取数据库结构...")
    dev_struct = get_db_structure(dev_conn)
    prod_struct = get_db_structure(prod_conn)

    diff_report = []
    alter_sql = []
    create_table_sql = []

    for table in dev_struct:
        if table not in prod_struct:
            diff_report.append(f"[新增表] Prod 缺少表: {table}")

            create_sql = get_create_table(dev_conn, table)
            create_table_sql.append(
                f"-- 来自 Dev 的表 `{table}`\n{create_sql}"
            )
        else:
            # 1. 字段删除检测 (Prod 有而 Dev 没有)
            for col in prod_struct[table]:
                if col not in dev_struct[table]:
                    diff_report.append(f"[删除字段] 表 {table} Dev 已删除字段: {col}")
                    alter_sql.append(f"ALTER TABLE `{table}` DROP COLUMN `{col}`;")

            # 2. 字段差异检测 (新增、类型变更、属性变更)
            for col, details in dev_struct[table].items():
                if col not in prod_struct[table]:
                    diff_report.append(f"[新增字段] 表 {table} 缺少字段: {col}")
                    alter_sql.append(
                        f"ALTER TABLE `{table}` ADD COLUMN `{col}` {details['Type']};"
                    )
                else:
                    prod_details = prod_struct[table][col]
                    modify_parts = []

                    # 类型比较
                    if details['Type'] != prod_details['Type']:
                        modify_parts.append(f"类型: {prod_details['Type']} -> {details['Type']}")
                        diff_report.append(
                            f"[字段类型变更] 表 {table}.{col}: {prod_details['Type']} -> {details['Type']}"
                        )

                    # NULL 属性比较
                    dev_null = details['Null'] == 'YES'
                    prod_null = prod_details['Null'] == 'YES'
                    if dev_null != prod_null:
                        null_clause = "NULL" if dev_null else "NOT NULL"
                        modify_parts.append(f"NULL属性: {prod_details['Null']} -> {details['Null']}")
                        diff_report.append(
                            f"[字段NULL变更] 表 {table}.{col}: {prod_details['Null']} -> {details['Null']}"
                        )

                    # Default 值比较
                    dev_default = details.get('Default')
                    prod_default = prod_details.get('Default')
                    if dev_default != prod_default:
                        dev_default_str = f"'{dev_default}'" if dev_default is not None else "NULL"
                        prod_default_str = f"'{prod_default}'" if prod_default is not None else "NULL"
                        modify_parts.append(f"DEFAULT: {prod_default_str} -> {dev_default_str}")
                        diff_report.append(
                            f"[字段DEFAULT变更] 表 {table}.{col}: {prod_default_str} -> {dev_default_str}"
                        )

                    # Comment 比较
                    dev_comment = details.get('Comment', '')
                    prod_comment = prod_details.get('Comment', '')
                    if dev_comment != prod_comment:
                        modify_parts.append(f"COMMENT: '{prod_comment}' -> '{dev_comment}'")
                        diff_report.append(
                            f"[字段COMMENT变更] 表 {table}.{col}: '{prod_comment}' -> '{dev_comment}'"
                        )

                    # 如果有任何变更，生成 MODIFY COLUMN 语句
                    if modify_parts or details['Type'] != prod_details['Type']:
                        modify_sql = f"ALTER TABLE `{table}` MODIFY COLUMN `{col}` {details['Type']}"

                        # 添加 NULL 属性
                        if details['Null'] == 'YES':
                            modify_sql += " NULL"
                        else:
                            modify_sql += " NOT NULL"

                        # 添加 DEFAULT
                        if details.get('Default') is not None:
                            default_val = details['Default']
                            if default_val.upper() != 'NULL':
                                modify_sql += f" DEFAULT '{default_val}'"

                        # 添加 COMMENT
                        if details.get('Comment'):
                            modify_sql += f" COMMENT '{details['Comment']}'"

                        alter_sql.append(modify_sql + ";")

            # 3. 索引差异检测
            dev_indices = get_table_indices(dev_conn, table)
            prod_indices = get_table_indices(prod_conn, table)

            # 检测 Prod 缺少的索引 (需要新增)
            for idx_name, idx_info in dev_indices.items():
                if idx_name not in prod_indices:
                    columns = "`, `".join(idx_info['columns'])
                    diff_report.append(f"[新增索引] 表 {table} 缺少索引: {idx_name} (`{columns}`)")

                    if idx_info['primary']:
                        alter_sql.append(f"ALTER TABLE `{table}` ADD PRIMARY KEY (`{columns}`);")
                    elif idx_info['unique']:
                        alter_sql.append(f"ALTER TABLE `{table}` ADD UNIQUE KEY `{idx_name}` (`{columns}`);")
                    else:
                        alter_sql.append(f"ALTER TABLE `{table}` ADD INDEX `{idx_name}` (`{columns}`);")

            # 检测 Dev 删除的索引 (需要删除)
            for idx_name, idx_info in prod_indices.items():
                if idx_name not in dev_indices:
                    columns = "`, `".join(idx_info['columns'])
                    diff_report.append(f"[删除索引] 表 {table} Dev 已删除索引: {idx_name} (`{columns}`)")

                    if idx_info['primary']:
                        alter_sql.append(f"ALTER TABLE `{table}` DROP PRIMARY KEY;")
                    else:
                        alter_sql.append(f"ALTER TABLE `{table}` DROP INDEX `{idx_name}`;")

    # 写文件
    with open("diff_report.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(diff_report))

    with open("create_missing_tables.sql", "w", encoding="utf-8") as f:
        f.write("\n\n".join(create_table_sql))

    with open("fix_changes.sql", "w", encoding="utf-8") as f:
        f.write("\n".join(alter_sql))

    dev_conn.close()
    prod_conn.close()

    print("\n完成！生成文件：")
    print("1. diff_report.txt")
    print("2. create_missing_tables.sql  （在 Prod 执行）")
    print("3. fix_changes.sql             （在 Prod 执行）")

if __name__ == "__main__":
    compare_dbs()
