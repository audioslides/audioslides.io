defmodule PlatformWeb.PresentationController do
  use PlatformWeb, :controller

  alias Platform.Core
  alias Platform.Core.Schema.Presentation

  alias Platform.Video

  def index(conn, _params) do
    presentations = Core.list_presentations()
    render(conn, "index.html", presentations: presentations)
  end

  def new(conn, _params) do
    changeset = Core.change_presentation(%Presentation{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"presentation" => presentation_params}) do
    case Core.create_presentation(presentation_params) do
      {:ok, presentation} ->
        conn
        |> put_flash(:info, "Presentation created successfully.")
        |> redirect(to: presentation_path(conn, :show, presentation))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    presentation = Core.get_presentation_with_slides!(id)
    render(conn, "show.html", presentation: presentation)
  end

  def edit(conn, %{"id" => id}) do
    presentation = Core.get_presentation!(id)
    #Video.convert_presentation(presentation.google_presentation_id)
    changeset = Core.change_presentation(presentation)
    render(conn, "edit.html", presentation: presentation, changeset: changeset)
  end

  def update(conn, %{"id" => id, "presentation" => presentation_params}) do
    presentation = Core.get_presentation!(id)

    case Core.update_presentation(presentation, presentation_params) do
      {:ok, presentation} ->
        conn
        |> put_flash(:info, "Presentation updated successfully.")
        |> redirect(to: presentation_path(conn, :show, presentation))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", presentation: presentation, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    presentation = Core.get_presentation!(id)
    {:ok, _presentation} = Core.delete_presentation(presentation)

    conn
    |> put_flash(:info, "Presentation deleted successfully.")
    |> redirect(to: presentation_path(conn, :index))
  end

  def sync(conn, %{"id" => id}) do
    presentation = Core.get_presentation_with_slides!(id)

    Core.sync_presentation(presentation)

    conn
    |> put_flash(:info, "Presentation synced...")
    |> redirect(to: presentation_path(conn, :show, presentation))
  end

  def generate_video(conn, %{"id" => id}) do
    presentation = Core.get_presentation_with_slides!(id)

    Video.convert_presentation_to_video(presentation)

    conn
    |> put_flash(:info, "Generating Presentation video...")
    |> redirect(to: presentation_path(conn, :show, presentation))
  end

end
