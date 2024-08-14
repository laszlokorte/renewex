defmodule Renewex.MixProject do
  use Mix.Project

  def project do
    [
      app: :renewex,
      version: "0.4.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/laszlokorte/renewex",
      homepage_url: "https://github.com/laszlokorte/renewex",
      docs: [
        # The main page in the docs
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, "~> 0.34.0", only: :dev, runtime: false}]
  end

  defp description() do
    "A parser for Renew files (*.rnw) written in Elixir."
  end

  defp package() do
    [
      name: "renewex",
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/laszlokorte/renewex",
        "Renew" => "http://www.renew.de"
      }
    ]
  end
end
