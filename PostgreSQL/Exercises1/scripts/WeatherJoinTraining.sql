Create Table weather(
	id serial primary key,
	datetime TIMESTAMP,
	temp real
)

	
Create Table training(
	id serial primary key,
	distance real,
	start_time time,
	end_time  time,
	data_training TIMESTAMP
)

COPY weather(datetime, temp) from  'D:\projects\scripts\OUTPUT\weather.csv' DELIMITER ',' CSV HEADER;
COPY training(data_training, start_time, end_time, distance) from  'D:\projects\scripts\OUTPUT\training.csv' DELIMITER ',' CSV HEADER;

-- Dell record which has 143 id.


CREATE OR REPLACE FUNCTION get_sum_min((t time, OUT sum_ real) AS $$
BEGIN
    sum_ := EXTRACT(MINUTE FROM t) * 60 + 
            EXTRACT(SECOND FROM t);
END;
$$ LANGUAGE plpgsql;


	
with d as(	
Select 
	*,
	get_sum_min(end_time) as delta_end,
	end_time - start_time as delta
	FROM training
	Where EXTRACT(HOUR FROM end_time) != EXTRACT(HOUR FROM start_time)),
	
weights as(	
Select *,
	delta_end/get_sum_sec(delta::time) as w_end,
	1 -  delta_end/get_sum_sec(delta::time) as w_start
	from d),

first_page as(

Select wg.id, wg.distance, wg.start_time, wg.end_time, wg.data_training,  
(lead(wt.temp) over())*wg.w_end  + wt.temp*wg.w_start as temp
	from weights as wg  Join weather as wt
ON (EXTRACT(HOUR from wg.start_time) = EXTRACT(HOUR from wt.datetime) AND
	EXTRACT(year from wg.data_training) = EXTRACT(year from wt.datetime) AND
	EXTRACT(month from wg.data_training) = EXTRACT(month from wt.datetime) AND
	EXTRACT(day from wg.data_training) = EXTRACT(day from wt.datetime)
	)),
	

dd as(	
Select *
	FROM training
	Where EXTRACT(HOUR FROM end_time) = EXTRACT(HOUR FROM start_time)),

second_page as(
Select wg.id, wg.distance, wg.start_time, wg.end_time, wg.data_training,  
	 wt.temp as temp
	from dd as wg  Join weather as wt
ON (EXTRACT(HOUR from wg.start_time) = EXTRACT(HOUR from wt.datetime) AND
	EXTRACT(year from wg.data_training) = EXTRACT(year from wt.datetime) AND
	EXTRACT(month from wg.data_training) = EXTRACT(month from wt.datetime) AND
	EXTRACT(day from wg.data_training) = EXTRACT(day from wt.datetime)
	))

Select * FROM(
SELECT * FROM first_page
UNION ALL
SELECT * FROM second_page)
ORDER BY data_training, start_time 

--  The last record has a null value because at the 'first_page' step, the sequence of 
-- 	executing operators (starting from FROM then window function) does not allow obtaining a 
-- 	value from the lead() function.
