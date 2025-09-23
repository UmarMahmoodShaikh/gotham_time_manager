defmodule GothamTimeManagerWeb.PageController do
  use GothamTimeManagerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
