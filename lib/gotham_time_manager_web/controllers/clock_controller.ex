defmodule GothamTimeManagerWeb.ClockController do
  use GothamTimeManagerWeb, :controller

  alias GothamTimeManager.Repo
  alias GothamTimeManager.Clocks.Clock

  action_fallback GothamTimeManagerWeb.FallbackController

  def index(conn, _params) do
    IO.puts("Fetching all clocks...")
    clocks = Repo.all(Clock)
    json(conn, %{data: Enum.map(clocks, &clock_to_map/1)})
  end

  def create(conn, params) when is_map(params) do
    params = Map.get(params, "clock", params)
    with {:ok, %Clock{} = clock} <- %Clock{} |> Clock.changeset(params) |> Repo.insert() do
      conn
      |> put_status(:created)
      |> json(%{data: clock_to_map(clock)})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Clock, id) do
      nil -> conn |> put_status(404) |> json(%{message: "Clock not found"})
      clock -> json(conn, %{data: clock_to_map(clock)})
    end
  end

  def update(conn, %{"id" => id} = all_params) do
    params = all_params |> Map.get("clock", all_params) |> Map.drop(["id"]) 
    case Repo.get(Clock, id) do
      nil -> conn |> put_status(404) |> json(%{message: "Clock not found"})
      clock ->
        with {:ok, %Clock{} = clock} <- clock |> Clock.changeset(params) |> Repo.update() do
          json(conn, %{data: clock_to_map(clock)})
        else
          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_status(400)
            |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Clock, id) do
      nil -> conn |> put_status(404) |> json(%{message: "Clock not found"})
      clock ->
        with {:ok, %Clock{}} <- Repo.delete(clock) do
          send_resp(conn, 204, "")
        end
    end
  end

  defp clock_to_map(%Clock{} = c) do
    %{id: c.id, time: c.time, status: c.status, user_id: c.user_id}
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, val}, acc ->
      String.replace(acc, "%{#{key}}", safe_to_string(val))
    end)
  end

  defp safe_to_string(val) when is_binary(val), do: val
  defp safe_to_string(val) when is_integer(val) or is_float(val), do: to_string(val)
  defp safe_to_string(val) when is_atom(val), do: Atom.to_string(val)
  defp safe_to_string(val) when is_list(val), do: val |> Enum.map(&safe_to_string/1) |> Enum.join(", ")
  defp safe_to_string(val), do: inspect(val)
end
