defmodule Gotham.SchedulingTest do
  use Gotham.DataCase

  alias Gotham.Scheduling

  describe "shifts" do
    alias Gotham.Scheduling.Shift

    import Gotham.SchedulingFixtures

    @invalid_attrs %{name: nil, is_night_shift: nil, is_constraint_hour: nil}

    test "list_shifts/0 returns all shifts" do
      shift = shift_fixture()
      assert Scheduling.list_shifts() == [shift]
    end

    test "get_shift!/1 returns the shift with given id" do
      shift = shift_fixture()
      assert Scheduling.get_shift!(shift.id) == shift
    end

    test "create_shift/1 with valid data creates a shift" do
      valid_attrs = %{name: "some name", is_night_shift: true, is_constraint_hour: true}

      assert {:ok, %Shift{} = shift} = Scheduling.create_shift(valid_attrs)
      assert shift.name == "some name"
      assert shift.is_night_shift == true
      assert shift.is_constraint_hour == true
    end

    test "create_shift/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduling.create_shift(@invalid_attrs)
    end

    test "update_shift/2 with valid data updates the shift" do
      shift = shift_fixture()

      update_attrs = %{
        name: "some updated name",
        is_night_shift: false,
        is_constraint_hour: false
      }

      assert {:ok, %Shift{} = shift} = Scheduling.update_shift(shift, update_attrs)
      assert shift.name == "some updated name"
      assert shift.is_night_shift == false
      assert shift.is_constraint_hour == false
    end

    test "update_shift/2 with invalid data returns error changeset" do
      shift = shift_fixture()
      assert {:error, %Ecto.Changeset{}} = Scheduling.update_shift(shift, @invalid_attrs)
      assert shift == Scheduling.get_shift!(shift.id)
    end

    test "delete_shift/1 deletes the shift" do
      shift = shift_fixture()
      assert {:ok, %Shift{}} = Scheduling.delete_shift(shift)
      assert_raise Ecto.NoResultsError, fn -> Scheduling.get_shift!(shift.id) end
    end

    test "change_shift/1 returns a shift changeset" do
      shift = shift_fixture()
      assert %Ecto.Changeset{} = Scheduling.change_shift(shift)
    end
  end

  describe "schedules" do
    alias Gotham.Scheduling.Schedule

    import Gotham.SchedulingFixtures

    @invalid_attrs %{start_date: nil, end_date: nil, consecutive_night_count: nil}

    test "list_schedules/0 returns all schedules" do
      schedule = schedule_fixture()
      assert Scheduling.list_schedules() == [schedule]
    end

    test "get_schedule!/1 returns the schedule with given id" do
      schedule = schedule_fixture()
      assert Scheduling.get_schedule!(schedule.id) == schedule
    end

    test "create_schedule/1 with valid data creates a schedule" do
      valid_attrs = %{
        start_date: ~D[2025-10-06],
        end_date: ~D[2025-10-06],
        consecutive_night_count: 42
      }

      assert {:ok, %Schedule{} = schedule} = Scheduling.create_schedule(valid_attrs)
      assert schedule.start_date == ~D[2025-10-06]
      assert schedule.end_date == ~D[2025-10-06]
      assert schedule.consecutive_night_count == 42
    end

    test "create_schedule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduling.create_schedule(@invalid_attrs)
    end

    test "update_schedule/2 with valid data updates the schedule" do
      schedule = schedule_fixture()

      update_attrs = %{
        start_date: ~D[2025-10-07],
        end_date: ~D[2025-10-07],
        consecutive_night_count: 43
      }

      assert {:ok, %Schedule{} = schedule} = Scheduling.update_schedule(schedule, update_attrs)
      assert schedule.start_date == ~D[2025-10-07]
      assert schedule.end_date == ~D[2025-10-07]
      assert schedule.consecutive_night_count == 43
    end

    test "update_schedule/2 with invalid data returns error changeset" do
      schedule = schedule_fixture()
      assert {:error, %Ecto.Changeset{}} = Scheduling.update_schedule(schedule, @invalid_attrs)
      assert schedule == Scheduling.get_schedule!(schedule.id)
    end

    test "delete_schedule/1 deletes the schedule" do
      schedule = schedule_fixture()
      assert {:ok, %Schedule{}} = Scheduling.delete_schedule(schedule)
      assert_raise Ecto.NoResultsError, fn -> Scheduling.get_schedule!(schedule.id) end
    end

    test "change_schedule/1 returns a schedule changeset" do
      schedule = schedule_fixture()
      assert %Ecto.Changeset{} = Scheduling.change_schedule(schedule)
    end
  end

  describe "leaves" do
    alias Gotham.Scheduling.Leave

    import Gotham.SchedulingFixtures

    @invalid_attrs %{status: nil, leave_type: nil, start_date: nil, end_date: nil}

    test "list_leaves/0 returns all leaves" do
      leave = leave_fixture()
      assert Scheduling.list_leaves() == [leave]
    end

    test "get_leave!/1 returns the leave with given id" do
      leave = leave_fixture()
      assert Scheduling.get_leave!(leave.id) == leave
    end

    test "create_leave/1 with valid data creates a leave" do
      valid_attrs = %{
        status: "some status",
        leave_type: "some leave_type",
        start_date: ~D[2025-10-06],
        end_date: ~D[2025-10-06]
      }

      assert {:ok, %Leave{} = leave} = Scheduling.create_leave(valid_attrs)
      assert leave.status == "some status"
      assert leave.leave_type == "some leave_type"
      assert leave.start_date == ~D[2025-10-06]
      assert leave.end_date == ~D[2025-10-06]
    end

    test "create_leave/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduling.create_leave(@invalid_attrs)
    end

    test "update_leave/2 with valid data updates the leave" do
      leave = leave_fixture()

      update_attrs = %{
        status: "some updated status",
        leave_type: "some updated leave_type",
        start_date: ~D[2025-10-07],
        end_date: ~D[2025-10-07]
      }

      assert {:ok, %Leave{} = leave} = Scheduling.update_leave(leave, update_attrs)
      assert leave.status == "some updated status"
      assert leave.leave_type == "some updated leave_type"
      assert leave.start_date == ~D[2025-10-07]
      assert leave.end_date == ~D[2025-10-07]
    end

    test "update_leave/2 with invalid data returns error changeset" do
      leave = leave_fixture()
      assert {:error, %Ecto.Changeset{}} = Scheduling.update_leave(leave, @invalid_attrs)
      assert leave == Scheduling.get_leave!(leave.id)
    end

    test "delete_leave/1 deletes the leave" do
      leave = leave_fixture()
      assert {:ok, %Leave{}} = Scheduling.delete_leave(leave)
      assert_raise Ecto.NoResultsError, fn -> Scheduling.get_leave!(leave.id) end
    end

    test "change_leave/1 returns a leave changeset" do
      leave = leave_fixture()
      assert %Ecto.Changeset{} = Scheduling.change_leave(leave)
    end
  end
end
