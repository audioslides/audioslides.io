defmodule PlatformWeb.ViewHelper do
  @moduledoc false

  @example_image "/images/example-slide.png"

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
    slide = List.first(lesson.slides)
    get_slide_image(lesson, slide)
  end
  def get_course_front_slide_image(_), do: @example_image

  def get_slide_image(lesson, slide) do
    image = Filename.get_filename_for_slide_image(lesson, slide)
    if File.exists?(image) do
      "/content/#{lesson.id}/#{slide.id}.png"
    else
      @example_image
    end
  end

end
