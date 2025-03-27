CREATE TABLE IF NOT EXISTS club (
    club_num_id SERIAL PRIMARY KEY,
    club_name domaine.nom NOT NULL,
);

CREATE TABLE IF NOT EXISTS style (
    style_num_id SERIAL PRIMARY KEY,
    style_name domaine.nom NOT NULL,
);  

CREATE TABLE IF NOT EXISTS distance (
    distance_num_id SERIAL PRIMARY KEY,
    distance_metre domaine.metre NOT NULL,
);

CREATE TABLE IF NOT EXISTS race (
    race_num_id SERIAL PRIMARY KEY,
    distance_num_id INT NOT NULL,
    style_num_id INT NOT NULL,
    FOREIGN KEY (distance_num_id) REFERENCES distance.distance_num_id,
    FOREIGN KEY (style_num_id) REFERENCES style.style_num_id
);

CREATE TABLE IF NOT EXISTS place (
    place_num_id SERIAL PRIMARY KEY,
    place_name domaine.nom NOT NULL,
);

CREATE TABLE IF NOT EXISTS sex (
    sex_code domaine.code PRIMARY KEY,
    sex_name domaine.nom NOT NULL
);

CREATE TABLE IF NOT EXISTS nationality (
    nationality_code domaine.code PRIMARY KEY,
    nationaity_name domaine.nom NOT NULL
);

CREATE TABLE IF NOT EXISTS swimmer (
    swimmer_num_id domaine.num_id PRIMARY KEY,
    swimmer_firstname domaine.prenom NOT NULL,
    swimmer_lastname domaine.nom NOT NULL,
    birth_year domaine.annee NOT NULL,
    club_num_id domaine.num_id NOT NULL,
    sex_code domaine.code NOT NULL,
    nationality_code domaine.code NOT NULL,
    FOREIGN KEY (club_num_id) REFERENCES club.club_num_id,
    FOREIGN KEY (sex_code) REFERENCES sex.sex_code,
    FOREIGN KEY (nationality_code) REFERENCES nationality.nationality_code
);

CREATE TABLE IF NOT EXISTS result (
    result_num_id SERIAL PRIMARY KEY,
    swimmer_num_id domaine.num_id NOT NULL,
    race_num_id domaine.num_id NOT NULL,
    place_num_id domaine.num_id NOT NULL,
    race_date domaine.date NOT NULL,
    time_millisecond domaine.millisecond NOT NULL,
    race_points domaine.cote NOT NULL,
    FOREIGN KEY (swimmer_num_id) REFERENCES swimmer.swimmer_num_id,
    FOREIGN KEY (race_num_id) REFERENCES race.race_num_id,
    FOREIGN KEY (place_num_id) REFERENCES place.place_num_id
);