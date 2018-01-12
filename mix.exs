defmodule Gandalf.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/pragmaticivan/gandalf"

  def project do
    [
      app: :gandalf,
      description: description(),
      aliases: aliases(),
      package: package(),
      version: @version,
      elixir: "> 1.5.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [gandalf: :test, "coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test, "coveralls.json": :test],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_deps: :transitive,
                 plt_add_apps: [:mix],
                 flags: [:race_conditions, :no_opaque],
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Gandalf, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:plug, "~> 1.3"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:secure_random, "~> 0.5.1"},
      {:poison, "~> 3.1"},
      {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false},
      {:postgrex, "~> 0.13.3", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 0.8.10", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.1", only: :test},
      {:excoveralls, "~> 0.8", only: :test}
    ]
  end

  defp aliases do
    [
      test: [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "gandalf.gen.migration",
        "ecto.migrate",
        "test"
      ],
      "coveralls.json": [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "gandalf.gen.migration",
        "ecto.migrate",
        "coveralls.json"
      ]
    ]
  end

  defp description do
    """
    A Oauth2 plug based provider.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: [
        "lib",
        "CHANGELOG.md",
        "LICENSE",
        "mix.exs",
        "README.md",
        "priv/templates"
      ],
      maintainers: ["Ivan Santos"]
    ]
  end
end
