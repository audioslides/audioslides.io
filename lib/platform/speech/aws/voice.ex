defmodule Platform.Speech.AWS.Voice do
  @moduledoc """
  The Speech context
  """

  @doc """

  iex> get_voice(voice_gender: "male", language: "de-DE")
  "Hans"

  iex> get_voice(voice_gender: "female", language: "de-DE")
  "Vicki"

  iex> get_voice(voice_gender: "male", language: "en-US")
  "Joey"

  iex> get_voice(voice_gender: "female", language: "en-US")
  "Joanna"

  """
  def get_voice([voice_gender: "male", language: "de-DE"]), do: "Hans"
  def get_voice([voice_gender: "female", language: "de-DE"]), do: "Vicki"
  def get_voice([voice_gender: "male", language: "en-US"]), do: "Joey"
  def get_voice([voice_gender: "female", language: "en-US"]), do: "Joanna"
end
