defmodule Platform.SlideAPI do
  @moduledoc """
  Context for the general converter
  """
  @adapter Application.get_env(:platform, __MODULE__, [])[:adapter]

  @doc """
  Get a presentation from the api

  """
  @callback get_presentation(String.t) :: {:ok, String.t} | {:error, String.t}
  defdelegate get_presentation(presentation_id), to: @adapter

  @doc """
  Get a slide from the api

  """
  @callback get_slide!(String.t, String.t) :: {}
  defdelegate get_slide!(presentation_id, slide_id), to: @adapter

  @doc """
  Get a slide from the api

  """
  @callback get_slide!(String.t, String.t) :: {}
  defdelegate get_slide!(presentation_id, slide_id), to: @adapter

  @doc """
  Get a slide thump from the api

  """
  @callback get_slide_thumb!(String.t, String.t) :: {}
  defdelegate get_slide_thumb!(presentation_id, slide_id), to: @adapter

  @doc """
  Get a download a slide thump from the api

  """
  @callback download_slide_thumb!(String.t, String.t, String.t) :: {}
  defdelegate download_slide_thumb!(presentation_id, slide_id, filename), to: @adapter

end
