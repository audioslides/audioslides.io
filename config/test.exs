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
  database: System.get_env("DATABASE_MYSQL_DATABASE") || "audioslides_io_test",
  hostname: System.get_env("DATABASE_MYSQL_HOSTNAME") || "127.0.0.1",
  pool: Ecto.Adapters.SQL.Sandbox

config :exvcr, vcr_cassette_library_dir: "test/support/vcr_cassettes"

# config :platform, :speech_api, Platform.Speech.AWS.Polly

config :goth,
  json:
    ~S[{ "type": "", "project_id": "", "private_key_id": "", "private_key": "", "client_email": "", "client_id": "", "auth_uri": "https://accounts.google.com/o/oauth2/auth", "token_uri": "https://accounts.google.com/o/oauth2/token", "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs", "client_x509_cert_url": "" }]

config :platform, :speech_api, Platform.Speech.Mock.SpeechApi

config :platform, VideoConverter, adapter: VideoConverter.TestAdapter

config :platform, FileHelper, adapter: FileHelper.FileSystemTestAdapter

config :platform, Platform.SlideAPI, adapter: Platform.SlidesAPIMock

config :platform, Platform.Accounts.UserFromAuth, adapter: Platform.Accounts.UserFromAuthMock
