defmodule Platform.Core do
  @moduledoc """
  The Core context.
  """
  import Ecto.Query, warn: false

  alias Platform.Repo
  alias Platform.Core.Schema.Presentation
  alias Platform.Core.Schema.Slide
  alias Platform.Core.PresentationSync

  ### ################################################################### ###
  ### Presentation                                                        ###
  ### ################################################################### ###
  def list_presentations do
    Presentation
    |> Repo.all
    |> Repo.preload(slides: Slide |> Ecto.Query.order_by([asc: :position]))
  end

  def get_presentation!(id) do
    Repo.get!(Presentation, id)
  end

  def get_presentation_by_google_presentation_id!(id) do
    Repo.get_by!(Presentation, google_presentation_id: id)
  end

  def get_presentation_with_slides!(id) do
    Presentation
    |> Repo.get!(id)
    |> Repo.preload(slides: Slide |> Ecto.Query.order_by([asc: :position]))
  end

  def create_presentation(attrs \\ %{}) do
    %Presentation{}
    |> Presentation.changeset(attrs)
    |> Repo.insert()
  end

  def update_presentation(%Presentation{} = presentation, attrs) do
    presentation
    |> Presentation.changeset(attrs)
    |> Repo.update()
  end

  def delete_presentation(%Presentation{} = presentation) do
    Repo.delete(presentation)
  end

  def change_presentation(%Presentation{} = presentation) do
    Presentation.changeset(presentation, %{})
  end

  ### ################################################################### ###
  ### Slide                                                               ###
  ### ################################################################### ###
  def get_slide!(%Presentation{} = presentation, id) do
    presentation
    |> Ecto.assoc(:slides)
    |> Repo.get!(id)
  end

  def create_slide(%Presentation{} = presentation, attrs \\ %{}) do
    %Slide{presentation: presentation}
    |> Slide.changeset(attrs)
    |> Repo.insert()
  end

  def update_slide(%Slide{} = slide, attrs) do
    slide
    |> Slide.changeset(attrs)
    |> Repo.update()
  end

  def delete_slide(%Slide{} = slide) do
    Repo.delete(slide)
  end

  def change_slide(%Presentation{} = presentation, %Slide{} = slide) do
    Slide.changeset(slide, %{presentation: presentation})
  end

  def sync_presentation(presentation) do
    PresentationSync.sync_slides(presentation)
  end
end
