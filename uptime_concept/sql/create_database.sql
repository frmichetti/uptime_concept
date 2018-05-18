drop table if exists statistics;

create table statistics(
  id serial not null
    constraint statistics_pkey
    primary key,
  server_name varchar(255) not null,
  instant timestamp default now() not null,
  up boolean default false not null,
  warning text,
  duration double precision
    constraint duration_check
    check (duration > (0)::double precision),
  code integer
);

create unique index statistics_id_uindex
  on statistics (id);

