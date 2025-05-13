import psycopg2
from psycopg2.extras import execute_batch
from faker import Faker
from tqdm import tqdm

fake = Faker()

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "postgres",
    "user": "postgres",
    "password": "postgres"
}

TOTAL_ROWS = 1_000_000
TABLE_COUNT = 10
ROWS_PER_TABLE = TOTAL_ROWS // TABLE_COUNT

TABLE_PREFIX = "paysera"

def connect_db():
    return psycopg2.connect(**DB_CONFIG)

def create_table(cur, table_name):
    cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {table_name} (
            id SERIAL PRIMARY KEY,
            full_name TEXT,
            email TEXT UNIQUE,
            address TEXT,
            phone TEXT,
            company TEXT,
            created_at TIMESTAMP DEFAULT NOW()
        );
    """)

def table_row_count(cur, table_name):
    cur.execute(f"SELECT COUNT(*) FROM {table_name};")
    return cur.fetchone()[0]

def generate_fake_row():
    return (
        fake.name(),
        fake.unique.email(),
        fake.address().replace("\n", ", "),
        fake.phone_number(),
        fake.company()
    )

def insert_rows(conn, cur, table_name, target_rows):
    existing_rows = table_row_count(cur, table_name)
    rows_to_insert = target_rows - existing_rows

    if rows_to_insert <= 0:
        print(f"Table `{table_name}` already has {existing_rows} rows.")
        return

    print(f"Inserting {rows_to_insert} rows into `{table_name}`...")

    batch_size = 1000
    for _ in tqdm(range(0, rows_to_insert, batch_size)):
        batch = [generate_fake_row() for _ in range(min(batch_size, rows_to_insert))]
        execute_batch(cur, f"""
            INSERT INTO {table_name} (full_name, email, address, phone, company)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (email) DO NOTHING;
        """, batch)
        conn.commit()

def main():
    conn = connect_db()
    cur = conn.cursor()

    for i in range(1, TABLE_COUNT + 1):
        table_name = f"{TABLE_PREFIX}_{i}"
        create_table(cur, table_name)
        conn.commit()
        insert_rows(conn, cur, table_name, ROWS_PER_TABLE)

    cur.close()
    conn.close()
    print("Seeding completed.")

if __name__ == "__main__":
    main()
