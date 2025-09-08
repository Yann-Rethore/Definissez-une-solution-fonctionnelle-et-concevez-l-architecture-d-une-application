-- Création des types ENUM pour les statuts et expéditeurs
CREATE TYPE support_request_status AS ENUM('open', 'in_progress', 'close');
CREATE TYPE chat_sender_type    AS ENUM('user', 'support');

BEGIN;

-- Table des agents support
CREATE TABLE support_infos (
  id       SERIAL PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  name     VARCHAR(200) NOT NULL
);

-- Table des conversations client ↔ support
CREATE TABLE conversation (
  id         BIGSERIAL PRIMARY KEY,
  user_id    INT           NOT NULL REFERENCES users(id),
  support_id INT           NOT NULL REFERENCES support_infos(id),
  name       VARCHAR(50)
);

-- Table des demandes de support par email
CREATE TABLE support_requests (
  id             SERIAL                PRIMARY KEY,
  user_id        INT                   NOT NULL REFERENCES users(id),
  subject        VARCHAR(100)          NOT NULL,
  content        VARCHAR(2500)         NOT NULL,
  mail_sent_at   TIMESTAMP,
  status         support_request_status NOT NULL DEFAULT 'open',
  attachment_id  INT                   REFERENCES interaction_attachments(id)
);

-- Table des demandes de visioconférence programmées
CREATE TABLE visio_requests (
  id                  SERIAL PRIMARY KEY,
  scheduled_datetime  TIMESTAMP   NOT NULL,
  urgent              BOOLEAN     NOT NULL DEFAULT FALSE,
  status              VARCHAR(50) NOT NULL
);

-- Table des pièces jointes génériques pour interactions
CREATE TABLE interaction_attachments (
  id             SERIAL    PRIMARY KEY,
  interaction_id INT       NOT NULL,
  filename       VARCHAR(255) NOT NULL,
  file_url       VARCHAR(512) NOT NULL,
  content_type   VARCHAR(100) NOT NULL,
  created_at     TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Table de l’historique de chat instantané
CREATE TABLE support_chat_log (
  id              SERIAL            PRIMARY KEY,
  sender          chat_sender_type  NOT NULL,
  sender_id       INT               NOT NULL,
  conversation_id INT               NOT NULL REFERENCES conversation(id),
  content         VARCHAR(2500)     NOT NULL,
  sent_at         TIMESTAMP         NOT NULL DEFAULT NOW(),
  attachment_id   INT               REFERENCES interaction_attachments(id)
);

-- Table des logs de sessions visioconférence
CREATE TABLE visio_log (
  id               SERIAL    PRIMARY KEY,
  user_id          INT       NOT NULL REFERENCES users(id),
  support_id       INT       NOT NULL REFERENCES support_infos(id),
  visio_request_id INT       NOT NULL REFERENCES visio_requests(id),
  started_at       TIMESTAMP,
  ended_at         TIMESTAMP
);

COMMIT;
