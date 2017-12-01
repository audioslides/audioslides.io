defmodule Platform.Speech do
  @moduledoc """
  The Speech context
  """

  @speech_api Application.get_env(:platform, :speech_api)

  @doc """
  Run the API call with gathered params
  In this test-case via SpeechApiMock

  iex> %{} |> run()
  <<73, 68, 51, 4, 0, 0, 0, 0, 0>>

  """
  def run(params) do
    @speech_api.get_speech(params)
  end

  @doc """
  Run the API call with gathered params
  In this test-case via SpeechApiMock

  iex> %{} |> run()
  <<73, 68, 51, 4, 0, 0, 0, 0, 0>>

  """
  def get_speech_url(params) do
    @speech_api.get_speech_url(params)
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
end
