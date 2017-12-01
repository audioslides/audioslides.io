defmodule PlatformWeb.HttpsRedirectPlugTest do
  alias PlatformWeb.HttpsRedirectPlug
  use PlatformWeb.ConnCase

  describe "#init" do
    test "passes the options unmodified" do
      opts = %{test: 123}
      assert HttpsRedirectPlug.init(opts) == opts
    end
  end

  describe "#call" do
    test "redirects does nothing if there's no x-forwarded-proto http header" do
      conn = %{build_conn(:get, "/") | host: "workshops.de"}
      conn_2 = put_req_header(conn, "x-forwarded-proto", "https")
      response_1 = HttpsRedirectPlug.call(conn, nil)
      response_2 = HttpsRedirectPlug.call(conn_2, nil)

      assert List.last(response_1.resp_headers) == {"cache-control", "max-age=0, private, must-revalidate"}

      assert List.last(response_2.resp_headers) == {"cache-control", "max-age=0, private, must-revalidate"}
    end

    test "test redirect of naked path" do
      conn = %{build_conn(:get, "/") | host: "workshops.de"}
      conn = put_req_header(conn, "x-forwarded-proto", "http")
      response = HttpsRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) == {"location", "https://workshops.de/"}
      assert response(response, 301)
    end

    test "test redirect of path" do
      conn = %{build_conn(:get, "/some/path") | host: "workshops.de"}
      conn = put_req_header(conn, "x-forwarded-proto", "http")
      response = HttpsRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) == {"location", "https://workshops.de/some/path"}
      assert response(response, 301)
    end

    test "test redirect of path with params" do
      conn = %{build_conn(:get, "/some/path?foo=bar") | host: "workshops.de"}
      conn = put_req_header(conn, "x-forwarded-proto", "http")
      response = HttpsRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) == {"location", "https://workshops.de/some/path?foo=bar"}

      assert response(response, 301)
    end

    test "test redirect with ssl" do
      conn = %{build_conn(:get, "/some/path") | host: "workshops.de"}
      conn = put_req_header(conn, "x-forwarded-proto", "http")
      response = HttpsRedirectPlug.call(conn, nil)

      assert List.last(response.resp_headers) == {"location", "https://workshops.de/some/path"}
      assert response(response, 301)
    end
  end
end
