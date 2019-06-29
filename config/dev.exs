use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :platform, PlatformWeb.Endpoint,
  http: [port: 4200],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("AS_GOOGLE_OAUTH_CLIENT_ID"),
  client_secret: System.get_env("AS_GOOGLE_OAUTH_CLIENT_SECRET")

# Watch static and templates for browser reloading.
config :platform, PlatformWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/(?!content).*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/platform_web/views/.*(ex)$},
      ~r{lib/platform_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :platform, Platform.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "audioslides_io_dev",
  hostname: "127.0.0.1",
  pool_size: 10
