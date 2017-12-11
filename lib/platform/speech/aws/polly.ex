defmodule Platform.Speech.AWS.Polly do
  @moduledoc """
  The Speech context
  """

  @behaviour Platform.SpeechAPI

  alias Platform.Speech.AWS.Voice

  @regex_ssml ~r/(<speak>[\s\S]*?<\/speak>)/

  def get_speech(%{"language_key" => language_key, "voice_gender" => voice_gender, "text" => text}) do
    voice = Voice.get_voice(voice_gender: voice_gender, language: language_key)

    params = build_params(%{"text" => text, "voice" => voice})

    get_binary_speech(params)
  end

  @doc """
  Get signed URL from amazon polly

  iex> result = get_speech_url(%{"text" => "EXAMPLE_TEXT", "voice_gender" => "male", "language_key" => "de-DE"})
  iex> result =~ "Text=EXAMPLE_TEXT"
  true

  iex> result = get_speech_url(%{"text" => "EXAMPLE_TEXT", "voice_gender" => "male", "language_key" => "de-DE"})
  iex> result =~ "TextType=text"
  true

  iex> result = get_speech_url(%{"text" => "<speak>EXAMPLE_TEXT</speak>", "voice_gender" => "male", "language_key" => "de-DE"})
  iex> result =~ "TextType=ssml"
  true

  """
  def get_speech_url(%{"language_key" => language_key, "voice_gender" => voice_gender, "text" => text}) do
    voice = Voice.get_voice(voice_gender: voice_gender, language: language_key)
    params = build_params(%{"text" => text, "voice" => voice})
    get_signed_get_url(params)
  end

  @doc """
  Build params for the request

  Should work with pure text
  iex> build_params(%{"text" => "text", "voice" => "voice"})
  %{"OutputFormat" => "mp3", "SampleRate" => "8000", "VoiceId" => "voice", "Text" => "text", "TextType" => "text"}

  Should work with SSML
  iex> build_params(%{"text" => "<speak>text</speak>", "voice" => "voice"})
  %{"OutputFormat" => "mp3", "SampleRate" => "8000", "VoiceId" => "voice", "Text" => "<speak>text</speak>", "TextType" => "ssml"}

  Should ignore additional text when type SSML
  iex> build_params(%{"text" => "<speak>text</speak>Some Additional Information", "voice" => "voice"})
  %{"OutputFormat" => "mp3", "SampleRate" => "8000", "VoiceId" => "voice", "Text" => "<speak>text</speak>", "TextType" => "ssml"}

  """
  def build_params(%{"text" => text, "voice" => voice}) do
    %{
      "OutputFormat" => "mp3",
      "SampleRate" => "8000",
      "VoiceId" => voice,
      "Text" => get_text(text),
      "TextType" => get_text_type(text)
    }
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

  Ignore additional comments for editors
  iex> get_text("<speak>Tag1</speak>Some extra information for editors")
  "<speak>Tag1</speak>"

  Should return empty string on empty string input
  iex> get_text("")
  ""

  Should return empty string on empty string input
  iex> get_text(nil)
  ""

  """
  def get_text(nil), do: ""

  def get_text(text) do
    case get_text_type(text) do
      "text" ->
        text

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

  iex> contains_text_ssml?("<speak>SSML Text\\n\\nLine Breaks also okay</speak>Some extra information for editor.")
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

  iex> result = get_signed_url(%{"param1" => "x"})
  iex> result =~ "polly"
  true

  iex> result = get_signed_url(%{"param1" => "x"})
  iex> result =~ "X-Amz-Algorithm=AWS4-HMAC-SHA256"
  true

  iex> result = get_signed_url(%{"param1" => "x"})
  iex> result =~ "X-Amz-Signature="
  true

  """
  def get_signed_url(params) do
    data = Poison.encode!(params)
    AWSAuth.QueryParameters.sign(
      Application.get_env(:platform, :aws)[:access_key_id],
      Application.get_env(:platform, :aws)[:secret],
      "POST",
      "https://polly.us-east-1.amazonaws.com:443/v1/speech/",
      "us-east-1",
      "polly",
      Map.new(),
      DateTime.utc_now() |> DateTime.to_naive(),
      data
    )
  end

  @doc """
  signs a url for speech with Amazon v4 API

  Example:
  "https://polly.eu-central-1.amazonaws.com:443/v1/speech/?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAISGI2ES3XMIAV23Q%2F20171019%2Feu-central-1%2Fpolly%2Faws4_request&X-Amz-Date=20171019T082646Z&X-Amz-Expires=86400&X-Amz-Signature=b487f67c26926e71cf6d8711e68ce4f5e015138621869375b0681bfcba2e8757&X-Amz-SignedHeaders=host"

  Just do a basic smoke-test, function AWSAuth is already tested

  iex> params = %{"param1" => "x"}
  iex> result = get_signed_get_url(params)
  iex> result =~ "polly"
  true

  iex> params = %{"param1" => "x"}
  iex> result = get_signed_get_url(params)
  iex> result =~ "X-Amz-Algorithm=AWS4-HMAC-SHA256"
  true

  iex> params = %{"param1" => "x"}
  iex> result = get_signed_get_url(params)
  iex> result =~ "X-Amz-Signature="
  true

  iex> params = %{"text" => "example_text"}
  iex> result = get_signed_get_url(params)
  iex> result =~ "text=example_text"
  true

  """
  def get_signed_get_url(params) do
    AWSAuth.QueryParameters.sign(
      Application.get_env(:platform, :aws)[:access_key_id],
      Application.get_env(:platform, :aws)[:secret],
      "GET",
      "https://polly.eu-central-1.amazonaws.com:443/v1/speech/?#{URI.encode_query(params)}",
      "eu-central-1",
      "polly",
      Map.new(),
      DateTime.utc_now() |> DateTime.to_naive(),
      ""
    )
  end

  ### Private functions

  defp get_binary_speech(params) do
    url = get_signed_url(params)
    data = Poison.encode!(params)

    case HTTPoison.post(url, data) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        raise "404 - Not found"

      {:error, %HTTPoison.Error{reason: reason}} ->
        raise "Error in AWS Speech Polly at HTTP: #{reason}"
    end
  end
end
