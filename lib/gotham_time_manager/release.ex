defmodule GothamTimeManager.Release do
  @moduledoc """
  Helpers to run tasks in the runtime release (no Mix).

  Used by Heroku release phase to run database migrations:

      bin/gotham_time_manager eval "GothamTimeManager.Release.migrate"
  """

  @app :gotham_time_manager

  def migrate do
    IO.puts("[release] Loading application #{@app} and running migrations...")
    Application.load(@app)

    repos()
    |> Enum.each(fn repo ->
      IO.puts("[release] Migrating repo #{inspect(repo)}")
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end)

    IO.puts("[release] Migrations complete")
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end
end
