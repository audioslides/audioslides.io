defmodule Platform.VideoProcessingStateTest do
  use PlatformWeb.ConnCase

  import Platform.VideoProcessingState

  alias Platform.VideoHelper
  alias Platform.Core

  doctest Platform.VideoProcessingState

  describe "get_processing_state/1" do
    test "should set lesson_id" do
      lesson = Factory.insert(:lesson)

      result = get_processing_state(lesson)
      assert result.lesson_id == lesson.id
    end

    test "should set video_state to NEEDS_UPDATE if no video is genereted by now" do
      lesson = Factory.insert(:lesson, video_hash: nil)

      result = get_processing_state(lesson)
      assert result.video_state == "NEEDS_UPDATE"
    end

    test "should set video_state to NEEDS_UPDATE if some of the sub videos changed" do
      slide1 = Factory.build(:slide, video_hash: "SAME_HASH")
      slide2 = Factory.build(:slide, video_hash: "OTHER_HASH")
      lesson = Factory.build(:lesson, video_hash: VideoHelper.sha256("SAME_HASHSAME_HASH"), slides: [slide1, slide2])

      result = get_processing_state(lesson)
      assert result.video_state == "NEEDS_UPDATE"
    end

    test "should set video_state to UP_TO_DATE if all sub videos still the same" do
      slide1 = Factory.build(:slide, video_hash: "SAME_HASH")
      slide2 = Factory.build(:slide, video_hash: "SAME_HASH")
      lesson = Factory.build(:lesson, video_hash: VideoHelper.sha256("SAME_HASHSAME_HASH"), slides: [slide1, slide2])

      result = get_processing_state(lesson)
      assert result.video_state == "UP_TO_DATE"
    end

    test "should set video_state to UPDATEING if a video_sync_pid is set" do
      slide1 = Factory.build(:slide, video_hash: "SAME_HASH")
      slide2 = Factory.build(:slide, video_hash: "SAME_HASH")
      lesson = Factory.build(:lesson, video_sync_pid: "temp", video_hash: VideoHelper.sha256("SAME_HASHSAME_HASH"), slides: [slide1, slide2])

      result = get_processing_state(lesson)
      assert result.video_state == "UPDATING"
    end

    test "should set video_state to UPDATING if a video_sync_pid is set and some of the sub videos changed" do
      slide1 = Factory.build(:slide, video_hash: "SAME_HASH")
      slide2 = Factory.build(:slide, video_hash: "OTHER_HASH")
      lesson = Factory.build(:lesson, video_sync_pid: "temp", video_hash: VideoHelper.sha256("SAME_HASHSAME_HASH"), slides: [slide1, slide2])

      result = get_processing_state(lesson)
      assert result.video_state == "UPDATING"
    end

    test "should list slide changes in list slides" do
      slide = Factory.build(:slide)
      lesson = Factory.build(:lesson, slides: [slide])

      result = get_processing_state(lesson)
      assert length(result.slides) == 1
    end
  end

  describe "get_processing_state_for_slide/1" do
    test "should set slide_id" do
      slide = Factory.insert(:slide)

      result = get_processing_state_for_slide(slide)
      assert result.slide_id == slide.id
    end

    Video
    test "should set video_state to NEEDS_UPDATE if no video is genereted by now" do
      slide = Factory.insert(:slide, video_hash: nil)

      result = get_processing_state_for_slide(slide)
      assert result.video_state == "NEEDS_UPDATE"
    end

    test "should set video_state to UP_TO_DATE if speaker_notes_hash is same" do
      slide = Factory.insert(:slide, audio_hash: "SAME_HASH", image_hash: "SAME_HASH", video_hash: VideoHelper.sha256("SAME_HASHSAME_HASH"))

      result = get_processing_state_for_slide(slide)
      assert result.video_state == "UP_TO_DATE"
    end

    test "should set video_state to NEEDS_UPDATE if speaker_notes_hash is different" do
      slide = Factory.insert(:slide, audio_hash: "SOME_HASH", image_hash: "SOME_OTHER_HASH", video_hash: VideoHelper.sha256("SOME_HASHSOME_HASH"))

      result = get_processing_state_for_slide(slide)
      assert result.video_state == "NEEDS_UPDATE"
    end

    test "should set video_state to UPDATING if video_sync_pid is set" do
      slide = Factory.insert(:slide, video_hash: "SOME_HASH", speaker_notes_hash: "SOME_OTHER_HASH", video_sync_pid: "PID")

      result = get_processing_state_for_slide(slide)
      assert result.video_state == "UPDATING"
    end

    test "should set video_state to UPDATING if video_sync_pid is set and video_hash is nil" do
      slide = Factory.insert(:slide, video_hash: nil , speaker_notes_hash: "SOME_OTHER_HASH", video_sync_pid: "PID")

      result = get_processing_state_for_slide(slide)
      assert result.video_state == "UPDATING"
    end

    # AUDIO
    test "should set audio_state to NEEDS_UPDATE if no audio is genereted by now" do
      slide = Factory.insert(:slide, audio_hash: nil)

      result = get_processing_state_for_slide(slide)
      assert result.audio_state == "NEEDS_UPDATE"
    end

    test "should set audio_state to UP_TO_DATE if speaker_notes_hash is same" do
      slide = Factory.insert(:slide, audio_hash: "SAME_HASH", speaker_notes_hash: "SAME_HASH")

      result = get_processing_state_for_slide(slide)
      assert result.audio_state == "UP_TO_DATE"
    end

    test "should set audio_state to NEEDS_UPDATE if speaker_notes_hash is different" do
      slide = Factory.insert(:slide, audio_hash: "SOME_HASH", speaker_notes_hash: "SOME_OTHER_HASH")

      result = get_processing_state_for_slide(slide)
      assert result.audio_state == "NEEDS_UPDATE"
    end

    test "should set audio_state to UPDATING if audio_sync_pid is set" do
      slide = Factory.insert(:slide, audio_hash: "SOME_HASH", speaker_notes_hash: "SOME_OTHER_HASH", audio_sync_pid: "PID")

      result = get_processing_state_for_slide(slide)
      assert result.audio_state == "UPDATING"
    end

    test "should set audio_state to UPDATING if audio_sync_pid is set and audio_hash is nil" do
      slide = Factory.insert(:slide, audio_hash: nil, speaker_notes_hash: "SOME_OTHER_HASH", audio_sync_pid: "PID")

      result = get_processing_state_for_slide(slide)
      assert result.audio_state == "UPDATING"
    end

    # Image
    test "should set image_state to NEEDS_UPDATE if no image is genereted by now" do
      slide = Factory.insert(:slide, image_hash: nil)

      result = get_processing_state_for_slide(slide)
      assert result.image_state == "NEEDS_UPDATE"
    end

    test "should set image_state to UP_TO_DATE if page_elements_hash is same" do
      slide = Factory.insert(:slide, image_hash: "SAME_HASH", page_elements_hash: "SAME_HASH")

      result = get_processing_state_for_slide(slide)
      assert result.image_state == "UP_TO_DATE"
    end

    test "should set image_state to NEEDS_UPDATE if page_elements_hash is different" do
      slide = Factory.insert(:slide, image_hash: "SOME_HASH", page_elements_hash: "SOME_OTHER_HASH")

      result = get_processing_state_for_slide(slide)
      assert result.image_state == "NEEDS_UPDATE"
    end

    test "should set image_state to UPDATING if image_sync_pid is set" do
      slide = Factory.insert(:slide, image_hash: "SOME_HASH", page_elements_hash: "SOME_OTHER_HASH", image_sync_pid: "PID")

      result = get_processing_state_for_slide(slide)
      assert result.image_state == "UPDATING"
    end

    test "should set image_state to UPDATING if image_sync_pid is set and image_hash is nil" do
      slide = Factory.insert(:slide, image_hash: nil, page_elements_hash: "SOME_OTHER_HASH", image_sync_pid: "PID")

      result = get_processing_state_for_slide(slide)
      assert result.image_state == "UPDATING"
    end
  end

  describe "set_processing_state" do
    test "should update all elements from NEEDS_UPDATE to UPDATING(set pid)" do

      slide1 = Factory.insert(:slide, video_hash: nil , speaker_notes_hash: "SOME_OTHER_HASH", video_sync_pid: nil)
      slide2 = Factory.insert(:slide, video_hash: nil , speaker_notes_hash: "SOME_OTHER_HASH", video_sync_pid: nil)
      lesson = Factory.insert(:lesson, video_hash: VideoHelper.sha256("SAME_HASHSAME_HASH"), slides: [slide1, slide2])

      set_processing_state(lesson)

      lesson = Core.get_lesson!(lesson.id)
      processing_state = get_processing_state(lesson)

      assert processing_state.video_state == "UPDATING"
    end

    test "should update left out all elements that are not in NEEDS_UPDATE state" do

      slide1 = Factory.insert(:slide, video_hash: nil , speaker_notes_hash: "SOME_OTHER_HASH")
      slide2 = Factory.insert(:slide, video_hash: VideoHelper.sha256("SAME_HASHSAME_HASH"), audio_hash: "SAME_HASH" , image_hash: "SAME_HASH", speaker_notes_hash: "SAME_HASH", page_elements_hash: "SAME_HASH")
      lesson = Factory.insert(:lesson, video_hash: VideoHelper.sha256("SAME_HASHSAME_HASH"), slides: [slide1, slide2])

      IO.inspect get_processing_state(lesson)
      set_processing_state(lesson)

      updated_slide1 = Core.get_slide!(slide1.id)
      processing_state_for_slide1 = get_processing_state_for_slide(updated_slide1)

      updated_slide2 = Core.get_slide!(slide2.id)
      IO.inspect updated_slide2
      processing_state_for_slide2 = get_processing_state_for_slide(updated_slide2)

      assert processing_state_for_slide1.video_state == "UPDATING"
      assert processing_state_for_slide2.video_state == "UP_TO_DATE"
    end
  end
end
