import time

from unidecode import unidecode
from pyhive import hive
import pandas as pd




def standardize_sexe(value):
    if str(value).upper().startswith('H') or str(value).upper().startswith('M'):
        return 'M'
    elif str(value).upper().startswith('F'):
        return 'F'
    else:
        return None
# Connect to Hive
with hive.connect('localhost') as conn:
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM Clients12_Mongo_EXT limit 10000')
    chunk_size = 1000

    while True:
        chunk = cursor.fetchmany(chunk_size)
        if not chunk:
            break
        df = pd.DataFrame(chunk, columns=[desc[0] for desc in cursor.description])

        df.replace({'false': 0, 'true': 1}, inplace=True)
        replacement_dict = {'�': 'e'}
        df['clients12_mongo_ext.sexe'] = df['clients12_mongo_ext.sexe'].apply(standardize_sexe)
        df.replace({'false': 0, 'true': 1}, inplace=True)
        df['clients12_mongo_ext.situationFamiliale'].replace(replacement_dict, regex=True, inplace=True)
        df.loc[df['clients12_mongo_ext.situationFamiliale'].str.startswith('Seu'), 'clients12_mongo_ext.situationFamiliale'] = 'Seul(e)'

        df = df[(df['clients12_mongo_ext.sexe'] == 'M') | (df['clients12_mongo_ext.sexe'] == 'F')]
        df.reset_index(drop=True, inplace=True)
        df = df[df['clients12_mongo_ext.taux'] != '-1']
        df.reset_index(drop=True, inplace=True)
        # Remove rows where any column contains '?'
        df = df[~df.applymap(lambda x: x == '?').any(axis=1)]
        df.reset_index(drop=True, inplace=True)
        # Remove rows where any column contains ' ' empty
        df = df[~df.applymap(lambda x: x == ' ').any(axis=1)]
        df.reset_index(drop=True, inplace=True)
        df = df[~df.applymap(lambda x: x == 'N/D').any(axis=1)]
        df.reset_index(drop=True, inplace=True)


        new_cursor = hive.connect('localhost').cursor()
        chunk_size2 = 500
        new_table_name = 'Clients12_Mongo_EXT_updated'

        for start in range(0, len(df), chunk_size2):
            end = min(start + chunk_size2, len(df))
            chunk = df.iloc[start:end]
            values = []
            for _, row in chunk.iterrows():
                row_values = [f"'{value}'" if value is not None else 'NULL' for value in row]
                values.append(f"({', '.join(row_values)})")

            values_str = ', '.join(values)
            insert_statement = f"INSERT INTO {new_table_name} VALUES {values_str}"

            if start % 100 == 0:
                status = f"Processed {start}/{len(df)} chunks"
                print(status)

            try:
                new_cursor.execute(insert_statement)
            except Exception as e:
                print(f"An error occurred: {e}")
                break
        new_cursor.close()


    conn.close()