/*Downtime Today*/
select server_name, instant, warning from statistics where (up is false)
  and (instant > current_timestamp - interval '1 day');

/*Donwntime in this Month*/
select server_name, instant, warning from statistics where (up is false)
   and (instant > current_timestamp - interval '1 month');

/*Donwntime in three Month*/
select server_name, instant, warning from statistics where (up is false)
  and (instant > current_timestamp - interval '3 month');

/*Donwntime in six Month*/
select server_name, instant, warning from statistics where (up is false)
  and (instant > current_timestamp - interval '6 month');
/*Downtime Count today*/
select server_name , count(*) as "downtime_count_today" from statistics
  where (up is false) and (instant > current_timestamp - interval '1 day') group by server_name;

/*Last 10 downtimes rows */
select server_name, instant, warning from statistics where (up is false)
  and (instant > current_timestamp - interval '1 month') limit 10;

/*Distinct Errors in Current Month*/
select distinct server_name, warning from statistics where (instant > current_timestamp - interval '1 month')
 and (warning is not null) ;

/* Average Response Time from Statistics per day */
select server_name, avg(duration) as response_time_avg from statistics where code between (200) and (300)
 and (instant > current_timestamp - interval '1 day') group by server_name;