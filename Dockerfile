# Multi-stage Dockerfile for Phoenix + Vue (esbuild + tailwind)
# Build stage
# Use official Elixir image
FROM elixir:1.16-alpine AS build

# Set build-time env
ENV MIX_ENV=prod \
    LANG=C.UTF-8

# Install system dependencies: build tools, node for esbuild/tailwind, and git for deps
RUN apk add --no-cache \
       build-base \
       git \
       nodejs \
       npm

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force \
 && mix local.rebar --force

# Cache elixir deps
COPY mix.exs mix.lock ./
COPY config ./config
RUN mix deps.get --only prod \
 && mix deps.compile

# Copy source
COPY lib ./lib
COPY priv ./priv
COPY assets ./assets

# Build static assets using Mix tasks (install esbuild/tailwind via Mix)
RUN mix assets.setup \
 && mix esbuild gotham_time_manager --minify \
 && mix tailwind gotham_time_manager --minify \
 && mix phx.digest

# Build the release
RUN mix release

# Run stage
FROM alpine:3.19 AS app

ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    HOME=/app \
    PORT=4000

# Install runtime deps for Elixir/Erlang INCLUDING C++ standard library
RUN apk add --no-cache \
       ca-certificates \
       openssl \
       ncurses \
       libstdc++ \
       libgcc \
    && adduser -D -g "" app \
    && mkdir -p /app \
    && chown -R app:app /app

WORKDIR /app

# Copy the release from build stage
COPY --from=build --chown=app:app /app/_build/prod/rel/gotham_time_manager ./

# Copy entrypoint script and make it executable
COPY --chown=app:app entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Switch to non-root user BEFORE setting entrypoint
USER app

EXPOSE 4000

# Set entrypoint
ENTRYPOINT ["./entrypoint.sh"]

# IMPORTANT RUNTIME ENVs (set via docker run or orchestrator):
#   SECRET_KEY_BASE: mix phx.gen.secret (only at runtime)
#   DATABASE_URL: Ecto repo URL, e.g. postgres://user:pass@host:5432/db
#   POOL_SIZE: DB connections (default 10)
#   PHX_HOST: external host name
