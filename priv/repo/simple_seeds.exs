# Simple seeds for role-based testing
alias Gotham.Repo
alias Gotham.Accounts.{User, Role}
alias Gotham.Accounts

# Create basic roles if they don't exist
employee_role = Repo.get_by(Role, label: "employee") ||
  Repo.insert!(%Role{label: "employee"})

manager_role = Repo.get_by(Role, label: "manager") ||
  Repo.insert!(%Role{label: "manager"})

admin_role = Repo.get_by(Role, label: "admin") ||
  Repo.insert!(%Role{label: "admin"})

IO.puts("Roles created/found:")
IO.puts("- Employee (ID: #{employee_role.id})")
IO.puts("- Manager (ID: #{manager_role.id})")
IO.puts("- Admin (ID: #{admin_role.id})")

# Create test users for each role
test_users = [
  %{
    email: "employee@gotham.com",
    username: "employee_user",
    first_name: "John",
    last_name: "Employee",
    role_id: employee_role.id,
    password: "password123"
  },
  %{
    email: "manager@gotham.com",
    username: "manager_user",
    first_name: "Jane",
    last_name: "Manager",
    role_id: manager_role.id,
    password: "password123"
  },
  %{
    email: "admin@gotham.com",
    username: "admin_user",
    first_name: "Bruce",
    last_name: "Admin",
    role_id: admin_role.id,
    password: "password123"
  }
]

IO.puts("\nCreating test users...")

Enum.each(test_users, fn user_attrs ->
  case Repo.get_by(User, email: user_attrs.email) do
    nil ->
      full_attrs = Map.merge(user_attrs, %{
        personal_email: user_attrs.email,
        is_visually_challenged: false
      })

      case Accounts.create_user(full_attrs) do
        {:ok, user} ->
          IO.puts("✓ Created #{user_attrs.first_name} #{user_attrs.last_name} (#{user_attrs.email}) - Role ID: #{user_attrs.role_id}")
        {:error, changeset} ->
          IO.puts("✗ Failed to create #{user_attrs.email}: #{inspect(changeset.errors)}")
      end
    user ->
      IO.puts("- User #{user_attrs.email} already exists")
  end
end)

IO.puts("\nSeeding completed!")
