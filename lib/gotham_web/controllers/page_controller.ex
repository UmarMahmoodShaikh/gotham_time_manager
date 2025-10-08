defmodule GothamWeb.PageController do
  use GothamWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
