defmodule Gotham.ActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gotham.Activities` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        is_billable: true,
        status: true,
        title: "some title"
      })
      |> Gotham.Activities.create_task()

    task
  end

  @doc """
  Generate a skill.
  """
  def skill_fixture(attrs \\ %{}) do
    {:ok, skill} =
      attrs
      |> Enum.into(%{
        label: "some label"
      })
      |> Gotham.Activities.create_skill()

    skill
  end

  @doc """
  Generate a task_assignment.
  """
  def task_assignment_fixture(attrs \\ %{}) do
    {:ok, task_assignment} =
      attrs
      |> Enum.into(%{})
      |> Gotham.Activities.create_task_assignment()

    task_assignment
  end

  @doc """
  Generate a task_skill.
  """
  def task_skill_fixture(attrs \\ %{}) do
    {:ok, task_skill} =
      attrs
      |> Enum.into(%{})
      |> Gotham.Activities.create_task_skill()

    task_skill
  end

  @doc """
  Generate a user_skill.
  """
  def user_skill_fixture(attrs \\ %{}) do
    {:ok, user_skill} =
      attrs
      |> Enum.into(%{})
      |> Gotham.Activities.create_user_skill()

    user_skill
  end

  @doc """
  Generate a unrecognized_work.
  """
  def unrecognized_work_fixture(attrs \\ %{}) do
    {:ok, unrecognized_work} =
      attrs
      |> Enum.into(%{
        description: "some description"
      })
      |> Gotham.Activities.create_unrecognized_work()

    unrecognized_work
  end
end
