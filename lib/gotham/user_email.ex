defmodule Gotham.UserEmail do
  import Swoosh.Email

  def onboard_user(user, raw_password) do
    to_address = user.personal_email || user.email
    from_address = System.get_env("SMTP_FROM") || "no-reply@gotham.com"

    new()
    |> to(to_address)
    |> from(from_address)
    |> subject("Welcome to Gotham - Your Account Details")
    |> html_body("""
      <p>Hi #{user.first_name} #{user.last_name},</p>
      <p>Welcome to Gotham. Your corporate credentials are below:</p>
      <ul>
        <li>Email: <strong>#{user.email}</strong></li>
        <li>Temporary Password: <strong>#{raw_password}</strong></li>
      </ul>
      <p>Please sign in and change your password immediately.</p>
      <p>— IT Team</p>
    """)
    |> text_body("""
      Hi #{user.first_name} #{user.last_name},

      Welcome to Gotham. Your corporate credentials are below:

      Email: #{user.email}
      Temporary Password: #{raw_password}

      Please sign in and change your password immediately.

      — IT Team
    """)
  end
end
