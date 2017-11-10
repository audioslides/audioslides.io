defmodule PlatformWeb.CurrentUserPlug do
  @moduledoc false
  import Plug.Conn

  alias Platform.Accounts

  defmodule Helpers do
    @moduledoc """
    Helpers to avoid to use sth. like conn.assign.xyz.
    Should be imported into VIEWS and CONTROLLERS.
    """
    def current_user(conn) do
      conn.assigns[:current_user]
    end
  end

  def init(opts), do: opts

  # Fetch the current user from the session and add it to `conn.assigns`. This
  # will allow you to have access to the current user in your views with
  # `@current_user`.
  def call(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    conn
    |> put_current_user(user)
  end
  def call(%Plug.Conn{} = conn, _) do
    user_id = get_user_id(conn)

    if user = user_id && Accounts.get_user(user_id) do
      conn
      |> put_current_user(user)
    else
      conn
      |> assign(:current_user, nil)
    end
  end

  defp put_current_user(%Plug.Conn{} = conn, %{id: user_id} = user) do
    token = Phoenix.Token.sign(conn, "user socket", user_id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def get_user_id(%Plug.Conn{} = conn) do
    get_session(conn, "user_id")
  end
end
