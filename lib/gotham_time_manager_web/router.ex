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
    plug :fetch_session
  end

  pipeline :auth_api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug GothamTimeManagerWeb.Plugs.Auth
  end

  scope "/api", GothamTimeManagerWeb do
    # Public routes which can be accessed without authentication
    pipe_through :api
    post "/login", UserController, :login
#    resources "/users", UserController, only: [:create]
  end

  scope "/api", GothamTimeManagerWeb do
    # Protected routes with authentication
    pipe_through :auth_api
    # Custom find endpoint allowing email/username params
    get "/users/find", UserController, :show
    resources "/users", UserController, except: []
    resources "/tasks", TaskController, except: [] do
      get "/users/:user_id", TaskController, :by_user
    end
  end
end

  
