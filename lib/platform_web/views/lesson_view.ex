defmodule PlatformWeb.LessonView do
  use PlatformWeb, :view

  @content_dir Application.get_env(:platform, :content_dir)

  def get_lang_icon("de-DE"), do: "🇩🇪"
  def get_lang_icon("en-US"), do: "🇺🇸"
  def get_lang_icon(lang), do: lang

  def get_gender_icon("male"), do: "👨‍🏫"
  def get_gender_icon("female"), do: "👩‍🏫"
  def get_gender_icon(gender), do: gender

  def get_frontimage(%{slides: slides} = lesson) when length(slides) > 0 do
      slide_id = List.first(lesson.slides).id
      if File.exists?("#{@content_dir}#{lesson.id}/#{slide_id}.png") do
        "/content/#{lesson.id}/#{slide_id}.png"
      else
        "/images/example-slide.png"
      end
  end
  def get_frontimage(_), do: "/images/example-slide.png"

  def get_slide_image(lesson, slide) do
    if File.exists?("#{@content_dir}#{lesson.id}/#{slide.id}.png") do
      "/content/#{lesson.id}/#{slide.id}.png"
    else
      "/images/example-slide.png"
    end
end

end
