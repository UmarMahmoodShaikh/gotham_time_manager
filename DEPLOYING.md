# Deploying Gotham Time Manager

This repository is set up to deploy on Heroku using heroku.yml (Container stack) and a multi-stage Dockerfile that builds a production Elixir release.

Recommendation
- If you want a simple PaaS with minimal ops, Heroku is a good choice for this app. Your repo already contains a working heroku.yml, Dockerfile, and release task, and we validated the flow locally.
- If you expect heavy/latency-sensitive workloads or need lower cost at scale, consider alternatives like Fly.io, Gigalixir, Render, or Railway. The Dockerfile will also work with these.

Prerequisites
- Heroku CLI installed and logged in.
- A Heroku app on the container stack: heroku stack:set container.
- Heroku Postgres (or an external Postgres URL).

Required config vars
- SECRET_KEY_BASE: generate with mix phx.gen.secret (store as Heroku config var).
- DATABASE_URL: provided by Heroku Postgres add-on or set manually (ecto://USER:PASS@HOST:5432/DBNAME).
- PHX_HOST: your app hostname (e.g., your-app.herokuapp.com or custom domain).
- PORT: set by Heroku (do not override).
- POOL_SIZE: optional, defaults to 10.
- DB_SSL: optional; defaults to true in prod. Heroku Postgres supports SSL; leave this as true.

Files involved
- heroku.yml: defines how to build and run the container, and the release phase migrations.
- Dockerfile: multi-stage build producing /app/bin/gotham_time_manager.
- Procfile: not required when using heroku.yml with the container stack. This repo omits Procfile to avoid confusion; heroku.yml defines build, run, and release phases.
- config/runtime.exs: reads DATABASE_URL, SECRET_KEY_BASE, PORT, PHX_HOST, DB_SSL.
- scripts/local_heroku_check.sh: optional local verification of the Heroku-like flow.

One-time app setup
1) Create the app on Heroku (or use an existing one) and set the container stack:
   heroku create gtm-be-api
   heroku stack:set container -a gtm-be-api

2) Add Postgres (or use existing):
   heroku addons:create heroku-postgresql:mini -a gtm-be-api

3) Set config vars:
   heroku config:set SECRET_KEY_BASE="$(mix phx.gen.secret)" PHX_HOST=gtm-be-api.herokuapp.com -a gtm-be-api
   # DATABASE_URL will be set by the Postgres add-on automatically

Deploy using heroku.yml
- With the container stack and heroku.yml present, a simple git push triggers Heroku to build the Docker image and run the release phase:
   heroku git:remote -a gtm-be-api
   git push heroku main

What happens during deploy
- Build: Heroku builds your Dockerfile as defined in heroku.yml.
- Release phase: Runs /app/bin/gotham_time_manager eval "GothamTimeManager.Release.migrate" to migrate the DB.
- Run phase: Starts the web process using /app/bin/gotham_time_manager start.

Verify and logs
- View logs: heroku logs --tail -a gtm-be-api
- Open app: heroku open -a gtm-be-api

Health checks
- The app currently returns 404 on "/" by default, which is fine for Heroku’s routing. If you use uptime monitors or load balancers that expect 200 OK on a specific path, add a simple GET /health route that returns 200 JSON.

Local verification (optional)
- You can emulate the Heroku container deployment locally. This builds the release, starts a Postgres container, runs migrations, and boots the app:
   bash scripts/local_heroku_check.sh

Troubleshooting
- Error: "Couldn't find the release image configured for this app. Is there a matching run process?"
  - Ensure the app is on the container stack: heroku stack:set container -a gtm-be-api.
  - Ensure heroku.yml exists at repo root and declares build/run/release.
  - Our heroku.yml uses /app/bin/gotham_time_manager (matches the Dockerfile release output).
  - If you still see the error, prefer using a single-string release.command (not a YAML list) to avoid parser quirks on some Heroku pipelines.

- Database SSL errors locally:
  - runtime.exs defaults DB_SSL=true (production-safe). For local Postgres without SSL, use the provided script which sets DB_SSL=false.

- Migrations didn’t run on deploy:
  - Confirm the release command exists in heroku.yml (release.command).
  - Check logs: heroku logs --tail to see the release phase output.

Rollback
- You can roll back to the previous release:
   heroku releases -a gtm-be-api
   heroku releases:info vNN -a gtm-be-api
   heroku releases:rollback vNN -a gtm-be-api

That’s it. With these settings, deploying to Heroku using the container stack should be smooth and consistent with local verification.

## Additional troubleshooting: Unknown error at "Fetching app code"
- Ensure the app is using the container stack: heroku stack:set container -a <your-app>
- Confirm heroku.yml is at the repository root and valid YAML.
- Prefer a single-quoted string for release.command to avoid YAML parsing issues:
  release:
    command: '/app/bin/gotham_time_manager eval "GothamTimeManager.Release.migrate"'
- Remove extra trailing blank lines at the end of heroku.yml (some pipelines are picky).
- Retry the build: sometimes the message is transient on Heroku's side; rerun git push heroku main.
