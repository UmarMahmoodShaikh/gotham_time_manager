defmodule GothamWeb.ClockJSON do
  alias Gotham.TimeTracking.Clock

  @doc """
  Renders a list of clocks.
  """
  def index(%{clocks: clocks}) do
    %{data: for(clock <- clocks, do: data(clock))}
  end

  @doc """
  Renders a single clock.
  """
  def show(%{clock: clock}) do
    %{data: data(clock)}
  end

  defp data(%Clock{} = clock) do
    %{
      user_id: clock.user_id,
      time: clock.time,
      status: clock.status,
      geolocation_data: clock.geolocation_data
    }
  end
end
