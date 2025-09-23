defmodule GothamTimeManagerWeb.Router do
  use GothamTimeManagerWeb, :router
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GothamTimeManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  pipeline :api do
    plug :accepts, ["json"]
  end
  scope "/api", GothamTimeManagerWeb do
    pipe_through :api
    resources "/users", UserController, except: []
    resources "/tasks", TaskController, except: [] do
      get "/users/:user_id", TaskController, :by_user
    end
  end
end
