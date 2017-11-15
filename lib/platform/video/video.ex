defmodule Platform.Video do
  @moduledoc """
  Context for the video converter
  """
  require Logger

  alias Platform.Filename
  alias Platform.GoogleSlides
  alias Platform.Speech
  alias Platform.Converter

  alias Platform.Core
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide


  def convert_lesson_to_video(%Lesson{} = lesson) do
    final_output_filename = Filename.get_filename_for_lesson_video(lesson)

    # start async creation of the videos
    video_generation_tasks = Enum.map(lesson.slides, fn(slide) -> Task.async(fn -> generate_video_for_slide(lesson, slide) end) end)

    # wait 60 seconds for all video generator processes
    tasks_with_results = Task.yield_many(video_generation_tasks, 60_000)

    generated_video_filenames = Enum.map(tasks_with_results, fn {task, res} ->
      # Shutdown the tasks that did not reply nor exit
      case res do
        {:ok, value} ->
          value
        nil ->
          Task.shutdown(task, :brutal_kill)
      end
    end)

    Converter.merge_videos(video_filename_list: generated_video_filenames, output_filename: final_output_filename)
  end

  def generate_video_for_slide(%Lesson{} = lesson, %Slide{} = slide) do
    image_filename = create_or_update_image_for_slide(lesson, slide)
    audio_filename = create_or_update_audio_for_slide(lesson, slide)

    video_filename = Filename.get_filename_for_slide_video(lesson, slide)

    # Only generate video of audio or video changed
    if generate_video_hash(slide) != slide.video_hash do
      Logger.info "Slide #{slide.id} Video: generated"

      Converter.generate_video(
        image_filename: image_filename,
        audio_filename: audio_filename,
        output_filename: video_filename
      )

      Core.update_slide_video_hash(slide, generate_video_hash(slide))
    else
      Logger.info "Slide #{slide.id} Video: skipped"
    end

    # relative_output_filename
    # "#{lesson.id}/#{slide.id}.mp4"
    Filename.get_filename_for_slide_video(lesson, slide)
  end

  def sha256(data), do: :crypto.hash(:sha256, data)

  def generate_video_hash(%Slide{audio_hash: audio_hash, image_hash: image_hash}) when is_binary(audio_hash) and is_binary(image_hash) do
    "#{audio_hash}#{image_hash}"
    |> sha256()
    |> Base.encode16()
  end
  def generate_video_hash(_), do: nil

  def create_or_update_image_for_slide(lesson, slide) do
    image_filename = Filename.get_filename_for_slide_image(lesson, slide)
    if slide.page_elements_hash != slide.image_hash do

      GoogleSlides.download_slide_thumb!(lesson.google_presentation_id, slide.google_object_id, image_filename)
      Core.update_slide_image_hash(slide, slide.page_elements_hash)

      Logger.info "Slide #{slide.id} Image: generated"
    else
      Logger.info "Slide #{slide.id} Image: skipped"
    end

    image_filename
  end

  def create_or_update_audio_for_slide(lesson, slide) do
    audio_filename = Filename.get_filename_for_slide_audio(lesson, slide)
    if slide.speaker_notes_hash != slide.audio_hash do
      Logger.info "Slide #{slide.id} Audio: generated"

      speech_binary = Speech.speak()
      |> Speech.language(lesson.voice_language)
      |> Speech.voice_gender(lesson.voice_gender)
      |> Speech.text(slide.speaker_notes)
      |> Speech.run()

      write_to_file(audio_filename, speech_binary)
      Core.update_slide_audio_hash(slide, slide.speaker_notes_hash)
    else
      Logger.info "Slide #{slide.id} Audio: skipped"
    end

    audio_filename
  end

  defp write_to_file(filename, data) do
    [_, directory, filename] = Regex.run(~r/^(.*\/)([^\/]*)$/, filename)
    File.mkdir_p(directory)
    {:ok, file} = File.open filename, [:write]
    IO.binwrite(file, data)
  end
end
