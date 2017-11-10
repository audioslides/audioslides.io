defmodule PlatformWeb.PresentationControllerTest do
  use PlatformWeb.ConnCase

  alias Platform.Core

  @create_attrs %{google_presentation_id: "some google_presentation_id", name: "some name", voice_gender: "male", voice_language: "de-DE"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{google_presentation_id: nil, name: nil, voice_gender: nil, voice_language: nil}

  def fixture(:presentation) do
    {:ok, presentation} = Core.create_presentation(@create_attrs)
    presentation
  end

  describe "index" do
    test "lists all presentations", %{conn: conn} do
      conn = get conn, presentation_path(conn, :index)
      assert html_response(conn, 200) =~ ~s(<main role="main">)
    end
  end

  describe "new presentation" do
    test "renders form", %{conn: conn} do
      conn = get conn, presentation_path(conn, :new)
      assert html_response(conn, 200) =~ "New Presentation"
    end
  end

  describe "create presentation" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, presentation_path(conn, :create), presentation: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == presentation_path(conn, :show, id)

      conn = get conn, presentation_path(conn, :show, id)
      assert html_response(conn, 200) =~ "name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, presentation_path(conn, :create), presentation: @invalid_attrs
      assert html_response(conn, 200) =~ "New Presentation"
    end
  end

  describe "edit presentation" do
    setup [:create_presentation]

    test "renders form for editing chosen presentation", %{conn: conn, presentation: presentation} do
      conn = get conn, presentation_path(conn, :edit, presentation)
      assert html_response(conn, 200) =~ "Edit Presentation"
    end
  end

  describe "update presentation" do
    setup [:create_presentation]

    test "redirects when data is valid", %{conn: conn, presentation: presentation} do
      conn = put conn, presentation_path(conn, :update, presentation), presentation: @update_attrs
      assert redirected_to(conn) == presentation_path(conn, :show, presentation)

      conn = get conn, presentation_path(conn, :show, presentation)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, presentation: presentation} do
      conn = put conn, presentation_path(conn, :update, presentation), presentation: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Presentation"
    end
  end

  describe "delete presentation" do
    setup [:create_presentation]

    test "deletes chosen presentation", %{conn: conn, presentation: presentation} do
      conn = delete conn, presentation_path(conn, :delete, presentation)
      assert redirected_to(conn) == presentation_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, presentation_path(conn, :show, presentation)
      end
    end
  end

  defp create_presentation(_) do
    presentation = fixture(:presentation)
    {:ok, presentation: presentation}
  end
end
