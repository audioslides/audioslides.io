defmodule Platform.LessonSyncTest do
  use Platform.DataCase

  # alias Platform.Core.Schema.Lesson
  alias Platform.Core.LessonSync
  alias Platform.GoogleSlidesFactory
  alias Platform.Factory

  describe "#sync_slides" do
    test "should insert slides if they don't exist" do
      lesson = Factory.insert(:lesson)

      google_slide1 = GoogleSlidesFactory.get_base_slide(object_id: "objID_1", content: "Example Content 1", speaker_notes: "Speaker Notes 1")
      google_slide2 = GoogleSlidesFactory.get_base_slide(object_id: "objID_2", content: "Example Content 2", speaker_notes: "Speaker Notes 2")

      google_lesson = %GoogleApi.Slides.V1.Model.Presentation{
        presentationId: lesson.google_presentation_id,
        slides: [google_slide1, google_slide2]
      }

      LessonSync.sync_slides(google_lesson)

      lesson =
        lesson
        |> Repo.preload(:slides)

      assert length(lesson.slides) == 2
      assert Enum.map(lesson.slides, fn(slide) -> slide.google_object_id end) == ["objID_1", "objID_2"]
    end

    test "should delete slides" do
      lesson = Factory.insert(:lesson)
      Factory.insert(:slide, lesson: lesson)

      slide1 = GoogleSlidesFactory.get_base_slide(object_id: "objID_1", content: "Example Content 1", speaker_notes: "Speaker Notes 1")

      google_lesson = %GoogleApi.Slides.V1.Model.Presentation{
        presentationId: lesson.google_presentation_id,
        slides: [slide1]
      }

      LessonSync.sync_slides(google_lesson)

      lesson =
        lesson
        |> Repo.preload(:slides)

      assert length(lesson.slides) == 1
      assert Enum.map(lesson.slides, fn(slide) -> slide.google_object_id end) == ["objID_1"]
    end
  end
end
