defmodule PlatformWeb.HttpsRedirectPlug do
  @moduledoc """
  Redirects http to https if request comes from a proxy
  and the x-forwarded-proto header is set to http
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_req_header(conn, "x-forwarded-proto") == ["http"] do
      redirect_to_https_version(conn)
    else
      conn
    end
  end

  defp redirect_to_https_version(conn) do
    status = if conn.method in ~w(HEAD GET), do: 301, else: 307

    location =
      "https://" <> naked_host(conn.host) <>
      conn.request_path <> qs(conn.query_string)

    conn
    |> put_resp_header("location", location)
    |> send_resp(status, "You are being redirected")
    |> halt()
  end

  defp naked_host(host), do: String.trim_leading(host, "www.")

  defp qs(""), do: ""
  defp qs(qs), do: "?" <> qs
end
