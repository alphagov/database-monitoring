-- This stored function includes a modified version of the query in https://wiki.postgresql.org/wiki/Lock_Monitoring.
CREATE OR REPLACE FUNCTION gds_blocking_queries()
RETURNS TABLE
(
  "Blocked pid" INT,
  "Blocked user" NAME,
  "Blocked query" TEXT,
  "Time blocked for" INTERVAL,
  "Blocking pid" INT,
  "Blocking user" NAME,
  "Blocking query" TEXT
)
AS
$func$
BEGIN
  RETURN QUERY
  SELECT blocked_locks.pid         AS "Blocked pid",
         blocked_activity.usename  AS "Blocked user",
         blocked_activity.query    AS "Blocked query",
         (NOW() - blocked_activity.query_start) AS "Time blocked for",
         blocking_locks.pid        AS "Blocking pid",
         blocking_activity.usename AS "Blocking user",
         blocking_activity.query   AS "Blocking query"
  FROM pg_catalog.pg_locks AS blocked_locks
  JOIN pg_catalog.pg_stat_activity AS blocked_activity
    ON blocked_activity.pid = blocked_locks.pid
  JOIN pg_catalog.pg_locks AS blocking_locks
    ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
  JOIN pg_catalog.pg_stat_activity AS blocking_activity
    ON blocking_activity.pid = blocking_locks.pid
  WHERE NOT blocked_locks.granted
  ORDER BY (now() - blocked_activity.query_start);
END
$func$ LANGUAGE plpgsql
SECURITY DEFINER
;
