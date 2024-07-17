-- category one:
Select percentile_cont(0.25) WITHIN GROUP (ORDER BY distance) as Q1,
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
