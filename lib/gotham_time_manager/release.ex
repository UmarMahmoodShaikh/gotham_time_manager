defmodule GothamTimeManager.Release do
  @moduledoc """
  Helpers to run tasks in the runtime release (no Mix).

  Used by Heroku release phase to run database migrations:

      bin/gotham_time_manager eval "GothamTimeManager.Release.migrate"
  """

  @app :gotham_time_manager

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
