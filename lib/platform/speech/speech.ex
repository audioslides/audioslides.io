defmodule Platform.Speech do
  @moduledoc """
  The Speech context
  """

  @speech_api Application.get_env(:platform, :speech_api)
  @content_dir Application.get_env(:platform, :content_dir)

  def run(%{"presentation_id" => presentation_id, "slide_id" => slide_id} = params) do
    filename = get_filename(presentation_id, slide_id)

    speech_binary = @speech_api.get_speech(params)

    write_to_file(filename, speech_binary)

    filename
  end

  @doc """

  iex> speak()
  %{"language_key" => "de-DE","voice_gender" => "female", "text" => ""}

  iex> speak() |> language("en-US") |> voice_gender("male")
  %{"language_key" => "en-US","voice_gender" => "male", "text" => ""}

  iex> speak() |> language("en-US") |> voice_gender("male") |> text("Komische API hier")
  %{"language_key" => "en-US","voice_gender" => "male", "text" => "Komische API hier"}

  """
  def speak do
    %{
      "language_key" => "de-DE",
      "voice_gender" => "female",
      "text" => ""
    }
  end

  @doc """

  iex> %{} |> language("de-DE")
  %{"language_key" => "de-DE"}

  iex> %{} |> language("en-US")
  %{"language_key" => "en-US"}

  """
  def language(params, language_key) do
    Map.put(params, "language_key", language_key)
  end

  @doc """

  iex> %{} |> for_presentation("123")
  %{"presentation_id" => "123"}

  """
  def for_presentation(params, presentation_id) do
    Map.put(params, "presentation_id", presentation_id)
  end

  @doc """

  iex> %{} |> for_slide("321")
  %{"slide_id" => "321"}

  """
  def for_slide(params, slide_id) do
    Map.put(params, "slide_id", slide_id)
  end

  @doc """

  iex> %{} |> voice_gender("male")
  %{"voice_gender" => "male"}

  iex> %{} |> voice_gender("female")
  %{"voice_gender" => "female"}

  """
  def voice_gender(params, voice_gender) do
    Map.put(params, "voice_gender", voice_gender)
  end

  @doc """

  iex> %{} |> text("TEST")
  %{"text" => "TEST"}

  iex> %{} |> text("TEST!!!!!")
  %{"text" => "TEST!!!!!"}

  """
  def text(params, text) do
    Map.put(params, "text", text)
  end

  defp write_to_file(filename, data) do
    {:ok, file} = File.open filename, [:write]
    IO.binwrite(file, data)
  end

  def get_filename(presentation_id, slide_id) do
    directory = "#{@content_dir}#{presentation_id}"
    File.mkdir_p(directory)

    "#{directory}/#{slide_id}.mp3"
  end

end
