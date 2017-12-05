defmodule Platform.Video do
  @moduledoc """
  Context for the video converter
  """
  require Logger

  alias Platform.Filename
  alias Platform.FileHelper
  alias Platform.Speech
  alias Platform.VideoConverter
  alias Platform.VideoProcessingState

  alias Platform.Core
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide

  def convert_lesson_to_video(%Lesson{} = lesson) do
    #final_output_filename = Filename.get_filename_for_lesson_video(lesson)

    #### ASync Version Start
    # start async creation of the videos
    lesson
    |> create_async_video_tasks()
    #|> Enum.each(&IO.inspect(&1))

    # wait 60 seconds for all video generator processes
    # tasks_with_results = Task.yield_many(video_generation_tasks, 60_000)

    #generated_video_filenames = get_results_or_kill_tasks(tasks_with_results)
    #### ASync Version END

    #### Sync Version Start
    #
    # Core.update_lesson(lesson, %{video_sync_pid: self()})

    # generated_video_filenames = Enum.map(lesson.slides, fn slide -> generate_video_for_slide(lesson, slide) end)
    # VideoConverter.merge_videos(
    #   video_filename_list: generated_video_filenames,
    #   output_filename: final_output_filename
    # )


    # Core.update_lesson(lesson, %{video_sync_pid: nil})
    # send :processing_stream,{:done, VideoProcessingState.get_processing_state(lesson)}
    #### Sync Version End

  end

  def create_async_video_tasks(lesson) do
    Task.async_stream(lesson.slides, fn(slide) -> generate_video_for_slide(lesson, slide) end, timeout: 120_000)
  end

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

      Core.update_slide(slide, %{video_sync_pid: self()})

      VideoConverter.generate_video(
        image_filename: image_filename,
        audio_filename: audio_filename,
        output_filename: video_filename
      )

      Core.update_slide_video_hash(slide, generate_video_hash(slide))
      Core.update_slide(slide, %{video_sync_pid: nil})

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
  "94EE059335E587E501CC4BF90613E0814F00A7B08BC7C648FD865A2AF6A22CC2"

  iex> sha256("")
  "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

  """
  def sha256(data) do
    sha_hash = :crypto.hash(:sha256, data)
    Base.encode16(sha_hash)
  end

  @doc """

  iex> generate_video_hash(nil)
  nil

  iex> generate_video_hash(%Slide{audio_hash: "A", image_hash: "B"})
  "38164FBD17603D73F696B8B4D72664D735BB6A7C88577687FD2AE33FD6964153"

  iex> generate_video_hash(%Slide{audio_hash: "A", image_hash: "A"})
  "58BB119C35513A451D24DC20EF0E9031EC85B35BFC919D263E7E5D9868909CB5"

  """
  def generate_video_hash(%Slide{audio_hash: audio_hash, image_hash: image_hash})
      when is_binary(audio_hash) and is_binary(image_hash) do
    "#{audio_hash}#{image_hash}"
    |> sha256()
  end
  def generate_video_hash(%Lesson{slides: slides}) when is_list(slides) do
    slides
    |> Enum.map(fn slide -> slide.video_hash end)
    |> Enum.join
    |> sha256()
  end
  def generate_video_hash(_), do: nil

  def create_or_update_image_for_slide(lesson, slide) do
    if slide.page_elements_hash != slide.image_hash do
      Logger.info("Slide #{slide.id} Image: need update")

      Core.update_slide(slide, %{image_sync_pid: self()})


      Core.download_thumb!(lesson, slide)
      Core.update_slide_image_hash(slide, slide.page_elements_hash)

      Core.update_slide(slide, %{image_sync_pid: nil})


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

      Core.update_slide(slide, %{audio_sync_pid: self()})


      speech_binary =
        Speech.run(%{
          "language_key" => lesson.voice_language,
          "voice_gender" => lesson.voice_gender,
          "text" => slide.speaker_notes
        })

      FileHelper.write_to_file(audio_filename, speech_binary)
      Core.update_slide_audio_hash(slide, slide.speaker_notes_hash)

      Core.update_slide(slide, %{audio_sync_pid: nil})


      Logger.info("Slide #{slide.id} Audio: generated")
    else
      Logger.info("Slide #{slide.id} Audio: skipped")
    end

    audio_filename
  end

end
