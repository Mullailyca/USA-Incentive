import os
import pyodbc
import pandas as pd
from datetime import datetime, timedelta

def get_db_connection(server, database, username, password):
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"UID={username};"
        f"PWD={password};"
    )
    return pyodbc.connect(conn_str)

def get_date_suffix(format_type='day-1'):
    today = datetime.now()
    if format_type.lower() == 'day-1':
        date_val = today - timedelta(days=1)
        return date_val.strftime('%Y%m%d')
    elif format_type.lower() == 'month-1':
        first_day_this_month = today.replace(day=1)
        last_month = first_day_this_month - timedelta(days=1)
        return last_month.strftime('%Y%m')
    elif format_type.lower() == 'month':
        return today.strftime('%Y%m')
    else:
        raise ValueError(f"Unsupported date format_type '{format_type}'")

def export_multiple_tables_same_file(conn, tables_dict, export_dir, file_name, date_format='day-1'):
    print('multiple_tables_same_file')
    os.makedirs(export_dir, exist_ok=True)
    date_suffix = get_date_suffix(date_format)
    file_name = f"{file_name}.xlsx"
    excel_path = os.path.join(export_dir, file_name)

    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        for sheet_name, table_name in tables_dict.items():
            df = pd.read_sql(f"SELECT * FROM {table_name}", conn).fillna("NULL")
            df.to_excel(writer, sheet_name=sheet_name, index=False)

    print(f'Success! Exported multiple tables into one Excel file: {excel_path}')
    return excel_path

def export_multiple_tables_diff_files(conn, tables_dict, export_dir, chunksize=50000):
    print('multiple_tables_fast_chunk (Optimized)')
    
    os.makedirs(export_dir, exist_ok=True)
    exported_files = []

    for file_name_key, table_name in tables_dict.items():
        print(f"Exporting table: {table_name} in chunks of {chunksize} rows ...")

        file_path = os.path.join(export_dir, f"{file_name_key}.xlsx")

        # Remove old file if exists
        if os.path.exists(file_path):
            os.remove(file_path)

        query = f"SELECT * FROM {table_name}"

        # 🟢 Build a list of chunks in memory as DataFrames
        chunks = []
        for chunk_df in pd.read_sql(query, conn, chunksize=chunksize):
            chunk_df = chunk_df.fillna("NULL")
            chunks.append(chunk_df)

        # 🟢 Concatenate once — much faster than writing per chunk
        final_df = pd.concat(chunks, ignore_index=True)

        # 🟢 Write only once to Excel → super fast
        final_df.to_excel(file_path, index=False)

        print(f"✅ Success! Exported '{table_name}' → {file_path}")
        exported_files.append(file_path)
    

    return exported_files

def export_table_split_sheets(conn, table_name, split_column, export_dir, file_prefix, date_format='day-1', chunk_size=10000):
    import time
    print('export_table_split_sheets_chunked with chunking')
    os.makedirs(export_dir, exist_ok=True)
    date_suffix = get_date_suffix(date_format)
    file_name = f"{file_prefix}_{table_name}_split_by_{split_column}_{date_suffix}.xlsx"
    excel_path = os.path.join(export_dir, file_name)

    # 1) Get distinct values for the split column
    distinct_values_query = f"SELECT DISTINCT {split_column} FROM {table_name}"
    distinct_values = pd.read_sql(distinct_values_query, conn)[split_column].dropna().tolist()

    if not distinct_values:
        raise ValueError(f"No distinct values found in column '{split_column}' for table '{table_name}'")

    # Sort alphabetically
    distinct_values = sorted(distinct_values)

    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        for val in distinct_values:
            print(f"Processing {split_column} = {val}")

            # Prepare to accumulate chunks here
            chunks = []

            # Use SQL parameterized query with chunking
            sql_query = f"SELECT * FROM {table_name} WHERE {split_column} = ?"

            try:
                for chunk in pd.read_sql(sql_query, conn, params=[val], chunksize=chunk_size):
                    chunk = chunk.fillna("NULL")
                    chunks.append(chunk)
            except Exception as e:
                print(f"Error reading chunk for {val}: {e}")
                continue

            if not chunks:
                print(f"No data found for {split_column} = {val}, skipping sheet.")
                continue

            df_val = pd.concat(chunks, ignore_index=True)
            print(f"Writing sheet: {val} with {len(df_val)} rows")
            df_val.to_excel(writer, sheet_name=str(val), index=False)

    print(f'Success! Exported "{table_name}" split by "{split_column}" into sheets in file: {excel_path}')
    return excel_path




