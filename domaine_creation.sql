SET search_path TO domaine;

-- domaine_type BOOLEEN

DO $$ BEGIN PERFORM 'true'::domaine.booleen; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.booleen AS boolean;
END $$;

-- domaine_type DATE

DO $$ BEGIN PERFORM '20250101'::domaine.annee; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.annee AS date 
CONSTRAINT jour_un CHECK(DATE_PART('DAY',VALUE) = 1)
CONSTRAINT mois_un CHECK(DATE_PART('MONTH',VALUE) = 1);
END $$;

DO $$ BEGIN PERFORM '20250312'::domaine.date; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.date AS date;
END $$;

DO $$ BEGIN PERFORM '20250312 09:30'::domaine.date_heure; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.date_heure AS timestamp;
END $$;

DO $$ BEGIN PERFORM '20250101'::domaine.debut_annee; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.debut_annee AS date 
CONSTRAINT jour_un CHECK(DATE_PART('DAY',VALUE) = 1)
CONSTRAINT mois_un CHECK(DATE_PART('MONTH',VALUE) = 1)
NOT NULL;
END $$;

DO $$ BEGIN PERFORM '20250312'::domaine.debut_date; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.debut_date AS date
NOT NULL;
END $$;

DO $$ BEGIN PERFORM '20250312 09:30'::domaine.debut_date_heure; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.debut_date_heure AS timestamp
NOT NULL;
END $$;

DO $$ BEGIN PERFORM '09:30'::domaine.debut_heure; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.debut_heure AS time
NOT NULL;
END $$;

DO $$ BEGIN PERFORM '20250301'::domaine.debut_mois; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.debut_mois AS date
NOT NULL
CONSTRAINT jour_un CHECK(DATE_PART('DAY',VALUE) = 1);
END $$;

DO $$ BEGIN PERFORM '20250101'::domaine.fin_annee; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.fin_annee AS date 
CONSTRAINT jour_un CHECK(DATE_PART('DAY',VALUE) = 1)
CONSTRAINT mois_un CHECK(DATE_PART('MONTH',VALUE) = 1)
DEFAULT('9999-01-01')
NOT NULL;
END $$;
	
DO $$ BEGIN PERFORM '20250312'::domaine.fin_date; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.fin_date AS date
DEFAULT('9999-12-31')
NOT NULL;
END $$;

DO $$ BEGIN PERFORM '20250312 09:30'::domaine.fin_date_heure; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.fin_date_heure AS timestamp
DEFAULT('9999-12-31 23:59:59')	
NOT NULL;
END $$;

DO $$ BEGIN PERFORM '09:30'::domaine.fin_heure; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.fin_heure AS time
DEFAULT('23:59:59')
NOT NULL;
END $$;

DO $$ BEGIN PERFORM '20250301'::domaine.fin_mois; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.fin_mois AS date
CONSTRAINT jour_un CHECK(DATE_PART('DAY',VALUE) = 1)
DEFAULT('9999-12-01')
NOT NULL;
END $$;

DO $$ BEGIN PERFORM '09:30'::domaine.heure; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.heure AS time;
END $$;

DO $$ BEGIN PERFORM '20250101'::domaine.millesime; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.millesime AS date 
CONSTRAINT jour_un CHECK(DATE_PART('DAY',VALUE) = 1)
CONSTRAINT mois_un CHECK(DATE_PART('MONTH',VALUE) = 1);
END $$;

DO $$ BEGIN PERFORM '20250301'::domaine.mois; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.mois AS date 
CONSTRAINT jour_un CHECK(DATE_PART('DAY',VALUE) = 1);
END $$;

-- domaine_type ID

DO $$ BEGIN PERFORM 9797::domaine.bancaire_carte_numero; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.bancaire_carte_numero AS bigint
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0)
CONSTRAINT check_digit CHECK ((VALUE % 100) = CASE WHEN ((VALUE /100) % 97) = 0 THEN 97 ELSE (VALUE /100) % 97 END);
END $$;

DO $$ BEGIN PERFORM 123::domaine.barre_num_code; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.barre_num_code AS bigint
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.code; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.code AS character varying(36)
CONSTRAINT minuscule_ou_majuscule	CHECK (VALUE = LOWER(VALUE) OR VALUE = UPPER(VALUE))
CONSTRAINT format CHECK (VALUE ~* '^[a-z][a-z0-9\-_]*$');
END $$;

DO $$ BEGIN PERFORM 'abc@abc.com'::domaine.email_adresse; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.email_adresse AS character varying(256)
CONSTRAINT format CHECK (VALUE ~ '^[a-z0-9!#\$%&''\*\+\-\/=?\^_`\{\|\}~]+(\.[a-z0-9!#\$%&''\*\+\-\/=?\^_`\{\|\}~]+)*@[a-z0-9][a-z0-9\-]*(\.[a-z0-9][a-z0-9\-]*)*$');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.id; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.id AS character varying(36)
CONSTRAINT minuscule_ou_majuscule	CHECK (VALUE = LOWER(VALUE) OR VALUE = UPPER(VALUE))
CONSTRAINT format CHECK (VALUE ~* '^[a-z0-9\-_]+$')
CONSTRAINT au_moins_une_lettre CHECK (VALUE ~* '^.*[a-z].*$');
END $$;
	
DO $$ BEGIN PERFORM 123::domaine.num_id; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.num_id AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;
	
