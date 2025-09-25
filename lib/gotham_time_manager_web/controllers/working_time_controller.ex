defmodule GothamTimeManagerWeb.WorkingTimeController do
  use GothamTimeManagerWeb, :controller

  alias GothamTimeManager.Repo
  alias GothamTimeManager.WorkingTimes.WorkingTime

  action_fallback GothamTimeManagerWeb.FallbackController

  def index(conn, _params) do
    working_times = Repo.all(WorkingTime)
    json(conn, %{data: Enum.map(working_times, &wt_to_map/1)})
  end

  def create(conn, params) when is_map(params) do
    params = Map.get(params, "working_time", params)
    with {:ok, %WorkingTime{} = wt} <- %WorkingTime{} |> WorkingTime.changeset(params) |> Repo.insert() do
      conn
      |> put_status(:created)
      |> json(%{data: wt_to_map(wt)})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(WorkingTime, id) do
      nil -> conn |> put_status(404) |> json(%{message: "Working time not found"})
      wt -> json(conn, %{data: wt_to_map(wt)})
    end
  end

  def update(conn, %{"id" => id} = all_params) do
    params = all_params |> Map.get("working_time", all_params) |> Map.drop(["id"]) 
    case Repo.get(WorkingTime, id) do
      nil -> conn |> put_status(404) |> json(%{message: "Working time not found"})
      wt ->
        with {:ok, %WorkingTime{} = wt} <- wt |> WorkingTime.changeset(params) |> Repo.update() do
          json(conn, %{data: wt_to_map(wt)})
        else
          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_status(400)
            |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(WorkingTime, id) do
      nil -> conn |> put_status(404) |> json(%{message: "Working time not found"})
      wt ->
        with {:ok, %WorkingTime{}} <- Repo.delete(wt) do
          send_resp(conn, 204, "")
        end
    end
  end

  defp wt_to_map(%WorkingTime{} = wt) do
    %{id: wt.id, start: wt.start, end: wt.end, user_id: wt.user_id}
  end

  # Keep error translation consistent with TaskController
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
