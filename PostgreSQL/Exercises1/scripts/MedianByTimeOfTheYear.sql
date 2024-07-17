Select round(avg(distance)::numeric, 2), time_of_year
FROM (Select *, 1 as time_of_year
      From Training
      WHERE EXTRACT(month FROM training_date) in (12, 1, 2)

      UNION ALL
      Select *, 2 as time_of_year
      From Training
      WHERE EXTRACT(month FROM training_date) in (3, 4, 5)
      UNION ALL

      Select *, 3 as time_of_year
      From Training
      WHERE EXTRACT(month FROM training_date) in (6, 7, 8)
      UNION ALL

      Select *, 4 as time_of_year
      From Training
      WHERE EXTRACT(month FROM training_date) in (9, 10, 11))

Group by time_of_year;