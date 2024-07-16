# This is a repository for practicing writing SQL queries on PostgreSQL. :keyboard:


## Exercises one: Training join Weather.
  
Table: Weather
<table>
  <tr>
    <td><mark>Column_name</mark></td>
    <td><mark>type</mark></td>
  </tr>
  <tr>
     <td>id</td>
    <td>int</td>
  </tr>
  <td>temp</td>
    <td>real</td>
  <tr>
   <td>datetime</td>
    <td>timestamp</td>
    </tr>
</table>
ID is the primary key (a column with unique values) for this table. 
The table contains the temperature for each hour of each day.

Table: Training
<table>
  <tr>
    <td><mark>Column_name</mark></td>
    <td><mark>type</mark></td>
  </tr>
  <tr>
     <td>id</td>
    <td>int</td>
  </tr>
  <td>distance</td>
    <td>real</td>
  <tr>
   <td>start_time</td>
    <td>time</td>
    </tr>
    <tr>
   <td>end_time</td>
    <td>time</td>
    </tr>
      <tr>
   <td>data_training</td>
    <td>timestamp</td>
    </tr>
</table>
id is the primary key (a column with unique values) for this table.
Each row of this table contains information about the duration, date, start time, and finish time of the train.

Write a solution to report the duration, date, start time, finish time trains and 
<mark>weighted arithmetic mean temperature</mark>. 

<em>Example:</em>
Input:
Table: Weather
<table>
<tr>
<td><mark>id</mark></td>
<td><mark>temp</mark></td>
<td><mark>datetime</mark></td>
</tr>
<tr>
<td>1</td>
<td>18</td>
<td>2023-04-01T18:00:00</td>
</tr>

<tr>
<td>2</td>
<td>17</td>
<td>2023-04-01T19:00:00</td>
</tr>

<tr>
<td>3</td>
<td>18</td>
<td>2023-04-01T20:00:00</td>
</tr>

<tr>
<td>4</td>
<td>16</td>
<td>2023-04-01T21:00:00</td>
</tr>
</table>


Input:
Table: Training
<table>
<tr>

<td><mark>id</mark></td>
<td><mark>distance</mark></td>
<td><mark>start_time</mark></td>
<td><mark>end_time</mark></td>
<td><mark>data_training</mark></td>
</tr>

<tr>
<td>1</td>
<td>5030</td>
<td>19:38:00</td>
<td>20:08:11</td>
<td>2023-04-01</td>
</tr>

<tr>
<td>2</td>
<td>6030</td>
<td>14:20:10</td>
<td>14:53:11</td>
<td>2023-04-02</td>
</tr>
<tr>
<td>4</td>
<td>4010</td>
<td>12:10:10</td>
<td>12:35:11</td>
<td>2023-04-03</td>
</tr>

<tr>
<td>5</td>
<td>10010</td>
<td>17:10:10</td>
<td>18:00:11</td>
<td>2023-04-03</td>
</tr>
</table>

<h2>Solution</h2>

```postgresql
-- calculates the total number of seconds in the time value passed as the parameter t 
-- and returns this value in the variable sum_.

CREATE OR REPLACE FUNCTION get_sum_min((t time, OUT sum_ real) AS $$
BEGIN
    sum_ := EXTRACT(MINUTE FROM t) * 60 + 
            EXTRACT(SECOND FROM t);
END;
$$ LANGUAGE plpgsql;
```

```postgresql
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
```
