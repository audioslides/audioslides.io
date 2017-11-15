defmodule PlatformWeb.CurrentUserPlugTest do
  use PlatformWeb.ConnCase

  alias PlatformWeb.CurrentUserPlug

  describe "#init" do
    test "passes the options unmodified" do
      opts = %{test: 123}
      assert CurrentUserPlug.init(opts) == opts
    end
  end

  describe "#call" do
    test "assigns user and token", %{conn: _conn} do
      # user = Factory.build(:user)
      # conn = %{conn | assigns: %{current_user: user}}

      # assert CurrentUserPlug.call(conn, []).assigns == ""
    end
  end
end
