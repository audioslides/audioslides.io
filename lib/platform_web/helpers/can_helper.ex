defmodule PlatformWeb.CanHelper do
  @moduledoc false

  def can?(conn, action, model) when is_atom(model) do
    Platform.Permission.can?(conn.assigns.current_user, action, %{__struct__: model})
  end

  def can?(conn, action, model) do
    Platform.Permission.can?(conn.assigns.current_user, action, model)
  end

  def authorize_action!(model, conn) do
    action =
      case conn.private.phoenix_action do
        :create -> :new
        :update -> :edit
        _ -> conn.private.phoenix_action
      end

    authorize!(model, conn, action)
  end

  def authorize!(model, conn, action) do
    if can?(conn, action, model) do
      model
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You can't access that page!")
      |> Phoenix.Controller.redirect(to: "/")
      |> Plug.Conn.halt()
    end
  end
end
