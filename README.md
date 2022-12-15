# PostgresNIODeadlockRecreator

A small recreator for a a postgres-nio deadlock seen with the error:
```
[AsyncKit] Connection request timed out. This might indicate a connection deadlock in your application. If you're running long running requests, consider increasing your connection timeout
```

We observed this failure initially under the following conditions:
- This application running on Google Cloud's serverless [Cloud Run](https://cloud.google.com/run/) platform
- Postgres 14.5 with the [TimescaleDB](https://www.timescale.com/) extension (though no queries hit timeseries tables) running on [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/)
- Running a small python script to hit the `/query` endpoint on this server concurrently 50 times every 20 minutes. Failure was observed on the third block of concurrent requests with a few succeeding before the deadlock occured.

Logs leading up to a crash for a single request are as follows:
```log
2022-12-14T23:29:06+0000 info Fluent Reproducer : request-id=619F2B5B-B030-451D-BB2F-C43D0EBB41A3 [Vapor] GET /query
2022-12-14T23:29:06+0000 debug Fluent Reproducer : database-id=psql request-id=619F2B5B-B030-451D-BB2F-C43D0EBB41A3 [FluentKit] query read Site
2022-12-14T23:29:06+0000 debug Fluent Reproducer : database-id=psql request-id=619F2B5B-B030-451D-BB2F-C43D0EBB41A3 [FluentPostgresDriver] SELECT "Site"."ID" AS "Site_ID", "Site"."name" AS "Site_name" FROM "Site" []
2022-12-14T23:29:06+0000 debug Fluent Reproducer : database-id=psql request-id=619F2B5B-B030-451D-BB2F-C43D0EBB41A3 [AsyncKit] Connection pool exhausted on this event loop, adding request to waitlist

... Additional request logs ...

2022-12-14T23:29:16+0000 error Fluent Reproducer : database-id=psql request-id=619F2B5B-B030-451D-BB2F-C43D0EBB41A3 [AsyncKit] Connection request timed out. This might indicate a connection deadlock in your application. If you're running long running requests, consider increasing your connection timeout.
2022-12-14T23:29:16+0000 warning Fluent Reproducer : request-id=619F2B5B-B030-451D-BB2F-C43D0EBB41A3 [] connectionRequestTimeout
```

# To Run
## XCode
Set the `DB_NAME`, `DB_HOST`, `DB_USER`, and optionally `DB_PASSWORD` env vars for your run settings

## Docker
```sh
docker build -t reproducer .
docker run -it --rm -p 8088:8088 --env DB_HOST=localhost --env DB_USER=postgres --env DB_NAME=database reproducer
```

Then send requests to `localhost:8088/query`
