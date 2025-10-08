defmodule Gotham.Token do
  use Joken.Config

  # Define custom claims
  @impl true
  def token_config do
    default_claims(
      # 15 * 60,  # 24 hours
      default_exp: 60 * 60 * 24,
      # Skip these claims for simplicity
      skip: [:aud, :iss, :jti, :nbf]
    )
    |> add_claim("user_id", nil, &is_integer/1)
  end
end
