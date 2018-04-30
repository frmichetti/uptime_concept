CREATE TABLE statistics
(
  id SERIAL PRIMARY KEY NOT NULL,
  server_name VARCHAR(255) NOT NULL,
  uptime_count BIGSERIAL NOT NULL,
  downtime_count BIGSERIAL NOT NULL
);
CREATE UNIQUE INDEX statistics_server_name_uindex ON statistics (server_name);
CREATE UNIQUE INDEX statistics_id_uindex ON statistics (id);