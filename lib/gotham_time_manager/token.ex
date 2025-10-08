defmodule GothamTimeManager.Token do
  @moduledoc """
  JWT utilities using Joken. Provides generation and verification
  of HS256 tokens with standard claims.
  """
  use Joken.Config

  @impl true
  def token_config do
    default_exp = 60 * 60 * 24

    # Define default claims: iat/exp and subject optional
    %{}
    |> add_claim("iat", fn -> DateTime.to_unix(DateTime.utc_now()) end, &is_integer/1)
    |> add_claim("exp", fn -> DateTime.to_unix(DateTime.utc_now()) + default_exp end, &is_integer/1)
  end

  def signer(_opts \\ []) do
    secret = Application.fetch_env!(:gotham_time_manager, :jwt_secret)
    Joken.Signer.create("HS256", secret)
  end

  def generate_for_user(user_id) do
    subject = to_string(user_id)
    extra = %{"sub" => subject}

    case generate_and_sign(extra, signer()) do
      {:ok, token, _claims} -> {:ok, token}
      error -> error
    end
  end

  def verify_token(token) do
    verify_and_validate(token, signer())
  end
end
