defmodule PlatformWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  @auth_adapter Application.get_env(:platform, Platform.Accounts.UserFromAuth, [])[:adapter]

  use PlatformWeb, :controller
  # handles request action
  plug(Ueberauth)

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case @auth_adapter.find_or_create(auth) do
      {:ok, user} ->
        # |> put_session(:current_user, user)
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:user_id, user.id)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
