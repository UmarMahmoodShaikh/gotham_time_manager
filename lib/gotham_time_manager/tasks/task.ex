defmodule GothamTimeManager.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias GothamTimeManager.Accounts.User

  @status_mapping %{
    -1 => :pending,
    0 => :non_active,
    1 => :active,
    2 => :in_review,
    3 => :completed,
    5 => :archived
  }

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :integer, default: -1

    many_to_many :users, User,
                 join_through: "tasks_users",
                 on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status])
    |> validate_required([:title, :description, :status])
    |> validate_inclusion(
      :status,
      Map.keys(@status_mapping),
      message: "is invalid. Allowed values: #{Enum.join(Enum.map(Map.keys(@status_mapping), &to_string/1), ", ")}"
    )
  end

  def status_name(%__MODULE__{status: status}) do
    Map.get(@status_mapping, status, :unknown)
  end
end