if __name__ == "__main__":
    # Set your database connection details here
    SERVER = '10.198.41.207'
    DATABASE = 'MVNOREPORT_USA_GT'
    USERNAME = 'MIS_TEAM'
    PASSWORD = 'M!$T3Am#135'

    Export_root_res = r"C:\Users\mull8523\OneDrive - Lyca Group\KB\USA\202601\kb_nolive\USA_TEST"

 
    today=datetime.now()
    first_day_this_month = today.replace(day=1)
    last_month = first_day_this_month - timedelta(days=1)
    month= last_month.strftime('%Y%m')


    # Tables to export
    TABLE_NAME_1 = 'Mis_1717_ins_comm'#IC
    TABLE_NAME_2=f'Mis_1717_USA_Missing_IC_{month}'#IC
    TABLE_NAME_3 = f'Mis_1717_USA_Missing_IC_{month}_mismatch'#IC
    TABLE_NAME_4= 'Mis_1717_USA_Reseller_output'#RESELLEROURPUT
    TABLE_NAME_5= 'Mis_1717_USA_DEALERLINE_output'#DEALERLINE
    TABLE_NAME_6= 'Mis_1717_USA_Detail_portin_WS'#resellerportin
    TABLE_NAME_7= 'MIS_1001_RES_DETAIL_OUTPUT'# res detail output
    TABLE_NAME_8= 'Mis_1717_USA_Retailer_output' # ret output 
    TABLE_NAME_9= 'Mis_1717_USA_IC_Retailer_output' #ret ic
    TABLE_NAME_10='Mis_1717_USA_Detail_portin_HS'#ret portin
    TABLE_NAME_11='MIS_1001_RET_DETAIL_OUTPUT' #ret idetail output
    TABLE_NAME_12='MIS_1001_5G_SIM_OUTPUT'
    TABLE_NAME_13=f'Mis_1717_USA_Retailer_output_Wirelessshops_{month}_OUTPUT'

    ins_file= f'{month}_USA_Instant_comm'
    res_op_file=f'{month}_USA_Reseller'
    res_detail=f'{month}_USA_Detail_report_TP_DP_LI'
    ret_op_file=f'{month}_USA_Retailer'
    ret_detail=f'{month}_USA_Detail_report'
    G_SIM=f'{month}_USA_5Gsims_activation'
    uplift=f'{month}_USA_FCA_Uplift_Bonus'

 
    tables_ins = {
        "INSTANT_COMM": TABLE_NAME_1,
        "INSTANT_COMM_MISSING": TABLE_NAME_2,
        "INSTANT_COMM_MISMATCH": TABLE_NAME_3
    }
    tables_res = {
        "RESELLER_OUTPUT": TABLE_NAME_4,
        "DEALERLINE_output": TABLE_NAME_5,
        "PORTIN_WS": TABLE_NAME_6
    }
    tables_ret = {
        "RETAILER_OUTPUT": TABLE_NAME_8,
        "IC_Retailer_OUTPUT": TABLE_NAME_9,
        "PORTIN_HS": TABLE_NAME_10
    }

    DIS_TABLES={
        res_detail:TABLE_NAME_7,
        G_SIM:TABLE_NAME_12,
        uplift:TABLE_NAME_13,
        ret_detail:TABLE_NAME_11

    }


    
    conn = None
    try:    
        conn = get_db_connection(SERVER, DATABASE, USERNAME, PASSWORD)
        print(datetime.now())

        # 1) Export multiple tables in the same Excel file (multiple sheets)
        export_multiple_tables_same_file(conn, tables_ins, Export_root_res, ins_file, date_format='month-1')
        export_multiple_tables_same_file(conn, tables_res, Export_root_res,res_op_file , date_format='month-1')
        export_multiple_tables_same_file(conn, tables_ret, Export_root_res, ret_op_file, date_format='month-1')

        # 2) Export multiple tables in different Excel files
        export_multiple_tables_diff_files(conn, DIS_TABLES, Export_root_res)
        #print(datetime.now())

        # 3) Export one table split by a column (e.g. 'Country'), sheets alphabetically ordered
        #export_table_split_sheets(conn, TABLE_NAME_1, 'Country', Export_root_res, FILE_PREFIX, date_format='month-1')

    except Exception as e:
        print(f"Error: {e}")
    finally:
        if conn:
            conn.close()
