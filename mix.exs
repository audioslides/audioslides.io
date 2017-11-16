defmodule Platform.Mixfile do
  use Mix.Project

  def project do
    [
      app: :platform,
      aliases: aliases(),
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "test.integration": :test,
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.semaphore": :test,
        "vcr": :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Platform.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ecto, "~> 2.2.2"},
      {:excoveralls, "~> 0.7", only: :test},
      {:exvcr, "~> 0.9", only: :test},
      {:mix_test_watch, "~> 0.3", only: :dev},
      {:google_api_slides, "~> 0.0.1"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_ecto, "~> 3.3.0"},
      {:mariaex, "~> 0.8.1"},
      {:gettext, "~> 0.11"},
      {:goth, "~> 0.7.0"},
      {:cowboy, "~> 1.0"},
      {:aws_auth, "~> 0.7.1"},
      {:httpoison, "~> 0.13"},
      {:ueberauth_google, "~> 0.5"},
      {:ueberauth, "~> 0.4"},
      {:ex_machina, "~> 2.1", only: :test},
      {:mock, "~> 0.3.1", only: :test}
    ]
  end

  defp aliases do
    [
      "credo": "credo --strict",
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "phx.server": ["ecto.migrate", "phx.server"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"],
      "s": ["phx.server"],
      "t": ["test.watch"],
      "test.integration": ["test --include integration:true"]
    ]
  end
end
