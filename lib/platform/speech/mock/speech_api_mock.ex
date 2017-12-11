defmodule Platform.Speech.Mock.SpeechApi do
  @moduledoc """
  The Speech Mock context
  """

  @behaviour Platform.SpeechAPI

  @doc """
  Mock a binary output speech sync API

  In this case just a mp3 header

  iex> get_speech(%{})
  <<73, 68, 51, 4, 0, 0, 0, 0, 0>>

  """
  def get_speech(_) do
    <<73, 68, 51, 4, 0, 0, 0, 0, 0>>
  end

  @doc """
  Mock a

  iex> get_speech_url(%{})
  "http://mocked-amazon.com/polly/?Text=EXAMPLE"

  """
  def get_speech_url(_) do
    "http://mocked-amazon.com/polly/?Text=EXAMPLE"
  end
end
