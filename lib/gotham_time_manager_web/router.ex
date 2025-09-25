defmodule GothamTimeManagerWeb.Router do
  use GothamTimeManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GothamTimeManagerWeb do
    pipe_through :api
    resources "/users", UserController, except: []
    resources "/tasks", TaskController, except: [] do
      get "/users/:user_id", TaskController, :by_user
    end
    resources "/clocks", ClockController, except: []
    resources "/workingtimes", WorkingTimeController, except: []
  end
end
