Select round(avg(distance)::numeric, 2), time_of_year
FROM (Select *, 1 as time_of_year
      From Training
      WHERE EXTRACT(month FROM data_training) in (12, 1, 2)

      UNION ALL
      Select *, 2 as time_of_year
      From Training
      WHERE EXTRACT(month FROM data_training) in (3, 4, 5)
      UNION ALL

      Select *, 3 as time_of_year
      From Training
      WHERE EXTRACT(month FROM data_training) in (6, 7, 8)
      UNION ALL

      Select *, 4 as time_of_year
      From Training
      WHERE EXTRACT(month FROM data_training) in (9, 10, 11))

Group by time_of_year;


-- category one:
Select avg(distance)                                          as mean,
       percentile_cont(0.25) WITHIN GROUP (ORDER BY distance) as Q1,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY distance)  as Q2,
       percentile_cont(0.75) WITHIN GROUP (ORDER BY distance) as Q3
FROM training;

-- category two:
SELECT avg(distance)                 as mean,
       Variance(distance)            as variance,
       Sqrt(VARIANCE(distance))      as standard_deviation,
       max(distance)                 as max,
       min(distance)                 as min,
       max(distance) - min(distance) as range
FROM TRaining;

-- category three:
WITH dd as (SELECT (distance - avg(distance) over ()) ^ 3 as dif, distance FROM training)
SELECT sum(dif) / count(*) * 1 / sqrt(variance(distance)) ^ 3 as skewness
FROM dd;

WITH dd as (SELECT (distance - avg(distance) over ()) ^ 4 as dif, distance FROM training)
SELECT (sum(dif) / count(*) * 1 / sqrt(variance(distance)) ^ 4) - 3 as kurtosis
FROM dd;
