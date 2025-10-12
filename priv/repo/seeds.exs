# priv/repo/seeds.exs
alias Gotham.Repo
alias Gotham.Accounts.{User, Role, Permission}
alias Gotham.Activities.{Task, TaskAssignment, TaskSkill, UserSkill, Skill}
alias Gotham.Scheduling.{Shift, Schedule, Leave}
alias Gotham.TimeTracking.{Clock, WorkingTime}

# We'll use Faker for realistic dummy data
Faker.start()

# Helper function to insert many records
insert_many = fn module, count, attrs_fun ->
  Enum.each(1..count, fn _ ->
    %module{}
    |> module.changeset(attrs_fun.())
    |> Repo.insert!()
  end)
end

# --------------------------
# Accounts
# --------------------------
IO.puts("Seeding Roles...")

insert_many.(Role, 100, fn ->
  %{
    name: Faker.Job.title()
  }
end)

IO.puts("Seeding Permissions...")

insert_many(Permission, 100, fn ->
  %{
    action: Faker.Lorem.word(),
    resource: Faker.Lorem.word()
  }
end)

IO.puts("Seeding Users...")
roles = Repo.all(Role)

insert_many(User, 100, fn ->
  %{
    name: Faker.Person.name(),
    email: Faker.Internet.email(),
    role_id: Enum.random(roles).id
  }
end)

# --------------------------
# Activities
# --------------------------
IO.puts("Seeding Skills...")

insert_many(Skill, 100, fn ->
  %{
    name: Faker.Lorem.word()
  }
end)

users = Repo.all(User)
skills = Repo.all(Skill)

tasks =
  Enum.map(1..100, fn i ->
    Repo.insert!(
      %Task{}
      |> Task.changeset(%{title: "Task #{i}", description: Faker.Lorem.sentence()})
    )
  end)

IO.puts("Seeding UserSkills...")

insert_many(UserSkill, 100, fn ->
  %{
    user_id: Enum.random(users).id,
    skill_id: Enum.random(skills).id,
    note: Faker.Lorem.sentence()
  }
end)

IO.puts("Seeding TaskSkills...")

insert_many(TaskSkill, 100, fn ->
  %{
    task_id: Enum.random(tasks).id,
    skill_id: Enum.random(skills).id,
    note: Faker.Lorem.sentence()
  }
end)

IO.puts("Seeding TaskAssignments...")

insert_many(TaskAssignment, 100, fn ->
  %{
    task_id: Enum.random(tasks).id,
    user_id: Enum.random(users).id,
    notes: Faker.Lorem.sentence()
  }
end)

# --------------------------
# Scheduling
# --------------------------
IO.puts("Seeding Shifts...")

insert_many(Shift, 100, fn ->
  %{
    start_time: Faker.DateTime.backward(30),
    end_time: Faker.DateTime.forward(30)
  }
end)

shifts = Repo.all(Shift)

IO.puts("Seeding Schedules...")

insert_many(Schedule, 100, fn ->
  %{
    shift_id: Enum.random(shifts).id,
    user_id: Enum.random(users).id,
    date: Faker.Date.forward(30)
  }
end)

IO.puts("Seeding Leaves...")

insert_many(Leave, 100, fn ->
  %{
    user_id: Enum.random(users).id,
    start_date: Faker.Date.backward(30),
    end_date: Faker.Date.forward(30),
    reason: Faker.Lorem.sentence()
  }
end)

# --------------------------
# TimeTracking
# --------------------------
IO.puts("Seeding Clocks...")

insert_many(Clock, 100, fn ->
  %{
    user_id: Enum.random(users).id,
    clock_in: Faker.DateTime.backward(10),
    clock_out: Faker.DateTime.forward(1)
  }
end)

IO.puts("Seeding WorkingTimes...")

insert_many(WorkingTime, 100, fn ->
  %{
    user_id: Enum.random(users).id,
    date: Faker.Date.backward(30),
    hours: Enum.random(1..12)
  }
end)

IO.puts("Seeding complete! ✅")
