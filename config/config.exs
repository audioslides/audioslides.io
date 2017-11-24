# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :platform, PlatformWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "M0u6S1m6QRfB7QoFROf6g5PT4nZ8uxATtlb6qZLtjHM6Lezb/Iv5j0ei0/3cLx2M",
  render_errors: [view: PlatformWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Platform.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :platform,
  ecto_repos: [Platform.Repo]

config :platform, :speech_api, Platform.Speech.AWS.Polly

config :platform, :content_dir, "priv/static/content/"

  # Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :platform, Platform.VideoConverter,
  adapter: Platform.VideoConverter.FFMpegAdapter

config :platform,   Platform.FileHelper,
  adapter: Platform.FileHelper.FileSystemAdapter

config :platform,   Platform.SlideAPI,
  adapter: Platform.GoogleSlidesAPI

config :goth, json: System.get_env("AS_GOOGLE_GCP_CREDENTIALS")

config :platform, :aws,
  access_key_id: System.get_env("AS_AWS_ACCESS_KEY_ID"),
  secret: System.get_env("AS_AWS_SECRET")
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

import_config "#{Mix.env}.exs"
