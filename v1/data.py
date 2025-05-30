from sklearn.linear_model import LinearRegression
import numpy as np
import pandas as pd
import os
from sqlalchemy import create_engine


def compute_trend(group, window=3):
    trends = []
    for i in range(len(group)):
        if i < window - 1:
            trends.append(np.nan)
        else:
            y = group['time_millisecond'].iloc[i - window + 1:i + 1].values.reshape(-1, 1)
            x = np.arange(window).reshape(-1, 1)
            model = LinearRegression().fit(x, y)
            slope = model.coef_[0][0]
            trends.append(slope)
    return pd.Series(trends, index=group.index)


# Load data from PostgreSQL database
def get_data(query):
    db_config = {
        'dbname': os.getenv('DB_NAME', 'SwimstatsDB'),
        'user': os.getenv('DB_USER', 'postgres'),
        'password': os.getenv('DB_PASSWORD', 'pga'),
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': os.getenv('DB_PORT', 5432)
    }

    connection_string = f"postgresql://{db_config['user']}:{db_config['password']}@{db_config['host']}:{db_config['port']}/{db_config['dbname']}"
    engine = create_engine(connection_string)
    
    data = pd.read_sql_query(query, engine)

    data['race_date'] = pd.to_datetime(data['race_date'])
    data['month'] = data['race_date'].dt.month
    data['year'] = data['race_date'].dt.year

    # Compute season year
    data['season_year'] = data['year']
    data.loc[data['month'] <= 8, 'season_year'] = data['year'] - 1

    # Compute age for the season
    data['age'] = data['season_year'] - pd.to_datetime(data['birth_year']).dt.year
    
    data = data.sort_values(by=['swimmer', 'race_date'])

    # Compute previous race_date
    data['previous_race'] = data.groupby('swimmer')['race_date'].shift(1)
    
    # Compute previous_time (temps précédent)
    data['previous_time'] = data.groupby('swimmer')['time_millisecond'].shift(1)

    # Compute days since last race
    data['days_since_last_race'] = (data['race_date'] - data['previous_race']).dt.days

    # compute trend score
    data['trend_score'] = data.groupby('swimmer', group_keys=False).apply(lambda g: compute_trend(g, window=3))

    # Compute age at first race
    first_race_age = data.groupby('swimmer')['age'].transform('first')
    data['first_race_age'] = first_race_age

    # Compute season year as before
    data['season_year'] = data['race_date'].dt.year
    data.loc[data['race_date'].dt.month <= 8, 'season_year'] -= 1

    # rename columns for consistency
    data['time'] = data['time_millisecond']
    data['distance'] = data['distance_metre']
    data['stroke'] = data['style_name']
    data['pool'] = data['pool_metre'].apply(lambda x: '50m' if x == 50 else '25m')


    df = (
        data.groupby('swimmer')
        .filter(lambda x: len(x) > 10 and 
            any(x['age'] == 14) and 
            any(x['age'] == 18))
    )
    return df

def load_data():
    # SQL query to fetch data
    query = """
        SELECT 
            s.swimmer_firstname || ' ' || s.swimmer_lastname AS swimmer,
            s.swimmer_num_id,
            s.sex_code AS sex,
            s.club_num_id,
            r.race_date,
            r.time_millisecond,
            s.birth_year,
            st.style_name,
            r.pool_metre,
            d.distance_metre
        FROM 
            swimstats.result r
        JOIN 
            swimstats.swimmer s ON r.swimmer_num_id = s.swimmer_num_id
        JOIN 
            swimstats.race ra ON r.race_num_id = ra.race_num_id
        JOIN 
            swimstats.style st ON ra.style_num_id = st.style_num_id
        JOIN 
            swimstats.distance d ON ra.distance_num_id = d.distance_num_id
        WHERE 
            st.style_name = 'Freestyle' 
            AND d.distance_metre = 400 
            AND r.time_millisecond < 480
    """

    df = get_data(query)
    return df

if __name__ == "__main__":
    df = load_data()
    print(df.head())
    print(df.describe())