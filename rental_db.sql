-- Création de la base 
CREATE DATABASE rental_db
  WITH ENCODING = 'UTF8'
       LC_COLLATE = 'fr_FR.UTF-8'
       LC_CTYPE  = 'fr_FR.UTF-8'
       TEMPLATE   = template0;

\c rental_db

BEGIN;

-- Table agencies
CREATE TABLE agencies (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(150) NOT NULL,
  address_id  INT NOT NULL
  -- , FOREIGN KEY (address_id) REFERENCES addresses(id)  -- à décommenter si vous avez une table addresses
);

-- Table categories
CREATE TABLE categories (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  description TEXT
);

-- Table offers
CREATE TABLE offers (
  id                     SERIAL PRIMARY KEY,
  departure_datetime     TIMESTAMP NOT NULL,
  return_datetime        TIMESTAMP NOT NULL,
  daily_rate             NUMERIC(10,2) NOT NULL,
  created_at             TIMESTAMP NOT NULL DEFAULT NOW(),
  departure_agency_id    INT NOT NULL,
  return_agency_id       INT NOT NULL,
  category_id            INT NOT NULL,
  CONSTRAINT fk_offer_departure_agency
    FOREIGN KEY (departure_agency_id) REFERENCES agencies(id),
  CONSTRAINT fk_offer_return_agency
    FOREIGN KEY (return_agency_id) REFERENCES agencies(id),
  CONSTRAINT fk_offer_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Table reservations
CREATE TABLE reservations (
  id               SERIAL PRIMARY KEY,
  reservation_date DATE NOT NULL,
  start_datetime   TIMESTAMP NOT NULL,
  end_datetime     TIMESTAMP NOT NULL,
  status           VARCHAR(50) NOT NULL,
  user_id          INT NOT NULL,
  offer_id         INT NOT NULL,
  CONSTRAINT fk_reservation_offer
    FOREIGN KEY (offer_id) REFERENCES offers(id)
  -- , CONSTRAINT fk_reservation_user FOREIGN KEY (user_id) REFERENCES users(id)
);

COMMIT;
