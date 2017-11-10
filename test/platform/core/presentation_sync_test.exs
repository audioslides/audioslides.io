defmodule Platform.PresentationSyncTest do
  use Platform.DataCase

  # alias Platform.Core.Schema.Presentation
  alias Platform.Core.PresentationSync
  alias Platform.GoogleSlidesFactory
  alias Platform.Factory

  describe "#sync_slides" do
    test "should insert slides if they don't exist" do
      presentation = Factory.insert(:presentation)

      google_slide1 = GoogleSlidesFactory.get_base_slide(object_id: "objID_1", content: "Example Content 1", speaker_notes: "Speaker Notes 1")
      google_slide2 = GoogleSlidesFactory.get_base_slide(object_id: "objID_2", content: "Example Content 2", speaker_notes: "Speaker Notes 2")

      google_presentation = %GoogleApi.Slides.V1.Model.Presentation{
        presentationId: presentation.google_presentation_id,
        slides: [google_slide1, google_slide2]
      }

      PresentationSync.sync_slides(google_presentation)

      presentation =
        presentation
        |> Repo.preload(:slides)

      assert length(presentation.slides) == 2
      assert Enum.map(presentation.slides, fn(slide) -> slide.google_object_id end) == ["objID_1", "objID_2"]
    end

    test "should delete slides" do
      presentation = Factory.insert(:presentation)
      Factory.insert(:slide, presentation: presentation)

      slide1 = GoogleSlidesFactory.get_base_slide(object_id: "objID_1", content: "Example Content 1", speaker_notes: "Speaker Notes 1")

      google_presentation = %GoogleApi.Slides.V1.Model.Presentation{
        presentationId: presentation.google_presentation_id,
        slides: [slide1]
      }

      PresentationSync.sync_slides(google_presentation)

      presentation =
        presentation
        |> Repo.preload(:slides)

      assert length(presentation.slides) == 1
      assert Enum.map(presentation.slides, fn(slide) -> slide.google_object_id end) == ["objID_1"]
    end
  end
end
