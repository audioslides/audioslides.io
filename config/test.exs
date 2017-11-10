use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :platform, PlatformWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :platform, Platform.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: System.get_env("DATABASE_MYSQL_USERNAME") || "root",
  password: System.get_env("DATABASE_MYSQL_PASSWORD") || "",
  database: "audioslides_io_test",
  hostname: "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox

config :exvcr, [
  vcr_cassette_library_dir: "test/support/vcr_cassettes",
]

#config :platform, :speech_api, Platform.Speech.AWS.Polly
