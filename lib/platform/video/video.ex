defmodule Platform.Video do
  @moduledoc """
  Context for the video converter
  """
  require Logger

  alias Platform.GoogleSlides
  alias Platform.Speech
  alias Platform.Converter

  alias Platform.Core.Schema.Presentation
  alias Platform.Core.Schema.Slide
  alias Platform.Core.PresentationSync

  @content_dir Application.get_env(:platform, :content_dir)

  def convert_presentation_to_video(%Presentation{} = presentation) do
    concat_input_filename = "#{@content_dir}#{presentation.id}.txt"
    final_output_filename = "#{@content_dir}#{presentation.id}.mp4"

    # start async creation of the videos
    video_generation_tasks = Enum.map(presentation.slides, fn(slide) -> Task.async(fn -> generate_video_for_slide(presentation, slide) end) end)

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

    save_video_filenames(generated_video_filenames, concat_input_filename)

    Converter.merge_videos(input_txt: concat_input_filename, output_filename: final_output_filename)
  end

  defp save_video_filenames(filenames, output_file) do
    File.rm(output_file)
    {:ok, file} = File.open(output_file, [:append])

    Enum.each(filenames,
      fn(filename) ->
        IO.binwrite(file, "file '#{filename}'\n")
      end)

    File.close(file)
  end

  def generate_video_for_slide(%Presentation{} = presentation, %Slide{} = slide) do

    google_slide = GoogleSlides.get_slide!(presentation.google_presentation_id, slide.google_object_id)

    image_filename = create_or_update_image_for_slide(presentation, slide, google_slide)
    audio_filename = create_or_update_audio_for_slide(presentation, slide, google_slide)
    video_filename = "#{@content_dir}#{presentation.id}/#{slide.id}.mp4"

    # Only generate video of audio or video changed
    if !File.exists?(video_filename) || any_content_changed?(slide, google_slide) do
      Logger.info "Slide #{slide.id} Hash: updated"
      PresentationSync.update_hash_for_slide(slide, google_slide)

      Logger.info "Slide #{slide.id} Video: generated"
      Converter.merge_audio_image(
        audio_filename: audio_filename,
        image_filename: image_filename,
        out_filename: "#{@content_dir}#{presentation.id}/#{slide.id}.mp4",
      )
    else
      Logger.info "Slide #{slide.id} Video: skipped"
    end

    # relative_output_filename
    "#{presentation.id}/#{slide.id}.mp4"
  end

  def any_content_changed?(slide, google_slide) do
    content_changed_for_speaker_notes?(slide, google_slide) || content_changed_for_page_elements?(slide, google_slide)
  end

  def create_or_update_image_for_slide(presentation, slide, google_slide) do
    image_filename = "#{@content_dir}#{presentation.id}/#{slide.id}.png"
    if !File.exists?(image_filename) || content_changed_for_page_elements?(slide, google_slide) do
      Logger.info "Slide #{slide.id} Image: generated"
      GoogleSlides.download_slide_thumb!(presentation.google_presentation_id, slide.google_object_id, image_filename)
    else
      Logger.info "Slide #{slide.id} Image: skipped"
    end

    image_filename
  end

  def create_or_update_audio_for_slide(presentation, slide, google_slide) do
    audio_filename = Speech.get_filename(presentation.id, slide.id)
    if !File.exists?(audio_filename) || content_changed_for_speaker_notes?(slide, google_slide) do
      Logger.info "Slide #{slide.id} Audio: generated"
      notes = GoogleSlides.get_speaker_notes(google_slide)

      Speech.speak()
      |> Speech.language(presentation.voice_language)
      |> Speech.voice_gender(presentation.voice_gender)
      |> Speech.text(notes)
      |> Speech.for_presentation(presentation.id)
      |> Speech.for_slide(slide.id)
      |> Speech.run()
    else
      Logger.info "Slide #{slide.id} Audio: skipped"
    end

    audio_filename
  end

  def content_changed_for_speaker_notes?(%{speaker_notes_hash: old_hash}, google_slide) do
    new_hash = GoogleSlides.generate_hash_for_speakernotes(google_slide)

    new_hash != old_hash
  end

  def content_changed_for_page_elements?(%{page_elements_hash: old_hash}, google_slide) do
    new_hash = GoogleSlides.generate_hash_for_page_elements(google_slide)

    new_hash != old_hash
  end

end
