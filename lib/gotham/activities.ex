defmodule Gotham.Activities do
  @moduledoc """
  The Activities context.
  """

  import Ecto.Query, warn: false
  alias Gotham.Repo

  alias Gotham.Activities.{Task, Skill, TaskAssignment, TaskSkill, UserSkill, UnrecognizedWork}

  # ------------------------
  # Task Functions
  # ------------------------
  def list_tasks, do: Repo.all(Task)
  def get_task!(id), do: Repo.get!(Task, id)

  def get_task(id) do
    case Repo.get(Task, id) do
      %Task{} = task -> {:ok, task}
      nil -> {:error, :not_found}
    end
  end

  def create_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task), do: Repo.delete(task)

  def change_task(%Task{} = task, attrs \\ %{}), do: Task.changeset(task, attrs)

  # ------------------------
  # Skill Functions
  # ------------------------
  def list_skills, do: Repo.all(Skill)
  def get_skill!(id), do: Repo.get!(Skill, id)

  def get_user_skills(user_id) do
    from(us in UserSkill,
      join: s in Skill,
      on: us.skill_id == s.id,
      where: us.user_id == ^user_id,
      select: s
    )
    |> Repo.all()
  end

  def get_skill(id) do
    case Repo.get(Skill, id) do
      %Skill{} = skill -> {:ok, skill}
      nil -> {:error, :not_found}
    end
  end

  def create_skill(attrs) do
    %Skill{}
    |> Skill.changeset(attrs)
    |> Repo.insert()
  end

  def update_skill(%Skill{} = skill, attrs) do
    skill
    |> Skill.changeset(attrs)
    |> Repo.update()
  end

  def delete_skill(%Skill{} = skill), do: Repo.delete(skill)

  def change_skill(%Skill{} = skill, attrs \\ %{}), do: Skill.changeset(skill, attrs)

  # ------------------------
  # TaskAssignment Functions
  # ------------------------
  def list_task_assignments, do: Repo.all(TaskAssignment)
  def get_task_assignment!(id), do: Repo.get!(TaskAssignment, id)

  def get_task_assignment_by_task_and_user(task_id, user_id) do
    Repo.get_by(TaskAssignment, task_id: task_id, user_id: user_id)
  end

  def create_task_assignment(attrs) do
    %TaskAssignment{}
    |> TaskAssignment.changeset(attrs)
    |> Repo.insert()
  end

  def update_task_assignment(%TaskAssignment{} = task_assignment, attrs) do
    task_assignment
    |> TaskAssignment.changeset(attrs)
    |> Repo.update()
  end

  def delete_task_assignment(%TaskAssignment{} = task_assignment),
    do: Repo.delete(task_assignment)

  def change_task_assignment(%TaskAssignment{} = task_assignment, attrs \\ %{}),
    do: TaskAssignment.changeset(task_assignment, attrs)

  # ------------------------
  # TaskSkill Functions
  # ------------------------
  def list_task_skills, do: Repo.all(TaskSkill)
  def get_task_skill!(id), do: Repo.get!(TaskSkill, id)

  def create_task_skill(attrs) do
    %TaskSkill{}
    |> TaskSkill.changeset(attrs)
    |> Repo.insert()
  end

  def update_task_skill(%TaskSkill{} = task_skill, attrs) do
    task_skill
    |> TaskSkill.changeset(attrs)
    |> Repo.update()
  end

  def delete_task_skill(%TaskSkill{} = task_skill), do: Repo.delete(task_skill)

  def change_task_skill(%TaskSkill{} = task_skill, attrs \\ %{}),
    do: TaskSkill.changeset(task_skill, attrs)

  # ------------------------
  # UserSkill Functions
  # ------------------------
  def list_user_skills, do: Repo.all(UserSkill)
  def get_user_skill!(id), do: Repo.get!(UserSkill, id)

  def create_user_skill(attrs) do
    %UserSkill{}
    |> UserSkill.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_skill(%UserSkill{} = user_skill, attrs) do
    user_skill
    |> UserSkill.changeset(attrs)
    |> Repo.update()
  end

  def delete_user_skill(%UserSkill{} = user_skill), do: Repo.delete(user_skill)

  def change_user_skill(%UserSkill{} = user_skill, attrs \\ %{}),
    do: UserSkill.changeset(user_skill, attrs)

  # ------------------------
  # UnrecognizedWork Functions
  # ------------------------
  def list_unrecognized_works, do: Repo.all(UnrecognizedWork)
  def get_unrecognized_work!(id), do: Repo.get!(UnrecognizedWork, id)

  def create_unrecognized_work(attrs) do
    %UnrecognizedWork{}
    |> UnrecognizedWork.changeset(attrs)
    |> Repo.insert()
  end

  def update_unrecognized_work(%UnrecognizedWork{} = unrecognized_work, attrs) do
    unrecognized_work
    |> UnrecognizedWork.changeset(attrs)
    |> Repo.update()
  end

  def delete_unrecognized_work(%UnrecognizedWork{} = unrecognized_work),
    do: Repo.delete(unrecognized_work)

  def change_unrecognized_work(%UnrecognizedWork{} = unrecognized_work, attrs \\ %{}),
    do: UnrecognizedWork.changeset(unrecognized_work, attrs)
end
