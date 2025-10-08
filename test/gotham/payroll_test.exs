defmodule Gotham.PayrollTest do
  use Gotham.DataCase

  alias Gotham.Payroll

  describe "compensation_logs" do
    alias Gotham.Payroll.CompensationLog

    import Gotham.PayrollFixtures

    @invalid_attrs %{pay_rate_type: nil, hours_calculated: nil}

    test "list_compensation_logs/0 returns all compensation_logs" do
      compensation_log = compensation_log_fixture()
      assert Payroll.list_compensation_logs() == [compensation_log]
    end

    test "get_compensation_log!/1 returns the compensation_log with given id" do
      compensation_log = compensation_log_fixture()
      assert Payroll.get_compensation_log!(compensation_log.id) == compensation_log
    end

    test "create_compensation_log/1 with valid data creates a compensation_log" do
      valid_attrs = %{pay_rate_type: "some pay_rate_type", hours_calculated: "120.5"}

      assert {:ok, %CompensationLog{} = compensation_log} =
               Payroll.create_compensation_log(valid_attrs)

      assert compensation_log.pay_rate_type == "some pay_rate_type"
      assert compensation_log.hours_calculated == Decimal.new("120.5")
    end

    test "create_compensation_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payroll.create_compensation_log(@invalid_attrs)
    end

    test "update_compensation_log/2 with valid data updates the compensation_log" do
      compensation_log = compensation_log_fixture()
      update_attrs = %{pay_rate_type: "some updated pay_rate_type", hours_calculated: "456.7"}

      assert {:ok, %CompensationLog{} = compensation_log} =
               Payroll.update_compensation_log(compensation_log, update_attrs)

      assert compensation_log.pay_rate_type == "some updated pay_rate_type"
      assert compensation_log.hours_calculated == Decimal.new("456.7")
    end

    test "update_compensation_log/2 with invalid data returns error changeset" do
      compensation_log = compensation_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payroll.update_compensation_log(compensation_log, @invalid_attrs)

      assert compensation_log == Payroll.get_compensation_log!(compensation_log.id)
    end

    test "delete_compensation_log/1 deletes the compensation_log" do
      compensation_log = compensation_log_fixture()
      assert {:ok, %CompensationLog{}} = Payroll.delete_compensation_log(compensation_log)

      assert_raise Ecto.NoResultsError, fn ->
        Payroll.get_compensation_log!(compensation_log.id)
      end
    end

    test "change_compensation_log/1 returns a compensation_log changeset" do
      compensation_log = compensation_log_fixture()
      assert %Ecto.Changeset{} = Payroll.change_compensation_log(compensation_log)
    end
  end
end
