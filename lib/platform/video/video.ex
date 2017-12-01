defmodule Platform.Video do
  @moduledoc """
  Context for the video converter
  """
  require Logger

  alias Platform.Filename
  alias Platform.FileHelper
  alias Platform.Speech
  alias Platform.VideoConverter

  alias Platform.Core
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide

  def convert_lesson_to_video(%Lesson{} = lesson) do
    final_output_filename = Filename.get_filename_for_lesson_video(lesson)

    #### ASync Version Start
    # start async creation of the videos
    # video_generation_tasks = create_async_video_tasks(lesson)

    # wait 60 seconds for all video generator processes
    # tasks_with_results = Task.yield_many(video_generation_tasks, 60_000)

    # generated_video_filenames = get_results_or_kill_tasks(tasks_with_results)
    #### ASync Version END

    #### Sync Version Start
    generated_video_filenames = Enum.map(lesson.slides, fn slide -> generate_video_for_slide(lesson, slide) end)

    #### Sync Version End

    VideoConverter.merge_videos(
      video_filename_list: generated_video_filenames,
      output_filename: final_output_filename
    )
  end

  # def create_async_video_tasks(lesson) do
  #   Enum.map(lesson.slides, fn(slide) ->
  #     Task.async(fn -> generate_video_for_slide(lesson, slide) end)
  #   end)
  # end

  def get_results_or_kill_tasks(tasks_with_results) do
    Enum.map(tasks_with_results, fn {task, res} ->
      # Shutdown the tasks that did not reply nor exit
      case res do
        {:ok, value} ->
          value

        nil ->
          Task.shutdown(task, :brutal_kill)
      end
    end)
  end

  def generate_video_for_slide(%Lesson{} = lesson, %Slide{} = slide) do
    image_filename = create_or_update_image_for_slide(lesson, slide)
    audio_filename = create_or_update_audio_for_slide(lesson, slide)

    video_filename = Filename.get_filename_for_slide_video(lesson, slide)

    # Only generate video of audio or video changed
    if generate_video_hash(slide) != slide.video_hash do
      Logger.info("Slide #{slide.id} Video: need update")

      VideoConverter.generate_video(
        image_filename: image_filename,
        audio_filename: audio_filename,
        output_filename: video_filename
      )

      Core.update_slide_video_hash(slide, generate_video_hash(slide))
      Logger.info("Slide #{slide.id} Video: generated")
    else
      Logger.info("Slide #{slide.id} Video: skipped")
    end

    # relative_output_filename, important for ffmmpeg concat method
    # "#{lesson.id}/#{slide.id}.mp4"
    Filename.get_relative_filename_for_slide_video(lesson, slide)
  end

  @doc """
  iex> sha256("TEST")
  <<148, 238, 5, 147, 53, 229, 135, 229, 1, 204, 75, 249, 6, 19, 224, 129, 79, 0, 167, 176, 139, 199, 198, 72, 253, 134, 90, 42, 246, 162, 44, 194>>

  iex> sha256("")
  <<227, 176, 196, 66, 152, 252, 28, 20, 154, 251, 244, 200, 153, 111, 185, 36, 39, 174, 65, 228, 100, 155, 147, 76, 164, 149, 153, 27, 120, 82, 184, 85>>

  """
  def sha256(data), do: :crypto.hash(:sha256, data)

  @doc """

  iex> generate_video_hash(nil)
  nil

  iex> generate_video_hash(%Slide{audio_hash: "A", image_hash: "B"})
  "AB"

  iex> generate_video_hash(%Slide{audio_hash: "A", image_hash: "A"})
  "AA"

  """
  def generate_video_hash(%Slide{audio_hash: audio_hash, image_hash: image_hash})
      when is_binary(audio_hash) and is_binary(image_hash) do
    "#{audio_hash}#{image_hash}"
    # |> sha256()
    # |> Base.encode16()
  end
  def generate_video_hash(%Lesson{slides: slides}) when is_list(slides) do
    slides
    |> Enum.map(fn slide -> slide.video_hash end)
    |> Enum.join
  # |> sha256()
  # |> Base.encode16()
  end
  def generate_video_hash(_), do: nil

  def create_or_update_image_for_slide(lesson, slide) do
    if slide.page_elements_hash != slide.image_hash do
      Logger.info("Slide #{slide.id} Image: need update")

      Core.download_thumb!(lesson, slide)
      Core.update_slide_image_hash(slide, slide.page_elements_hash)

      Logger.info("Slide #{slide.id} Image: generated")
    else
      Logger.info("Slide #{slide.id} Image: skipped")
    end

    Filename.get_filename_for_slide_image(lesson, slide)
  end

  def create_or_update_audio_for_slide(lesson, slide) do
    audio_filename = Filename.get_filename_for_slide_audio(lesson, slide)

    if slide.speaker_notes_hash != slide.audio_hash do
      Logger.info("Slide #{slide.id} Audio: need update")

      speech_binary =
        Speech.run(%{
          "language_key" => lesson.voice_language,
          "voice_gender" => lesson.voice_gender,
          "text" => slide.speaker_notes
        })

      FileHelper.write_to_file(audio_filename, speech_binary)
      Core.update_slide_audio_hash(slide, slide.speaker_notes_hash)

      Logger.info("Slide #{slide.id} Audio: generated")
    else
      Logger.info("Slide #{slide.id} Audio: skipped")
    end

    audio_filename
  end

end
