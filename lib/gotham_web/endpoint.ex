defmodule GothamWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :gotham

  # Serve at "/" the static files from "priv/static" (if needed for dashboard/assets)
  plug Plug.Static,
    at: "/",
    from: :gotham,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Enable CORS for API requests (adjust origins for production!)
  plug CORSPlug,
    origin: ["*"],
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]

  # Code reloading (dev only)
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :gotham
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # Parse JSON by default for API
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # Session (optional if you want JWT + cookies)
  plug Plug.Session,
    store: :cookie,
    key: "_gotham_key",
    signing_salt: "random_salt"

  # Router
  plug GothamWeb.Router
end
