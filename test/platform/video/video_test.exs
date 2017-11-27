defmodule Platform.VideoTest do
  use PlatformWeb.ConnCase
  import Mock
  import Platform.Video
  import Mox

  alias Platform.Core.Schema.Slide
  alias Platform.Core
  alias Platform.Speech
  alias Platform.FileHelper

  doctest Platform.Video

  setup :verify_on_exit!

  setup_with_mocks([
    {Speech, [], [run: fn _ -> <<1, 2, 3>> end]},
    {FileHelper, [], [write_to_file: fn _, _ -> "" end]}
    ])
    do
    lesson = Factory.insert(:lesson, google_presentation_id: "1tGbdANGoW8BGI-S-_DcP0XsXhoaTO_KConY7-RVFnkM")
    slide_with_old_hash = Factory.insert(:slide, google_object_id: "id.g299abd206d_0_525" , page_elements_hash: "new", image_hash: "old", speaker_notes_hash: "new", audio_hash: "old" )
    slide_up_to_date = Factory.insert(:slide, google_object_id: "id.g299abd206d_0_525" , page_elements_hash: "same_hash", image_hash: "same_hash", speaker_notes_hash: "same_hash", audio_hash: "same_hash" )
    {:ok, lesson: lesson, slide: slide_with_old_hash, slide_up_to_date: slide_up_to_date}
  end

  describe "the create_or_update_image_for_slide function" do
    test "should call the GoogleSlide.download_slide_thumb! function when image_hash is different", %{lesson: lesson, slide: slide} do

      Platform.GoogleSlidesAPIMock
      |> expect(:download_slide_thumb!, fn _x, _y, z -> z end)

      create_or_update_image_for_slide(lesson, slide)

      #assert called SlideAPI.download_slide_thumb!(lesson.google_presentation_id, slide.google_object_id, :_ )
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
    test "should call the Speech.run function when audio_hash is different", %{lesson: lesson, slide: slide} do
      create_or_update_audio_for_slide(lesson, slide)

      assert called Speech.run(%{
        "language_key" => lesson.voice_language,
        "voice_gender" => lesson.voice_gender,
        "text" => slide.speaker_notes
      })
    end
    test "should not call the GoogleSlide.download_slide_thumb! function when audio_hash is the same", %{lesson: lesson, slide_up_to_date: slide} do
      create_or_update_audio_for_slide(lesson, slide)

      assert not called Speech.run(%{
        "language_key" => lesson.voice_language,
        "voice_gender" => lesson.voice_gender,
        "text" => slide.speaker_notes
      })
    end
    test "should update the audio_hash after downloading the new thumb", %{lesson: lesson, slide: slide} do
      create_or_update_audio_for_slide(lesson, slide)
      assert Core.get_slide!(slide.id).audio_hash == "new"
    end
    test "should not write the mp3 to the filesystem if already up to date", %{lesson: lesson, slide_up_to_date: slide} do
      create_or_update_audio_for_slide(lesson, slide)

      assert not called FileHelper.write_to_file(:_, <<1, 2, 3>>)
    end
    test "should write the mp3 to the filesystem", %{lesson: lesson, slide: slide} do
      create_or_update_audio_for_slide(lesson, slide)

      assert called FileHelper.write_to_file(:_, <<1, 2, 3>>)
    end
  end

  describe "get_results_or_kill_tasks" do
    test "should kill tasks that not ready jet" do
      kill_me_task = Task.async(fn -> "foo" end)
      kill_me_ref  = Process.monitor(kill_me_task.pid)

      ready_task = Task.async(fn -> "foo" end)
      ready_ref  = Process.monitor(ready_task.pid)

      tasks_with_results = [
        {kill_me_task, nil},
        {ready_task, {:ok, "example result"}}
      ]

      results = get_results_or_kill_tasks(tasks_with_results)

      ## results are collected
      assert results == [nil, "example result"]

      # task should down
      assert_receive {:DOWN, ^kill_me_ref, :process, _, :killed}, 500
      assert_receive {:DOWN, ^ready_ref, :process, _, :normal}, 500
    end
  end
end
