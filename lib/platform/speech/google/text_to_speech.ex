defmodule Platform.Speech.Google.TextToSpeech do
  @moduledoc """
  The Speech context
  """

  @behaviour Platform.SpeechAPI

  alias Goth.Token

  alias Platform.Speech.Google.Voice

  #@access_key Application.get_env(:platform, :aws)[:access_key_id]
  #@secret_key Application.get_env(:platform, :aws)[:secret]

  @regex_ssml ~r/(<speak>[\s\S]*?<\/speak>)/

  def get_speech(%{"language_key" => language_key, "voice_gender" => voice_gender, "text" => text}) do
    voice = Voice.get_voice(voice_gender: voice_gender, language: language_key)

    params = %{
      "input": %{
        "ssml": "<speak>" <> text <> "</speak>"
      },
      "voice": %{
        "languageCode": language_key,
        "name": voice
      },
      "audioConfig": %{
        "audioEncoding": "LINEAR16",
        "pitch": -4,
        "speakingRate": 1.00
      }
    }

    data = Poison.encode!(params)

    get_speech_binary(data)
  end

  defp get_speech_binary(data) do
    headers = get_headers_with_token()

    case HTTPoison.post("https://texttospeech.googleapis.com/v1beta1/text:synthesize", data, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"audioContent" => audio_content_base64} = Poison.decode!(body)
        Base.decode64!(audio_content_base64)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        raise "404 - Not found"
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise "Error in Google TTL at HTTP: #{reason}"
    end
  end

  defp get_headers_with_token do
    {:ok, goth_token} = Token.for_scope("https://www.googleapis.com/auth/cloud-platform")

    token = goth_token.token

    ["Authorization": "Bearer #{token}", "Content-Type": "application/json; charset=utf-8"]
  end

  defp write_to_file(filename, data) do
    {:ok, file} = File.open filename, [:write]
    IO.binwrite(file, data)
  end

  @doc """
  Is given Text SSML or normal text?

  iex> get_text("Normal Text")
  "Normal Text"

  iex> get_text("<speak>SSML Text</speak>")
  "<speak>SSML Text</speak>"

  iex> get_text("<speak>SSML Text\\n\\nLine Breaks also okay</speak>")
  "<speak>SSML Text\\n\\nLine Breaks also okay</speak>"

  You can use comments outside of your speak tag
  iex> get_text("Some other notes before the speak tag!!\\n<speak>Comments outside are okay</speak>")
  "<speak>Comments outside are okay</speak>"

  Only first tag is used
  iex> get_text("<speak>Tag1</speak><speak>Tag2</speak>")
  "<speak>Tag1</speak>"

  """
  def get_text(text) do
    case get_text_type(text) do
      "text" -> text
      "ssml" ->
        [_, speak_tag_group] = Regex.run(@regex_ssml, text)
        speak_tag_group
    end
  end

  @doc """

  iex> get_text_type("Normal Text")
  "text"

  iex> get_text_type("<speak>TEXT</speak>")
  "ssml"

  """
  def get_text_type(text) do
    if contains_text_ssml?(text) do
      "ssml"
    else
      "text"
    end
  end

  @doc """
  Is given Text SSML or normal text?

  iex> contains_text_ssml?("Normal Text")
  false

  iex> contains_text_ssml?("<speak>SSML Text</speak>")
  true

  iex> contains_text_ssml?("<speak>SSML Text\\n\\nLine Breaks also okay</speak>")
  true

  """
  def contains_text_ssml?(text) do
    Regex.match?(@regex_ssml, text)
  end

end
