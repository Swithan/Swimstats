import psycopg2
from psycopg2 import sql

# Step 1: Connect to the PostgreSQL database
def connect_to_db():
    try:
        # Connect to your PostgreSQL database
        conn = psycopg2.connect(
            dbname="swimstats",      # Replace with your database name
            user="postgres",   # Replace with your username
            password="admin", # Replace with your password
            # host="172.18.0.2",   # py
            host="172.19.0.2",   # pyf
            port="5432"         # Replace with your port if needed
        )
        return conn
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return None

# Step 2: Create tables
def create_tables(conn):
    try:
        with conn.cursor() as cur:
            # Create Swimmer table
            cur.execute('''
                CREATE TABLE IF NOT EXISTS Swimmers (
                    s_id VARCHAR(255) PRIMARY KEY,  -- Athlete ID (unique)
                    lastname VARCHAR(255) NOT NULL,
                    firstname VARCHAR(255) NOT NULL,
                    birthyear INTEGER,
                    sex VARCHAR(1),
                    nationality VARCHAR(50),
                    last_club VARCHAR(255),
                    pb VARCHAR(50),
                    results BOOLEAN DEFAULT FALSE
                );
            ''')

            # Create Race table
            cur.execute('''
                CREATE TABLE IF NOT EXISTS Races (
                    r_id SERIAL PRIMARY KEY,  -- Automatically generated race ID
                    s_id VARCHAR(255) REFERENCES Swimmers(s_id) ON DELETE CASCADE,
                    distance VARCHAR(10) NOT NULL,
                    stroke VARCHAR(50),
                    pool VARCHAR(50),
                    time VARCHAR(50),
                    points INTEGER,
                    race_date DATE,
                    place VARCHAR(255)
                );
            ''')

            # Create splits table
            cur.execute('''
                CREATE TABLE IF NOT EXISTS Race_Splits (
                    rs_id SERIAL PRIMARY KEY,
                    race_id INTEGER REFERENCES Races(r_id) ON DELETE CASCADE,
                    split_distance VARCHAR(10),
                    split_time VARCHAR(50),
                    subsplit_distance VARCHAR(10),
                    subsplit_time VARCHAR(50)
                );
            ''')
            
            conn.commit()
            print("Tables created successfully.")
            with (open('swimmers.csv', 'r')) as f:
                cur.copy_expert("COPY Swimmers FROM STDIN WITH CSV HEADER", f)
                conn.commit()
    except Exception as e:
        print(f"Error creating tables: {e}")
        conn.rollback()

def insert_swimmer(conn, swimmer_data):
    try:
        with conn.cursor() as cur:
            # Insert swimmer data into the Swimmer table
            cur.execute('''
                INSERT INTO Swimmers (s_id, lastname, firstname, birthyear, sex, nationality, last_club, pb)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (s_id) DO NOTHING;
            ''', (swimmer_data['s_id'], swimmer_data['lastname'], swimmer_data['firstname'],
                  swimmer_data['birthyear'], swimmer_data['sex'], swimmer_data['nationality'], swimmer_data['last_club'], swimmer_data['pb']))
            
            conn.commit()
    except Exception as e:
        print(f"Error inserting swimmer: {e}")
        conn.rollback()

def insert_race(conn, race_data):
    try:
        with conn.cursor() as cur:
            # Insert race data into the Race table
            cur.execute('''
                INSERT INTO Races (s_id, distance, stroke, pool, time, points, race_date, place)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING r_id;
            ''', (race_data['s_id'], race_data['distance'], race_data['stroke'], race_data['pool'],
                  race_data['time'], race_data['points'], race_data['race_date'], race_data['place']))
            
            inserted_r_id = cur.fetchone()[0]
            conn.commit()
            return inserted_r_id
    except Exception as e:
        print(f"Error inserting race: {e}")
        conn.rollback()
        return None

def get_races(conn):
    try:
        with conn.cursor() as cur :
            cur.execute('''SELECT * FROM races''')
            return cur.fetchall() 
    except Exception as e:
        print(f"Error retrieving races : {e}")
        conn.rollback()


def insert_split(conn, r_id, split_data):
    try:
        with conn.cursor() as cur:
            # Insert race data into the Race table
            cur.execute('''
                INSERT INTO race_splits (race_id, split_distance, split_time, subsplit_distance, subsplit_time)
                VALUES (%s, %s, %s, %s, %s);
            ''', (r_id, split_data['split_dist'], split_data['split_time'], 
                  split_data['subsplit_dist'], split_data['subsplit_time']))
            
            conn.commit()
    except Exception as e:
        print(f"Error inserting split: {e}")
        conn.rollback()

def get_todo_swimmers(conn):
    try:
        with conn.cursor() as cur :
            cur.execute('''SELECT s_id FROM swimmers WHERE results = False;''')
            return cur.fetchall() 
    except Exception as e:
        print(f"Error retreiving TODO swimmers : {e}")
        conn.rollback()

def get_f_todo_swimmers(conn):
    try:
        with conn.cursor() as cur :
            cur.execute('''SELECT s_id FROM swimmers WHERE results = False AND sex = 'F';''')
            return cur.fetchall() 
    except Exception as e:
        print(f"Error retreiving TODO swimmers : {e}")
        conn.rollback()

def get_done_swimmers(conn):
    try:
        with conn.cursor() as cur :
            cur.execute('''SELECT s_id, firstname, lastname FROM swimmers WHERE results;''')
            return cur.fetchall() 
    except Exception as e:
        print(f"Error retreiving TODO swimmers : {e}")
        conn.rollback()

def get_swimmer_by_club(conn, club):
    try:
        with conn.cursor() as cur :
            cur.execute('''SELECT s_id FROM swimmers HAVING last_club = ;''')
            return cur.fetchall() 
    except Exception as e:
        print(f"Error retreiving swimmers by club : {e}")
        conn.rollback()

def update_swimmer_has_results(conn, swimmer): 
    try:
        with conn.cursor() as cur :
            cur.execute('''UPDATE swimmers SET results = true WHERE s_id = %s;''', (swimmer,))
            updated_row_count = cur.lastrowid
            return updated_row_count > 0
    except Exception as e:
        print(f"Error updating done swimmers : {e}")
        conn.rollback()
