defmodule GothamWeb.UnrecognizedWorkJSON do
  alias Gotham.Activities.UnrecognizedWork

  @doc """
  Renders a list of unrecognized_works.
  """
  def index(%{unrecognized_works: unrecognized_works}) do
    %{data: for(unrecognized_work <- unrecognized_works, do: data(unrecognized_work))}
  end

  @doc """
  Renders a single unrecognized_work.
  """
  def show(%{unrecognized_work: unrecognized_work}) do
    %{data: data(unrecognized_work)}
  end

  defp data(%UnrecognizedWork{} = unrecognized_work) do
    %{
      id: unrecognized_work.id,
      description: unrecognized_work.description
    }
  end
end
