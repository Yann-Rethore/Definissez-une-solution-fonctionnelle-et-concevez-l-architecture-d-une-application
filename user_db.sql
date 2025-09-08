-- Script de création des tables addresses et users

BEGIN;

-- Table addresses
CREATE TABLE addresses (
  id        SERIAL PRIMARY KEY,
  street    VARCHAR(255),
  city      VARCHAR(100),
  zip_code  VARCHAR(20),
  country   VARCHAR(100)
);

-- Table users
CREATE TABLE users (
  id                        SERIAL PRIMARY KEY,
  email                     VARCHAR(255) NOT NULL UNIQUE,
  password_hash             VARCHAR(255) NOT NULL,
  first_name                VARCHAR(100),
  last_name                 VARCHAR(100),
  birth_date                DATE,
  email_verified            BOOLEAN    NOT NULL DEFAULT FALSE,
  activation_token          VARCHAR(255),
  activation_token_expiry   TIMESTAMP,
  cgu_accepted              BOOLEAN    NOT NULL DEFAULT FALSE,
  created_at                TIMESTAMP   NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMP   NOT NULL DEFAULT NOW(),
  address_id                INT         NOT NULL,
  CONSTRAINT fk_users_address
    FOREIGN KEY(address_id) REFERENCES addresses(id)
);

COMMIT;
