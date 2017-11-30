defmodule PlatformWeb.BreadcrumbHelper do
  @moduledoc false
  use Phoenix.HTML

  @doc """
  iex> BreadcrumbHelper.encode(%{title: "Issues"})
  [{"Issues", nil}]

  iex> BreadcrumbHelper.encode(%{title: "Comments", parent: %{title: "Issues", path: "/issues"}})
  [{"Issues", "/issues"}, {"Comments", nil}]

  iex> BreadcrumbHelper.encode(%{title: "Comments", parent: %{}})
  ** (RuntimeError) Provide a link for parent
  """
  def encode(%{parent: %{path: _} = parent} = map) when is_map(parent) do
    encode(parent) ++ [encode_single(map)]
  end
  def encode(%{parent: parent}) when is_map(parent) do
    raise "Provide a link for parent"
  end
  def encode(%{} = map) do
    [encode_single(map)]
  end

  @doc """
  iex> BreadcrumbHelper.encode_single(%{title: "Issues"})
  {"Issues", nil}

  iex> BreadcrumbHelper.encode_single(%{title: "Issues", path: "/issues"})
  {"Issues", "/issues"}
  """
  def encode_single(%{title: title} = map) do
    {title, Map.get(map, :path)}
  end
end
