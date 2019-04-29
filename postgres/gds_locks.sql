CREATE OR REPLACE FUNCTION gds_locks()
RETURNS TABLE
(
  pid INT,
  "Time taken by query (in ms)" DECIMAL,
  "User name" NAME,
  "Query" TEXT,
  "Mode" TEXT,
  "Lock type" TEXT,
  "Lock granted?" VARCHAR
)
AS
$func$
BEGIN
  RETURN QUERY
  SELECT
    s.pid,
    ROUND(EXTRACT(EPOCH FROM AGE(NOW(), s.query_start))::DECIMAL*1000, 2),
    s.usename,
    s.query,
    l.mode,
    l.locktype,
    CASE WHEN l.granted THEN 'yes'::VARCHAR ELSE 'no'::VARCHAR END
  -- Please be aware that pg_locks and pg_stat_activity are both views should this query be changed later, as there could be performance implications.
  FROM  pg_stat_activity s,
        pg_locks l
  WHERE s.pid = l.pid
  AND   s.pid != pg_backend_pid()
  ORDER BY  l.granted,
            l.mode DESC,
            l.pid DESC;
END
$func$ LANGUAGE plpgsql
SECURITY DEFINER
;