DO $$ BEGIN PERFORM 'BE68539007547034'::domaine.iban_id; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.iban_id AS character varying(34)
CONSTRAINT format CHECK (VALUE ~ '[A-Z]{2}\d{2}[A-Z0-9]+\d{2}$');
END $$;
	
DO $$ BEGIN PERFORM 'ABC'::domaine.immatriculation_id; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.immatriculation_id AS character varying(36)
CONSTRAINT format CHECK (VALUE ~ '^[A-Z0-9\-]+(\s[A-Z0-9\-]+)*$');
END $$;
	
DO $$ BEGIN PERFORM 9797::domaine.national_registre_numero; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.national_registre_numero AS bigint
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0) 
CONSTRAINT mod97 CHECK ((97-MOD(DIV(ABS(VALUE),100),97)) = MOD(ABS(VALUE),100));
END $$;
	
-- Obsolète - utiliser plutôt num_code
DO $$ BEGIN PERFORM 123::domaine.numerique_code; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.numerique_code AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;
	
DO $$ BEGIN PERFORM 123::domaine.num_code; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.num_code AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;
	
-- Obsolète - utiliser plutôt num_id
DO $$ BEGIN PERFORM 123::domaine.numerique_id; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.numerique_id AS bigint
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;
	
DO $$ BEGIN PERFORM 123::domaine.numero; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.numero AS bigint
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.url; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.url AS character varying(128)
CONSTRAINT zero_espace CHECK (POSITION(' ' IN VALUE) = 0)
CONSTRAINT minuscule CHECK (VALUE = LOWER(VALUE));
END $$;
	
-- domaine_type LOCALISATION

DO $$ BEGIN PERFORM 'abc'::domaine.gps_coordonnees; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.gps_coordonnees AS character varying(64)
CONSTRAINT zero_espace CHECK (POSITION(' ' IN VALUE) = 0);
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.latitude; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.latitude AS character varying(64)
CONSTRAINT zero_espace CHECK (POSITION(' ' IN VALUE) = 0);
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.longitude; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.longitude AS character varying(64)
CONSTRAINT zero_espace CHECK (POSITION(' ' IN VALUE) = 0);
END $$;

-- domaine_type MESURE

DO $$ BEGIN PERFORM 123::domaine.cl; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.cl AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.cm; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.cm AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.cm3; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.cm3 AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.comptage; EXCEPTION WHEN undefined_object THEN	
CREATE DOMAIN domaine.comptage AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

DO $$ BEGIN PERFORM 123::domaine.cote; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.cote AS numeric(10,1);
END $$;

DO $$ BEGIN PERFORM 123::domaine.duree_annee; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.duree_annee AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

DO $$ BEGIN PERFORM '09:30'::domaine.duree_heure; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.duree_heure AS time;
END $$;

DO $$ BEGIN 
    PERFORM 83.43::domaine.duree_seconde; 
EXCEPTION WHEN undefined_object THEN
    CREATE DOMAIN domaine.duree_seconde AS FLOAT CHECK (VALUE >= 0);
END $$;


DO $$ BEGIN PERFORM 123::domaine.duree_jour; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.duree_jour AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

DO $$ BEGIN PERFORM 123::domaine.duree_mois; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.duree_mois AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

DO $$ BEGIN PERFORM 123::domaine.euro; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.euro AS numeric(10,2);
END $$;

DO $$ BEGIN PERFORM 123::domaine.keuro; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.keuro AS numeric(10,3);
END $$;

DO $$ BEGIN PERFORM 123::domaine.kg; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.kg AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.km; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.km AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.km_h; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.km_h AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.mesure; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.mesure AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.metre; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.metre AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.mm; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.mm AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.tava; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.tava AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.tonne; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.tonne AS float;
END $$;

-- domaine_type NOM

DO $$ BEGIN PERFORM 'abc'::domaine.adresse; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.adresse AS character varying(128)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.nom; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.nom AS character varying(128)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.prenom; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.prenom AS character varying(128)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.titre; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.titre AS character varying(128)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

-- domaine_type ORDRE

DO $$ BEGIN PERFORM 123::domaine.classement; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.classement AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

DO $$ BEGIN PERFORM 123::domaine.ordre; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.ordre AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

DO $$ BEGIN PERFORM 123::domaine.rang; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.rang AS integer
CONSTRAINT zero_ou_positif CHECK (VALUE >= 0);
END $$;

-- domaine_type TEXTE 

DO $$ BEGIN PERFORM 'abc'::domaine.commentaire; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.commentaire AS character varying(2048)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.conseil; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.conseil AS character varying(2048)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.description; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.description AS character varying(2048)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.emploi_mode; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.emploi_mode AS character varying(2048)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.exemple; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.exemple AS character varying(2048)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.raison; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.raison AS character varying(2048)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

DO $$ BEGIN PERFORM 'abc'::domaine.texte; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.texte AS character varying(2048)
CONSTRAINT zero_double_espace CHECK (POSITION('  ' IN VALUE) = 0)
CONSTRAINT zero_gauche_espace CHECK (LEFT(VALUE,1) != ' ')
CONSTRAINT zero_droite_espace CHECK (RIGHT(VALUE,1) != ' ');
END $$;

-- domaine_type VALEUR

DO $$ BEGIN PERFORM 123::domaine.taux; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.taux AS float;
END $$;

DO $$ BEGIN PERFORM 123::domaine.valeur; EXCEPTION WHEN undefined_object THEN
CREATE DOMAIN domaine.valeur AS float;
END $$;













