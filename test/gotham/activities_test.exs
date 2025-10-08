defmodule Gotham.ActivitiesTest do
  use Gotham.DataCase

  alias Gotham.Activities

  describe "tasks" do
    alias Gotham.Activities.Task

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, is_billable: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Activities.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Activities.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{
        status: true,
        description: "some description",
        title: "some title",
        is_billable: true
      }

      assert {:ok, %Task{} = task} = Activities.create_task(valid_attrs)
      assert task.status == true
      assert task.description == "some description"
      assert task.title == "some title"
      assert task.is_billable == true
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()

      update_attrs = %{
        status: false,
        description: "some updated description",
        title: "some updated title",
        is_billable: false
      }

      assert {:ok, %Task{} = task} = Activities.update_task(task, update_attrs)
      assert task.status == false
      assert task.description == "some updated description"
      assert task.title == "some updated title"
      assert task.is_billable == false
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_task(task, @invalid_attrs)
      assert task == Activities.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Activities.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Activities.change_task(task)
    end
  end

  describe "skills" do
    alias Gotham.Activities.Skill

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{label: nil}

    test "list_skills/0 returns all skills" do
      skill = skill_fixture()
      assert Activities.list_skills() == [skill]
    end

    test "get_skill!/1 returns the skill with given id" do
      skill = skill_fixture()
      assert Activities.get_skill!(skill.id) == skill
    end

    test "create_skill/1 with valid data creates a skill" do
      valid_attrs = %{label: "some label"}

      assert {:ok, %Skill{} = skill} = Activities.create_skill(valid_attrs)
      assert skill.label == "some label"
    end

    test "create_skill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_skill(@invalid_attrs)
    end

    test "update_skill/2 with valid data updates the skill" do
      skill = skill_fixture()
      update_attrs = %{label: "some updated label"}

      assert {:ok, %Skill{} = skill} = Activities.update_skill(skill, update_attrs)
      assert skill.label == "some updated label"
    end

    test "update_skill/2 with invalid data returns error changeset" do
      skill = skill_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_skill(skill, @invalid_attrs)
      assert skill == Activities.get_skill!(skill.id)
    end

    test "delete_skill/1 deletes the skill" do
      skill = skill_fixture()
      assert {:ok, %Skill{}} = Activities.delete_skill(skill)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_skill!(skill.id) end
    end

    test "change_skill/1 returns a skill changeset" do
      skill = skill_fixture()
      assert %Ecto.Changeset{} = Activities.change_skill(skill)
    end
  end

  describe "task_assignments" do
    alias Gotham.Activities.TaskAssignment

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{}

    test "list_task_assignments/0 returns all task_assignments" do
      task_assignment = task_assignment_fixture()
      assert Activities.list_task_assignments() == [task_assignment]
    end

    test "get_task_assignment!/1 returns the task_assignment with given id" do
      task_assignment = task_assignment_fixture()
      assert Activities.get_task_assignment!(task_assignment.id) == task_assignment
    end

    test "create_task_assignment/1 with valid data creates a task_assignment" do
      valid_attrs = %{}

      assert {:ok, %TaskAssignment{} = task_assignment} =
               Activities.create_task_assignment(valid_attrs)
    end

    test "create_task_assignment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_task_assignment(@invalid_attrs)
    end

    test "update_task_assignment/2 with valid data updates the task_assignment" do
      task_assignment = task_assignment_fixture()
      update_attrs = %{}

      assert {:ok, %TaskAssignment{} = task_assignment} =
               Activities.update_task_assignment(task_assignment, update_attrs)
    end

    test "update_task_assignment/2 with invalid data returns error changeset" do
      task_assignment = task_assignment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activities.update_task_assignment(task_assignment, @invalid_attrs)

      assert task_assignment == Activities.get_task_assignment!(task_assignment.id)
    end

    test "delete_task_assignment/1 deletes the task_assignment" do
      task_assignment = task_assignment_fixture()
      assert {:ok, %TaskAssignment{}} = Activities.delete_task_assignment(task_assignment)

      assert_raise Ecto.NoResultsError, fn ->
        Activities.get_task_assignment!(task_assignment.id)
      end
    end

    test "change_task_assignment/1 returns a task_assignment changeset" do
      task_assignment = task_assignment_fixture()
      assert %Ecto.Changeset{} = Activities.change_task_assignment(task_assignment)
    end
  end

  describe "task_skills" do
    alias Gotham.Activities.TaskSkill

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{}

    test "list_task_skills/0 returns all task_skills" do
      task_skill = task_skill_fixture()
      assert Activities.list_task_skills() == [task_skill]
    end

    test "get_task_skill!/1 returns the task_skill with given id" do
      task_skill = task_skill_fixture()
      assert Activities.get_task_skill!(task_skill.id) == task_skill
    end

    test "create_task_skill/1 with valid data creates a task_skill" do
      valid_attrs = %{}

      assert {:ok, %TaskSkill{} = task_skill} = Activities.create_task_skill(valid_attrs)
    end

    test "create_task_skill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_task_skill(@invalid_attrs)
    end

    test "update_task_skill/2 with valid data updates the task_skill" do
      task_skill = task_skill_fixture()
      update_attrs = %{}

      assert {:ok, %TaskSkill{} = task_skill} =
               Activities.update_task_skill(task_skill, update_attrs)
    end

    test "update_task_skill/2 with invalid data returns error changeset" do
      task_skill = task_skill_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activities.update_task_skill(task_skill, @invalid_attrs)

      assert task_skill == Activities.get_task_skill!(task_skill.id)
    end

    test "delete_task_skill/1 deletes the task_skill" do
      task_skill = task_skill_fixture()
      assert {:ok, %TaskSkill{}} = Activities.delete_task_skill(task_skill)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_task_skill!(task_skill.id) end
    end

    test "change_task_skill/1 returns a task_skill changeset" do
      task_skill = task_skill_fixture()
      assert %Ecto.Changeset{} = Activities.change_task_skill(task_skill)
    end
  end

  describe "user_skills" do
    alias Gotham.Activities.UserSkill

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{}

    test "list_user_skills/0 returns all user_skills" do
      user_skill = user_skill_fixture()
      assert Activities.list_user_skills() == [user_skill]
    end

    test "get_user_skill!/1 returns the user_skill with given id" do
      user_skill = user_skill_fixture()
      assert Activities.get_user_skill!(user_skill.id) == user_skill
    end

    test "create_user_skill/1 with valid data creates a user_skill" do
      valid_attrs = %{}

      assert {:ok, %UserSkill{} = user_skill} = Activities.create_user_skill(valid_attrs)
    end

    test "create_user_skill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_user_skill(@invalid_attrs)
    end

    test "update_user_skill/2 with valid data updates the user_skill" do
      user_skill = user_skill_fixture()
      update_attrs = %{}

      assert {:ok, %UserSkill{} = user_skill} =
               Activities.update_user_skill(user_skill, update_attrs)
    end

    test "update_user_skill/2 with invalid data returns error changeset" do
      user_skill = user_skill_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activities.update_user_skill(user_skill, @invalid_attrs)

      assert user_skill == Activities.get_user_skill!(user_skill.id)
    end

    test "delete_user_skill/1 deletes the user_skill" do
      user_skill = user_skill_fixture()
      assert {:ok, %UserSkill{}} = Activities.delete_user_skill(user_skill)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_user_skill!(user_skill.id) end
    end

    test "change_user_skill/1 returns a user_skill changeset" do
      user_skill = user_skill_fixture()
      assert %Ecto.Changeset{} = Activities.change_user_skill(user_skill)
    end
  end

  describe "unrecognized_works" do
    alias Gotham.Activities.UnrecognizedWork

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{description: nil}

    test "list_unrecognized_works/0 returns all unrecognized_works" do
      unrecognized_work = unrecognized_work_fixture()
      assert Activities.list_unrecognized_works() == [unrecognized_work]
    end

    test "get_unrecognized_work!/1 returns the unrecognized_work with given id" do
      unrecognized_work = unrecognized_work_fixture()
      assert Activities.get_unrecognized_work!(unrecognized_work.id) == unrecognized_work
    end

    test "create_unrecognized_work/1 with valid data creates a unrecognized_work" do
      valid_attrs = %{description: "some description"}

      assert {:ok, %UnrecognizedWork{} = unrecognized_work} =
               Activities.create_unrecognized_work(valid_attrs)

      assert unrecognized_work.description == "some description"
    end

    test "create_unrecognized_work/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_unrecognized_work(@invalid_attrs)
    end

    test "update_unrecognized_work/2 with valid data updates the unrecognized_work" do
      unrecognized_work = unrecognized_work_fixture()
      update_attrs = %{description: "some updated description"}

      assert {:ok, %UnrecognizedWork{} = unrecognized_work} =
               Activities.update_unrecognized_work(unrecognized_work, update_attrs)

      assert unrecognized_work.description == "some updated description"
    end

    test "update_unrecognized_work/2 with invalid data returns error changeset" do
      unrecognized_work = unrecognized_work_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activities.update_unrecognized_work(unrecognized_work, @invalid_attrs)

      assert unrecognized_work == Activities.get_unrecognized_work!(unrecognized_work.id)
    end

    test "delete_unrecognized_work/1 deletes the unrecognized_work" do
      unrecognized_work = unrecognized_work_fixture()
      assert {:ok, %UnrecognizedWork{}} = Activities.delete_unrecognized_work(unrecognized_work)

      assert_raise Ecto.NoResultsError, fn ->
        Activities.get_unrecognized_work!(unrecognized_work.id)
      end
    end

    test "change_unrecognized_work/1 returns a unrecognized_work changeset" do
      unrecognized_work = unrecognized_work_fixture()
      assert %Ecto.Changeset{} = Activities.change_unrecognized_work(unrecognized_work)
    end
  end

  describe "task_assignments" do
    alias Gotham.Activities.TaskAssignment

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{notes: nil}

    test "list_task_assignments/0 returns all task_assignments" do
      task_assignment = task_assignment_fixture()
      assert Activities.list_task_assignments() == [task_assignment]
    end

    test "get_task_assignment!/1 returns the task_assignment with given id" do
      task_assignment = task_assignment_fixture()
      assert Activities.get_task_assignment!(task_assignment.id) == task_assignment
    end

    test "create_task_assignment/1 with valid data creates a task_assignment" do
      valid_attrs = %{notes: "some notes"}

      assert {:ok, %TaskAssignment{} = task_assignment} =
               Activities.create_task_assignment(valid_attrs)

      assert task_assignment.notes == "some notes"
    end

    test "create_task_assignment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_task_assignment(@invalid_attrs)
    end

    test "update_task_assignment/2 with valid data updates the task_assignment" do
      task_assignment = task_assignment_fixture()
      update_attrs = %{notes: "some updated notes"}

      assert {:ok, %TaskAssignment{} = task_assignment} =
               Activities.update_task_assignment(task_assignment, update_attrs)

      assert task_assignment.notes == "some updated notes"
    end

    test "update_task_assignment/2 with invalid data returns error changeset" do
      task_assignment = task_assignment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activities.update_task_assignment(task_assignment, @invalid_attrs)

      assert task_assignment == Activities.get_task_assignment!(task_assignment.id)
    end

    test "delete_task_assignment/1 deletes the task_assignment" do
      task_assignment = task_assignment_fixture()
      assert {:ok, %TaskAssignment{}} = Activities.delete_task_assignment(task_assignment)

      assert_raise Ecto.NoResultsError, fn ->
        Activities.get_task_assignment!(task_assignment.id)
      end
    end

    test "change_task_assignment/1 returns a task_assignment changeset" do
      task_assignment = task_assignment_fixture()
      assert %Ecto.Changeset{} = Activities.change_task_assignment(task_assignment)
    end
  end

  describe "task_skills" do
    alias Gotham.Activities.TaskSkill

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{note: nil}

    test "list_task_skills/0 returns all task_skills" do
      task_skill = task_skill_fixture()
      assert Activities.list_task_skills() == [task_skill]
    end

    test "get_task_skill!/1 returns the task_skill with given id" do
      task_skill = task_skill_fixture()
      assert Activities.get_task_skill!(task_skill.id) == task_skill
    end

    test "create_task_skill/1 with valid data creates a task_skill" do
      valid_attrs = %{note: "some note"}

      assert {:ok, %TaskSkill{} = task_skill} = Activities.create_task_skill(valid_attrs)
      assert task_skill.note == "some note"
    end

    test "create_task_skill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_task_skill(@invalid_attrs)
    end

    test "update_task_skill/2 with valid data updates the task_skill" do
      task_skill = task_skill_fixture()
      update_attrs = %{note: "some updated note"}

      assert {:ok, %TaskSkill{} = task_skill} =
               Activities.update_task_skill(task_skill, update_attrs)

      assert task_skill.note == "some updated note"
    end

    test "update_task_skill/2 with invalid data returns error changeset" do
      task_skill = task_skill_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activities.update_task_skill(task_skill, @invalid_attrs)

      assert task_skill == Activities.get_task_skill!(task_skill.id)
    end

    test "delete_task_skill/1 deletes the task_skill" do
      task_skill = task_skill_fixture()
      assert {:ok, %TaskSkill{}} = Activities.delete_task_skill(task_skill)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_task_skill!(task_skill.id) end
    end

    test "change_task_skill/1 returns a task_skill changeset" do
      task_skill = task_skill_fixture()
      assert %Ecto.Changeset{} = Activities.change_task_skill(task_skill)
    end
  end

  describe "user_skills" do
    alias Gotham.Activities.UserSkill

    import Gotham.ActivitiesFixtures

    @invalid_attrs %{note: nil}

    test "list_user_skills/0 returns all user_skills" do
      user_skill = user_skill_fixture()
      assert Activities.list_user_skills() == [user_skill]
    end

    test "get_user_skill!/1 returns the user_skill with given id" do
      user_skill = user_skill_fixture()
      assert Activities.get_user_skill!(user_skill.id) == user_skill
    end

    test "create_user_skill/1 with valid data creates a user_skill" do
      valid_attrs = %{note: "some note"}

      assert {:ok, %UserSkill{} = user_skill} = Activities.create_user_skill(valid_attrs)
      assert user_skill.note == "some note"
    end

    test "create_user_skill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_user_skill(@invalid_attrs)
    end

    test "update_user_skill/2 with valid data updates the user_skill" do
      user_skill = user_skill_fixture()
      update_attrs = %{note: "some updated note"}

      assert {:ok, %UserSkill{} = user_skill} =
               Activities.update_user_skill(user_skill, update_attrs)

      assert user_skill.note == "some updated note"
    end

    test "update_user_skill/2 with invalid data returns error changeset" do
      user_skill = user_skill_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Activities.update_user_skill(user_skill, @invalid_attrs)

      assert user_skill == Activities.get_user_skill!(user_skill.id)
    end

    test "delete_user_skill/1 deletes the user_skill" do
      user_skill = user_skill_fixture()
      assert {:ok, %UserSkill{}} = Activities.delete_user_skill(user_skill)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_user_skill!(user_skill.id) end
    end

    test "change_user_skill/1 returns a user_skill changeset" do
      user_skill = user_skill_fixture()
      assert %Ecto.Changeset{} = Activities.change_user_skill(user_skill)
    end
  end
end
