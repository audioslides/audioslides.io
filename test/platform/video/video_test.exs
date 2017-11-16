defmodule Platform.VideoTest do
  use PlatformWeb.ConnCase
  import Mock
  import Platform.Video

  alias Platform.Core.Schema.Slide
  alias Platform.GoogleSlides
  alias Platform.Core
  alias Platform.Speech

  doctest Platform.Video

  describe "the create_or_update_image_for_slide function" do
    test "should call the GoogleSlide.download_slide_thumb! function when image_hash is different" do
      with_mocks [{GoogleSlides, [], [
        download_slide_thumb!: fn _, _, _ -> "" end
      ]}
      ] do
        lesson = Factory.insert(:lesson, google_presentation_id: "1tGbdANGoW8BGI-S-_DcP0XsXhoaTO_KConY7-RVFnkM")
        slide = Factory.insert(:slide, google_object_id: "id.g299abd206d_0_525" , page_elements_hash: "new", image_hash: "old" )

        create_or_update_image_for_slide(lesson, slide)

        assert called GoogleSlides.download_slide_thumb!(lesson.google_presentation_id, slide.google_object_id, :_ )
      end
    end
    test "should not call the GoogleSlide.download_slide_thumb! function when image_hash is the same" do
      with_mocks [{GoogleSlides, [], [
        download_slide_thumb!: fn _, _, _ -> "" end
      ]}
      ] do
        lesson = Factory.insert(:lesson, google_presentation_id: "1tGbdANGoW8BGI-S-_DcP0XsXhoaTO_KConY7-RVFnkM")
        slide = Factory.insert(:slide, google_object_id: "id.g299abd206d_0_525" , page_elements_hash: "same_hash", image_hash: "same_hash" )

        create_or_update_image_for_slide(lesson, slide)

        assert not called GoogleSlides.download_slide_thumb!(lesson.google_presentation_id, slide.google_object_id, :_ )
      end
    end
    test "should update the image_hash after downloading the new thumb" do
      with_mocks [{GoogleSlides, [], [
        download_slide_thumb!: fn _, _, _ -> "" end
      ]}
      ] do
        lesson = Factory.insert(:lesson, google_presentation_id: "1tGbdANGoW8BGI-S-_DcP0XsXhoaTO_KConY7-RVFnkM")
        slide = Factory.insert(:slide, google_object_id: "id.g299abd206d_0_525" , page_elements_hash: "new", image_hash: "old" )

        create_or_update_image_for_slide(lesson, slide)

        assert called GoogleSlides.download_slide_thumb!(lesson.google_presentation_id, slide.google_object_id, :_ )
        assert Core.get_slide!(slide.id).image_hash != slide.image_hash
      end
    end
  end


  describe "the create_or_update_audio_for_slide function" do
    test "should call the Speech.run function when audio_hash is different" do
      with_mocks [
        {Speech, [], [
        run: fn _ -> "" end,
      ]}
      ] do
        lesson = Factory.insert(:lesson, google_presentation_id: "1tGbdANGoW8BGI-S-_DcP0XsXhoaTO_KConY7-RVFnkM", voice_gender: "male", voice_language: "DE_de")
        slide = Factory.insert(:slide, google_object_id: "id.g299abd206d_0_525" , speaker_notes_hash: "new", audio_hash: "old" )

        create_or_update_audio_for_slide(lesson, slide)

        assert called Speech.run(%{
          "language_key" => lesson.voice_language,
          "voice_gender" => lesson.voice_gender,
          "text" => slide.speaker_notes
        })
      end
    end
    test "should not call the GoogleSlide.download_slide_thumb! function when audio_hash is the same" do
      with_mocks [
        {Speech, [], [
        run: fn _ -> "" end
      ]}
      ] do
        lesson = Factory.insert(:lesson, google_presentation_id: "1tGbdANGoW8BGI-S-_DcP0XsXhoaTO_KConY7-RVFnkM", voice_gender: "male", voice_language: "DE_de")
        slide = Factory.insert(:slide, google_object_id: "id.g299abd206d_0_525" , speaker_notes_hash: "same_hash", audio_hash: "same_hash", speaker_notes: "some text" )

        create_or_update_audio_for_slide(lesson, slide)

        assert not called Speech.run(%{
          "language_key" => lesson.voice_language,
          "voice_gender" => lesson.voice_gender,
          "text" => slide.speaker_notes
        })
      end
    end
    test "should update the audio_hash after downloading the new thumb" do
      with_mocks [
        {Speech, [], [
          run: fn _ -> <<12, 13, 14>> end
       ]}
      ] do
        lesson = Factory.insert(:lesson, google_presentation_id: "1tGbdANGoW8BGI-S-_DcP0XsXhoaTO_KConY7-RVFnkM", voice_gender: "male", voice_language: "DE_de")
        slide = Factory.insert(:slide, google_object_id: "id.g299abd206d_0_525" , speaker_notes_hash: "new", audio_hash: "old", speaker_notes: "some text" )

        create_or_update_audio_for_slide(lesson, slide)

        assert called Speech.run(%{
          "language_key" => lesson.voice_language,
          "voice_gender" => lesson.voice_gender,
          "text" => slide.speaker_notes
        })
        assert Core.get_slide!(slide.id).audio_hash == "new"
      end
    end
  end
end
