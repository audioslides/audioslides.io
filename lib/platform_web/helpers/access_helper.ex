defmodule PlatformWeb.AccessHelper do
  @moduledoc false

  import PlatformWeb.CanHelper

  alias Platform.Core

  def list_lessons(conn) do
    if can?(conn, :show, User) do
      Core.list_lessons()
    else
      Core.list_visible_lessons()
    end
  end
end
