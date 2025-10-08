defmodule Gotham.TimeTrackingTest do
  use Gotham.DataCase

  alias Gotham.TimeTracking

  describe "clocks" do
    alias Gotham.TimeTracking.Clock

    import Gotham.TimeTrackingFixtures

    @invalid_attrs %{status: nil, time: nil, geolocation_data: nil}

    test "list_clocks/0 returns all clocks" do
      clock = clock_fixture()
      assert TimeTracking.list_clocks() == [clock]
    end

    test "get_clock!/1 returns the clock with given id" do
      clock = clock_fixture()
      assert TimeTracking.get_clock!(clock.id) == clock
    end

    test "create_clock/1 with valid data creates a clock" do
      valid_attrs = %{status: true, time: ~U[2025-10-06 08:49:00Z], geolocation_data: %{}}

      assert {:ok, %Clock{} = clock} = TimeTracking.create_clock(valid_attrs)
      assert clock.status == true
      assert clock.time == ~U[2025-10-06 08:49:00Z]
      assert clock.geolocation_data == %{}
    end

    test "create_clock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_clock(@invalid_attrs)
    end

    test "update_clock/2 with valid data updates the clock" do
      clock = clock_fixture()
      update_attrs = %{status: false, time: ~U[2025-10-07 08:49:00Z], geolocation_data: %{}}

      assert {:ok, %Clock{} = clock} = TimeTracking.update_clock(clock, update_attrs)
      assert clock.status == false
      assert clock.time == ~U[2025-10-07 08:49:00Z]
      assert clock.geolocation_data == %{}
    end

    test "update_clock/2 with invalid data returns error changeset" do
      clock = clock_fixture()
      assert {:error, %Ecto.Changeset{}} = TimeTracking.update_clock(clock, @invalid_attrs)
      assert clock == TimeTracking.get_clock!(clock.id)
    end

    test "delete_clock/1 deletes the clock" do
      clock = clock_fixture()
      assert {:ok, %Clock{}} = TimeTracking.delete_clock(clock)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_clock!(clock.id) end
    end

    test "change_clock/1 returns a clock changeset" do
      clock = clock_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_clock(clock)
    end
  end

  describe "working_times" do
    alias Gotham.TimeTracking.WorkingTime

    import Gotham.TimeTrackingFixtures

    @invalid_attrs %{
      start_time: nil,
      end_time: nil,
      is_manual_entry: nil,
      validation_status: nil,
      unpaid_overtime_hours: nil,
      is_transition_time: nil
    }

    test "list_working_times/0 returns all working_times" do
      working_time = working_time_fixture()
      assert TimeTracking.list_working_times() == [working_time]
    end

    test "get_working_time!/1 returns the working_time with given id" do
      working_time = working_time_fixture()
      assert TimeTracking.get_working_time!(working_time.id) == working_time
    end

    test "create_working_time/1 with valid data creates a working_time" do
      valid_attrs = %{
        start_time: ~U[2025-10-06 08:49:00Z],
        end_time: ~U[2025-10-06 08:49:00Z],
        is_manual_entry: true,
        validation_status: "some validation_status",
        unpaid_overtime_hours: "120.5",
        is_transition_time: true
      }

      assert {:ok, %WorkingTime{} = working_time} = TimeTracking.create_working_time(valid_attrs)
      assert working_time.start_time == ~U[2025-10-06 08:49:00Z]
      assert working_time.end_time == ~U[2025-10-06 08:49:00Z]
      assert working_time.is_manual_entry == true
      assert working_time.validation_status == "some validation_status"
      assert working_time.unpaid_overtime_hours == Decimal.new("120.5")
      assert working_time.is_transition_time == true
    end

    test "create_working_time/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_working_time(@invalid_attrs)
    end

    test "update_working_time/2 with valid data updates the working_time" do
      working_time = working_time_fixture()

      update_attrs = %{
        start_time: ~U[2025-10-07 08:49:00Z],
        end_time: ~U[2025-10-07 08:49:00Z],
        is_manual_entry: false,
        validation_status: "some updated validation_status",
        unpaid_overtime_hours: "456.7",
        is_transition_time: false
      }

      assert {:ok, %WorkingTime{} = working_time} =
               TimeTracking.update_working_time(working_time, update_attrs)

      assert working_time.start_time == ~U[2025-10-07 08:49:00Z]
      assert working_time.end_time == ~U[2025-10-07 08:49:00Z]
      assert working_time.is_manual_entry == false
      assert working_time.validation_status == "some updated validation_status"
      assert working_time.unpaid_overtime_hours == Decimal.new("456.7")
      assert working_time.is_transition_time == false
    end

    test "update_working_time/2 with invalid data returns error changeset" do
      working_time = working_time_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TimeTracking.update_working_time(working_time, @invalid_attrs)

      assert working_time == TimeTracking.get_working_time!(working_time.id)
    end

    test "delete_working_time/1 deletes the working_time" do
      working_time = working_time_fixture()
      assert {:ok, %WorkingTime{}} = TimeTracking.delete_working_time(working_time)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_working_time!(working_time.id) end
    end

    test "change_working_time/1 returns a working_time changeset" do
      working_time = working_time_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_working_time(working_time)
    end
  end

  describe "clocks" do
    alias Gotham.TimeTracking.Clock

    import Gotham.TimeTrackingFixtures

    @invalid_attrs %{status: nil, time: nil, geolocation_data: nil}

    test "list_clocks/0 returns all clocks" do
      clock = clock_fixture()
      assert TimeTracking.list_clocks() == [clock]
    end

    test "get_clock!/1 returns the clock with given id" do
      clock = clock_fixture()
      assert TimeTracking.get_clock!(clock.id) == clock
    end

    test "create_clock/1 with valid data creates a clock" do
      valid_attrs = %{status: true, time: ~U[2025-10-06 08:56:00Z], geolocation_data: %{}}

      assert {:ok, %Clock{} = clock} = TimeTracking.create_clock(valid_attrs)
      assert clock.status == true
      assert clock.time == ~U[2025-10-06 08:56:00Z]
      assert clock.geolocation_data == %{}
    end

    test "create_clock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_clock(@invalid_attrs)
    end

    test "update_clock/2 with valid data updates the clock" do
      clock = clock_fixture()
      update_attrs = %{status: false, time: ~U[2025-10-07 08:56:00Z], geolocation_data: %{}}

      assert {:ok, %Clock{} = clock} = TimeTracking.update_clock(clock, update_attrs)
      assert clock.status == false
      assert clock.time == ~U[2025-10-07 08:56:00Z]
      assert clock.geolocation_data == %{}
    end

    test "update_clock/2 with invalid data returns error changeset" do
      clock = clock_fixture()
      assert {:error, %Ecto.Changeset{}} = TimeTracking.update_clock(clock, @invalid_attrs)
      assert clock == TimeTracking.get_clock!(clock.id)
    end

    test "delete_clock/1 deletes the clock" do
      clock = clock_fixture()
      assert {:ok, %Clock{}} = TimeTracking.delete_clock(clock)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_clock!(clock.id) end
    end

    test "change_clock/1 returns a clock changeset" do
      clock = clock_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_clock(clock)
    end
  end

  describe "working_times" do
    alias Gotham.TimeTracking.WorkingTime

    import Gotham.TimeTrackingFixtures

    @invalid_attrs %{
      start_time: nil,
      end_time: nil,
      is_manual_entry: nil,
      validation_status: nil,
      unpaid_overtime_hours: nil,
      is_transition_time: nil
    }

    test "list_working_times/0 returns all working_times" do
      working_time = working_time_fixture()
      assert TimeTracking.list_working_times() == [working_time]
    end

    test "get_working_time!/1 returns the working_time with given id" do
      working_time = working_time_fixture()
      assert TimeTracking.get_working_time!(working_time.id) == working_time
    end

    test "create_working_time/1 with valid data creates a working_time" do
      valid_attrs = %{
        start_time: ~U[2025-10-06 08:56:00Z],
        end_time: ~U[2025-10-06 08:56:00Z],
        is_manual_entry: true,
        validation_status: "some validation_status",
        unpaid_overtime_hours: "120.5",
        is_transition_time: true
      }

      assert {:ok, %WorkingTime{} = working_time} = TimeTracking.create_working_time(valid_attrs)
      assert working_time.start_time == ~U[2025-10-06 08:56:00Z]
      assert working_time.end_time == ~U[2025-10-06 08:56:00Z]
      assert working_time.is_manual_entry == true
      assert working_time.validation_status == "some validation_status"
      assert working_time.unpaid_overtime_hours == Decimal.new("120.5")
      assert working_time.is_transition_time == true
    end

    test "create_working_time/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeTracking.create_working_time(@invalid_attrs)
    end

    test "update_working_time/2 with valid data updates the working_time" do
      working_time = working_time_fixture()

      update_attrs = %{
        start_time: ~U[2025-10-07 08:56:00Z],
        end_time: ~U[2025-10-07 08:56:00Z],
        is_manual_entry: false,
        validation_status: "some updated validation_status",
        unpaid_overtime_hours: "456.7",
        is_transition_time: false
      }

      assert {:ok, %WorkingTime{} = working_time} =
               TimeTracking.update_working_time(working_time, update_attrs)

      assert working_time.start_time == ~U[2025-10-07 08:56:00Z]
      assert working_time.end_time == ~U[2025-10-07 08:56:00Z]
      assert working_time.is_manual_entry == false
      assert working_time.validation_status == "some updated validation_status"
      assert working_time.unpaid_overtime_hours == Decimal.new("456.7")
      assert working_time.is_transition_time == false
    end

    test "update_working_time/2 with invalid data returns error changeset" do
      working_time = working_time_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TimeTracking.update_working_time(working_time, @invalid_attrs)

      assert working_time == TimeTracking.get_working_time!(working_time.id)
    end

    test "delete_working_time/1 deletes the working_time" do
      working_time = working_time_fixture()
      assert {:ok, %WorkingTime{}} = TimeTracking.delete_working_time(working_time)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_working_time!(working_time.id) end
    end

    test "change_working_time/1 returns a working_time changeset" do
      working_time = working_time_fixture()
      assert %Ecto.Changeset{} = TimeTracking.change_working_time(working_time)
    end
  end
end
