/* Snowflake */
CREATE TABLE IF NOT EXISTS swimstats.club (
    club_num_id SERIAL PRIMARY KEY,
    club_name domaine.nom NOT NULL
);

CREATE TABLE IF NOT EXISTS swimstats.style (
    style_num_id SERIAL PRIMARY KEY,
    style_name domaine.nom NOT NULL
);  

CREATE TABLE IF NOT EXISTS swimstats.distance (
    distance_num_id SERIAL PRIMARY KEY,
    distance_metre domaine.metre NOT NULL
);

CREATE TABLE IF NOT EXISTS swimstats.sex (
    sex_code domaine.code PRIMARY KEY,
    sex_name domaine.nom NOT NULL
);

CREATE TABLE IF NOT EXISTS swimstats.country (
    country_code domaine.code PRIMARY KEY,
    country_name domaine.nom NOT NULL
);

/* Star */
CREATE TABLE IF NOT EXISTS swimstats.place (
    place_num_id SERIAL PRIMARY KEY,
    city_name domaine.nom NOT NULL,
    country_code domaine.nom NOT NULL REFERENCES swimstats.country(country_code)
);

CREATE TABLE IF NOT EXISTS swimstats.race (
    race_num_id SERIAL PRIMARY KEY,
    distance_num_id INT NOT NULL REFERENCES  swimstats.distance(distance_num_id),
    style_num_id INT NOT NULL REFERENCES  swimstats.style(style_num_id)
);

CREATE TABLE IF NOT EXISTS swimstats.swimmer (
    swimmer_num_id domaine.num_id PRIMARY KEY,
    swimmer_firstname domaine.prenom NOT NULL,
    swimmer_lastname domaine.nom NOT NULL,
    birth_year domaine.annee NOT NULL,
    club_num_id domaine.num_id NOT NULL REFERENCES  swimstats.club(club_num_id),
    sex_code domaine.code NOT NULL REFERENCES  swimstats.sex(sex_code),
    nationality_code domaine.code NOT NULL REFERENCES  swimstats.nationality(nationality_code)
);

/* Fact */

CREATE TABLE IF NOT EXISTS swimstats.result (
    result_num_id SERIAL PRIMARY KEY,
    swimmer_num_id domaine.num_id NOT NULL REFERENCES swimstats.swimmer(swimmer_num_id),
    race_num_id domaine.num_id NOT NULL REFERENCES swimstats.race(race_num_id),
    place_num_id domaine.num_id NOT NULL REFERENCES swimstats.place(place_num_id),
    pool_metre domaine.metre NOT NULL,
    race_date domaine.debut_date NOT NULL,
    time_millisecond domaine.duree_seconde NOT NULL,
    race_points domaine.cote NOT NULL
);