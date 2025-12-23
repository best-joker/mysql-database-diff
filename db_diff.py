import pymysql
import sys

def get_db_structure(conn):
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    cursor.execute("SHOW TABLES")
    tables = [list(row.values())[0] for row in cursor.fetchall()]

    structure = {}
    for table in tables:
        cursor.execute(f"DESCRIBE `{table}`")
        structure[table] = {row['Field']: row for row in cursor.fetchall()}

    cursor.close()
    return structure

def get_create_table(conn, table):
    cursor = conn.cursor()
    cursor.execute(f"SHOW CREATE TABLE `{table}`")
    create_sql = cursor.fetchone()[1]
    cursor.close()
    return create_sql + ";\n"

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
            for col, details in dev_struct[table].items():
                if col not in prod_struct[table]:
                    diff_report.append(f"[新增字段] 表 {table} 缺少字段: {col}")
                    alter_sql.append(
                        f"ALTER TABLE `{table}` ADD COLUMN `{col}` {details['Type']};"
                    )
                elif details['Type'] != prod_struct[table][col]['Type']:
                    diff_report.append(
                        f"[字段变更] 表 {table}.{col} 类型不一致: "
                        f"Dev({details['Type']}) vs Prod({prod_struct[table][col]['Type']})"
                    )
                    alter_sql.append(
                        f"ALTER TABLE `{table}` MODIFY COLUMN `{col}` {details['Type']};"
                    )

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
