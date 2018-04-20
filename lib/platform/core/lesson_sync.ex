defmodule Platform.Core.LessonSync do
  @moduledoc """
  Keeps database and online lesson in sync
  """
  alias Platform.Repo
  alias Platform.GoogleSlidesHelper
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide
  alias GoogleApi.Slides.V1.Model.Presentation
  alias Platform.Core
  alias Filename

  require Ecto.Query

  @slide_api Application.get_env(:platform, Platform.SlideAPI, [])[:adapter]

  def sync_slides(%Lesson{google_presentation_id: google_presentation_id}) do
    google_presentation_id
    |> @slide_api.get_presentation
    |> handle_response
  end

  def sync_slides(%Presentation{} = google_presentation) do
    lesson = Core.get_lesson_by_google_presentation_id!(google_presentation.presentationId)
    delete_removed_slides(lesson, google_presentation.slides)
    create_or_update_slides(lesson, google_presentation.slides)
  end

  def handle_response({:ok, %Presentation{} = google_presentation}) do
    sync_slides(google_presentation)
  end

  def handle_response({:error, %{body: json_body}}) do
    error = Poison.decode!(json_body)["error"]

    {:error, %{
      message: error["message"],
      status: error["status"]
    }}
  end

  # def dowload_lesson(%Lesson{} = lesson) do
  #   case GoogleSlides.get_presentation!(lesson.google_presentation_id) do
  #     {:error, _} ->
  #       ""
  #       _ -> ""
  #   end
  # end

  def create_or_update_slides(%Lesson{} = lesson, google_slides) when is_list(google_slides) do
    index_google_slides = Enum.with_index(google_slides)

    Enum.each(index_google_slides, fn {google_slide, index} ->
      google_object_id = google_slide.objectId

      changes = %{
        position: index,
        name: GoogleSlidesHelper.get_title(google_slide),
        speaker_notes: GoogleSlidesHelper.get_speaker_notes(google_slide),
        speaker_notes_hash: GoogleSlidesHelper.generate_hash_for_speakernotes(google_slide),
        page_elements_hash: GoogleSlidesHelper.generate_hash_for_page_elements(google_slide),
        synced_at: DateTime.utc_now()
      }

      slide =
        case Repo.get_by(Slide, lesson_id: lesson.id, google_object_id: google_object_id) do
          nil ->
            %Slide{lesson_id: lesson.id, google_object_id: google_object_id}

          # Post exists, let's use it
          slide ->
            slide
        end

      slide
      |> Slide.changeset(changes)
      |> Repo.insert_or_update!()
    end)
  end

  def delete_removed_slides(%Lesson{} = lesson, google_slides) when is_list(google_slides) do
    slide_ids = Enum.map(google_slides, fn google_slide -> google_slide.objectId end)

    # delete slides that have been deleted online
    slides =
      lesson
      |> Ecto.assoc(:slides)
      |> Ecto.Query.where([c], c.google_object_id not in ^slide_ids)
      |> Repo.all()

    Enum.each(slides, fn slide ->
      Core.delete_slide(lesson, slide)
    end)
  end

  def download_all_thumbs!(%Lesson{} = lesson) do
    Enum.each(lesson.slides, fn slide ->
      download_thumb!(lesson, slide)
      Core.update_slide_image_hash(slide, slide.page_elements_hash)
    end)
  end

  def download_thumb!(%Lesson{} = lesson, %Slide{} = slide) do
    image_filename = Filename.get_filename_for_slide_image(lesson, slide)

    @slide_api.download_slide_thumb!(
      lesson.google_presentation_id,
      slide.google_object_id,
      image_filename
    )
  end
end
