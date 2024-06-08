defmodule IdentityWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use IdentityWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: IdentityWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: IdentityWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :token_not_found}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: IdentityWeb.ErrorJSON)
    |> render(:"403",
      error: %{
        status: :token_not_found,
        reason: "token not found"
      }
    )
  end

  def call(conn, {:error, :invalid_token}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: IdentityWeb.ErrorJSON)
    |> render(:"401",
      error: %{
        status: :invalid_token,
        reason: "invalid token"
      }
    )
  end

  def call(conn, {:error, :invalid_password}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: IdentityWeb.ErrorJSON)
    |> render(:"401",
      error: %{
        status: :invalid_password,
        reason: "invalid password"
      }
    )
  end

  def call(conn, {:error, :invalid_email}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: IdentityWeb.ErrorJSON)
    |> render(:"401",
      error: %{
        status: :invalid_email,
        reason: "invalid email"
      }
    )
  end
end
