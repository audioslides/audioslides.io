defmodule Platform.SpeechAPI do
  @moduledoc """
  The Speech context
  """

  @callback get_speech(params :: Map.t()) :: any

  @callback get_speech_url(params :: Map.t()) :: any
end
