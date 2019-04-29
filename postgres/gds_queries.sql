CREATE OR REPLACE FUNCTION gds_queries
(
  -- Only show queries that have run for at least _min_time milliseconds.
  _min_time INT DEFAULT 0
)
RETURNS TABLE
(
  "Time taken by query (in ms)" DECIMAL,
  "Query being run" TEXT
)
AS
$func$
BEGIN
  RETURN QUERY
  SELECT  ROUND(EXTRACT(EPOCH FROM AGE(NOW(), query_start))::DECIMAL*1000, 2), -- Time taken for query, in ms, to 2 decimal places
          query
  FROM    pg_stat_activity
  WHERE   query IS NOT NULL
  AND     query != ''
  AND     (ROUND(EXTRACT(EPOCH FROM AGE(NOW(), query_start))::DECIMAL, 3)*1000)::INT > _min_time
  AND     state != 'idle'
  ORDER BY  1 DESC,
            2
  LIMIT   100;
END
$func$ LANGUAGE plpgsql
SECURITY DEFINER
;
