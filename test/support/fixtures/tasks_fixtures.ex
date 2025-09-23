defmodule GothamTimeManager.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GothamTimeManager.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        status: 42,
        title: "some title"
      })
      |> GothamTimeManager.Tasks.create_task()

    task
  end
end
