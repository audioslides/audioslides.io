defmodule Platform.VideoProcessingTest do
  use PlatformWeb.ConnCase
  import Mock
  import Platform.VideoProcessing
  import Mox

  alias Platform.Core.Schema.Slide
  alias Platform.Core
  alias Platform.Speech
  alias Platform.FileHelper
  alias Platform.VideoHelper

  doctest Platform.VideoProcessing

  setup :verify_on_exit!

  setup_with_mocks [
    {Speech, [], [run: fn _ -> <<1, 2, 3>> end]},
    {FileHelper, [], [write_to_file: fn _, _ -> "" end]}
  ] do

    slide_with_old_hash =
      Factory.insert(
        :slide,
        google_object_id: "id.g299abd206d_0_525",
        page_elements_hash: "new",
        image_hash: "old",
        speaker_notes_hash: "new",
        audio_hash: "old"
      )

    slide_up_to_date =
      Factory.insert(
        :slide,
        google_object_id: "id.g299abd206d_0_525",
        page_elements_hash: "same_hash",
        image_hash: "same_hash",
        speaker_notes_hash: "same_hash",
        audio_hash: "same_hash"
      )

    lesson =
      Factory.insert(
        :lesson,
        video_hash: nil,
        google_presentation_id: "1tGbdANGoW8BGI-S-_DcP0XsXhoaTO_KConY7-RVFnkM",
        slides: [
          %Slide{id: 1, name: "TestSlide", position: 1, video_hash: "X"},
          %Slide{id: 2, name: "TestSlide", position: 1, video_hash: "Y"}
        ]
      )



    {:ok, lesson: lesson, slide: slide_with_old_hash, slide_up_to_date: slide_up_to_date}
  end

  describe "#merge_videos" do

    test "should update video_hash after merge", %{lesson: lesson} do
      merge_videos(lesson)

      assert Core.get_lesson!(lesson.id).video_hash != nil
      assert Core.get_lesson!(lesson.id).video_hash == VideoHelper.generate_video_hash(lesson)
    end

  end

  describe "#parse_duration" do
    test "should parse a string to seconds in interger with only seconds" do
      seconds = parse_duration("00:00:34.12")

      assert seconds == 34
    end

    test "should parse a string to seconds in interger with seconds and minutes" do
      seconds = parse_duration("00:01:34.12")

      assert seconds == 94
    end

    test "should parse a string to seconds in interger with seconds, minutes and hours" do
      seconds = parse_duration("01:01:34.12")

      assert seconds == 3694
    end

    test "should also parse if hour part is missing" do
      seconds = parse_duration("01:34.12")

      assert seconds == 94
    end

  end

  describe "the create_or_update_image_for_slide function" do
    test "should call the GoogleSlide.download_slide_thumb! function when image_hash is different", %{
      lesson: lesson,
      slide: slide
    } do
      Platform.SlidesAPIMock
      |> expect(:download_slide_thumb!, fn _x, _y, z -> z end)

      create_or_update_image_for_slide(lesson, slide)

      # assert called SlideAPI.download_slide_thumb!(lesson.google_presentation_id, slide.google_object_id, :_ )
    end

    # test "should not call the GoogleSlide.download_slide_thumb! function when image_hash is the same", %{lesson: lesson, slide_up_to_date: slide} do
    #   create_or_update_image_for_slide(lesson, slide)

    #   assert not called SlideAPI.download_slide_thumb!(lesson.google_presentation_id, slide.google_object_id, :_ )
    # end
    # test "should update the image_hash after downloading the new thumb", %{lesson: lesson, slide: slide} do
    #   create_or_update_image_for_slide(lesson, slide)

    #   assert called SlideAPI.download_slide_thumb!(lesson.google_presentation_id, slide.google_object_id, :_ )
    #   assert Core.get_slide!(slide.id).image_hash != slide.image_hash
    # end
  end

  describe "the create_or_update_audio_for_slide function" do
    test "should call the Speech.run function when audio_hash is different", %{
      lesson: lesson,
      slide: slide
    } do
      create_or_update_audio_for_slide(lesson, slide)

      assert called(
               Speech.run(%{
                 "language_key" => lesson.voice_language,
                 "voice_gender" => lesson.voice_gender,
                 "text" => slide.speaker_notes
               })
             )
    end

    test "should not call the GoogleSlide.download_slide_thumb! function when audio_hash is the same", %{
      lesson: lesson,
      slide_up_to_date: slide
    } do
      create_or_update_audio_for_slide(lesson, slide)

      assert not called(
               Speech.run(%{
                 "language_key" => lesson.voice_language,
                 "voice_gender" => lesson.voice_gender,
                 "text" => slide.speaker_notes
               })
             )
    end

    test "should update the audio_hash after downloading the new thumb", %{
      lesson: lesson,
      slide: slide
    } do
      create_or_update_audio_for_slide(lesson, slide)
      assert Core.get_slide!(slide.id).audio_hash == "new"
    end

    test "should not write the mp3 to the filesystem if already up to date", %{
      lesson: lesson,
      slide_up_to_date: slide
    } do
      create_or_update_audio_for_slide(lesson, slide)

      assert not called(FileHelper.write_to_file(:_, <<1, 2, 3>>))
    end

    test "should write the mp3 to the filesystem", %{lesson: lesson, slide: slide} do
      create_or_update_audio_for_slide(lesson, slide)

      assert called(FileHelper.write_to_file(:_, <<1, 2, 3>>))
    end
  end
end
