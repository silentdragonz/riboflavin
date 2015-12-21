defmodule Riboflavin.Mixfile do
  use Mix.Project

  def project do
    [app: :riboflavin,
     description: "Backblaze B2 API for Elixir",
     version: "0.0.2",
     elixir: "~> 1.1",
     description: "Backblaze B2 client.",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison],
     mod: {Riboflavin, []},
     env: env]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 1.2"},
      {:httpoison, "~> 0.8.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README*"],
      maintainers: ["Garrett Johnson"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/silentdragonz/riboflavin"}]
  end

  defp env do
    [
      api_url: "https://api.backblaze.com/b2api/v1",
      account_id: System.get_env("B2_ACCOUNT_ID"),
      application_key: System.get_env("B2_APP_KEY")
    ]
  end
end
