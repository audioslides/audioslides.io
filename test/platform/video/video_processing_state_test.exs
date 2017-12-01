defmodule Platform.VideoProcessingStateTest do
  use PlatformWeb.ConnCase

  import Platform.VideoProcessingState

  doctest Platform.VideoProcessingState

  describe "get_initial_processing_state/1" do
    test "should set lesson_id" do
      lesson = Factory.insert(:lesson)

      result = get_initial_processing_state(lesson)
      assert result.lesson_id == lesson.id
    end

    test "should set video_state to NEW if no video is genereted by now" do
      lesson = Factory.insert(:lesson, video_hash: nil)

      result = get_initial_processing_state(lesson)
      assert result.video_state == "NEW"
    end
  end


  describe "get_initial_processing_state_for_slide/1" do
    test "should set slide_id" do
      slide = Factory.insert(:slide)

      result = get_initial_processing_state_for_slide(slide)
      assert result.slide_id == slide.id
    end

    Video
    test "should set video_state to NEW if no video is genereted by now" do
      slide = Factory.insert(:slide, video_hash: nil)

      result = get_initial_processing_state_for_slide(slide)
      assert result.video_state == "NEW"
    end

    test "should set video_state to NO_UPDATED_NEEDED if speaker_notes_hash is same" do
      slide = Factory.insert(:slide, audio_hash: "SAME_HASH", image_hash: "SAME_HASH", video_hash: "SAME_HASHSAME_HASH")

      result = get_initial_processing_state_for_slide(slide)
      assert result.video_state == "NO_UPDATED_NEEDED"
    end

    test "should set video_state to NEED_UPDATE if speaker_notes_hash is different" do
      slide = Factory.insert(:slide, audio_hash: "SOME_HASH", image_hash: "SOME_OTHER_HASH", video_hash: "SOME_HASHSOME_HASH")

      result = get_initial_processing_state_for_slide(slide)
      assert result.video_state == "NEED_UPDATE"
    end

    # AUDIO
    test "should set audio_state to NEW if no audio is genereted by now" do
      slide = Factory.insert(:slide, audio_hash: nil)

      result = get_initial_processing_state_for_slide(slide)
      assert result.audio_state == "NEW"
    end

    test "should set audio_state to NO_UPDATED_NEEDED if speaker_notes_hash is same" do
      slide = Factory.insert(:slide, audio_hash: "SAME_HASH", speaker_notes_hash: "SAME_HASH")

      result = get_initial_processing_state_for_slide(slide)
      assert result.audio_state == "NO_UPDATED_NEEDED"
    end

    test "should set audio_state to NEED_UPDATE if speaker_notes_hash is different" do
      slide = Factory.insert(:slide, audio_hash: "SOME_HASH", speaker_notes_hash: "SOME_OTHER_HASH")

      result = get_initial_processing_state_for_slide(slide)
      assert result.audio_state == "NEED_UPDATE"
    end

    # Image
    test "should set image_state to NEW if no image is genereted by now" do
      slide = Factory.insert(:slide, image_hash: nil)

      result = get_initial_processing_state_for_slide(slide)
      assert result.image_state == "NEW"
    end

    test "should set image_state to NO_UPDATED_NEEDED if page_elements_hash is same" do
      slide = Factory.insert(:slide, image_hash: "SAME_HASH", page_elements_hash: "SAME_HASH")

      result = get_initial_processing_state_for_slide(slide)
      assert result.image_state == "NO_UPDATED_NEEDED"
    end

    test "should set image_state to NEED_UPDATE if page_elements_hash is different" do
      slide = Factory.insert(:slide, image_hash: "SOME_HASH", page_elements_hash: "SOME_OTHER_HASH")

      result = get_initial_processing_state_for_slide(slide)
      assert result.image_state == "NEED_UPDATE"
    end
  end
end
