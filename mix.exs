defmodule Gandalf.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/pragmaticivan/gandalf"

  def project do
    [
      app: :gandalf,
      description: description(),
      aliases: aliases(),
      package: package(),
      version: @version,
      elixir: "~> 1.6-dev",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [gandalf: :test],
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
      {:postgrex, "~> 0.13", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [test: ["ecto.drop --quiet", "ecto.create --quiet", "gandalf.db.gen.migration", "ecto.migrate", "test"]]
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
