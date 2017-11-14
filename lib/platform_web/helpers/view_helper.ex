defmodule PlatformWeb.ViewHelper do
  @moduledoc false

  @content_dir Application.get_env(:platform, :content_dir)

  @doc """
  iex> lang_icon("de-DE")
  ~s(🇩🇪)

  iex> lang_icon("en-US")
  ~s(🇺🇸)

  iex> lang_icon("pl-pl")
  ~s(pl-pl)
  """
  def lang_icon("de-DE"), do: "🇩🇪"
  def lang_icon("en-US"), do: "🇺🇸"
  def lang_icon(lang), do: lang

  @doc """
  iex> voice_gender_icon("male")
  ~s(👨‍🏫)

  iex> voice_gender_icon("female")
  ~s(👩‍🏫)

  iex> voice_gender_icon("non-binary")
  ~s(Not supported)
  """
  def voice_gender_icon("male"), do: "👨‍🏫"
  def voice_gender_icon("female"), do: "👩‍🏫"
  def voice_gender_icon(_), do: "Not supported"

  def get_course_front_slide_image(%{slides: slides} = lesson) when length(slides) > 0 do
    slide_id = List.first(lesson.slides).id

    if File.exists?("#{@content_dir}#{lesson.id}/#{slide_id}.png") do
      "/content/#{lesson.id}/#{slide_id}.png"
    else
      "/images/example-slide.png"
    end
  end
  def get_course_front_slide_image(_), do: "/images/example-slide.png"

  def get_slide_image(lesson, slide) do
    if File.exists?("#{@content_dir}#{lesson.id}/#{slide.id}.png") do
      "/content/#{lesson.id}/#{slide.id}.png"
    else
      "/images/example-slide.png"
    end
  end

end
