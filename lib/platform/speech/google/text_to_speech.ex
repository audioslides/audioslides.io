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
        "ssml": text
      },
      "voice": %{
        "languageCode": language_key,
        "name": voice
      },
      "audioConfig": %{
        "audioEncoding": "MP3"
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

  @doc """
  signs a url for speech with Amazon v4 API

  Example:
  "https://polly.eu-central-1.amazonaws.com:443/v1/speech/?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISGI2ES3XMIAV23Q%2F20171019%2Feu-central-1%2Fpolly%2Faws4_request&X-Amz-Date=20171019T082646Z&X-Amz-Expires=86400&X-Amz-Signature=b487f67c26926e71cf6d8711e68ce4f5e015138621869375b0681bfcba2e8757&X-Amz-SignedHeaders=host"

  Just do a basic smoke-test, function AWSAuth is already tested

  iex> params = Poison.encode!(%{"param1" => "x"})
  iex> result = get_signed_url(params)
  iex> result =~ "polly"
  true

  iex> params = Poison.encode!(%{"param1" => "x"})
  iex> result = get_signed_url(params)
  iex> result =~ "X-Amz-Algorithm=AWS4-HMAC-SHA256"
  true

  iex> params = Poison.encode!(%{"param1" => "x"})
  iex> result = get_signed_url(params)
  iex> result =~ "X-Amz-Signature="
  true

  """
  # def get_signed_url(params) do
  #   AWSAuth.QueryParameters.sign(
  #     @access_key,
  #     @secret_key,
  #     "POST",
  #     "https://polly.us-east-1.amazonaws.com:443/v1/speech/",
  #     "us-east-1",
  #     "polly",
  #     Map.new,
  #     DateTime.utc_now |> DateTime.to_naive,
  #     params
  #     )
  # end

  # ### Private functions

  # defp get_binary_speech(url, data) do
  #   case HTTPoison.post(url, data) do
  #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  #       body
  #     {:ok, %HTTPoison.Response{status_code: 404}} ->
  #       raise "404 - Not found"
  #     {:error, %HTTPoison.Error{reason: reason}} ->
  #       raise "Error in AWS Speech Polly at HTTP: #{reason}"
  #   end
  # end

end
