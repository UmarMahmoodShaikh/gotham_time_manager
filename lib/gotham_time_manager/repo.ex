defmodule GothamTimeManager.Repo do
  use Ecto.Repo,
    otp_app: :gotham_time_manager,
    adapter: Ecto.Adapters.Postgres
end
