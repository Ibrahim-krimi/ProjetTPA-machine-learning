import time

from unidecode import unidecode
from pyhive import hive
import pandas as pd
new_table_name = 'Immatriculations_Mongo_EXT_updated'

# Connect to Hive
with hive.connect('localhost') as conn:
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM Immatriculations_Mongo_EXT  ')

    chunk_size = 1000

    while True:
        chunk = cursor.fetchmany(chunk_size)
        if not chunk:
            break
        df = pd.DataFrame(chunk, columns=[desc[0] for desc in cursor.description])
        df.replace({'false': 0, 'true': 1}, inplace=True)
        replacement_dict = {'�': 'e'}
        df['immatriculations_mongo_ext.longueur'].replace(replacement_dict, regex=True, inplace=True)
        # Convert 'marque' column to uppercase
        df['immatriculations_mongo_ext.marque'] = df['immatriculations_mongo_ext.marque'].str.upper()


        new_cursor = hive.connect('localhost').cursor()
        chunk_size2 = 500

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
        time.sleep(60)

    conn.close()