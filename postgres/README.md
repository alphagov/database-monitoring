# Postgres monitoring queries

## Overview

This is a set of Postgres functions that can be run to diagnose performance problems in Postgres databases. They capture information which can tell you which queries are impacting databse performance, and how those queries are being run (what their query plans are). They should _only_ be used when a problem is definitely occurring since, as with any query, their use will load the database server.

## How to use

Just run any of the following commands from a [`psql`](https://www.postgresql.org/docs/9.6/app-psql.html) session.

```
-- To show currently-running queries
SELECT * FROM gds_queries();

-- To show queries that are currently being blocked by other queries.
SELECT * FROM gds_blocking_queries();

-- To show current locks that have been taken out by running queries/database management processes.
SELECT * FROM gds_locks();
```

## How to install

These stored functions can easily be loaded in a `psql` session when you're logged in as a Postgres user with administrator privileges. Since these functions have been installed using a `SECURITY DEFINER`, they can be run by any user. If you need to restrict their use then you can [`REVOKE`](https://www.postgresql.org/docs/9.1/sql-revoke.html) privileges as necessary to restrict who can run them.
