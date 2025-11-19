defmodule Demand.MixProject do
  use Mix.Project

  @description """
  A prompt library for Elixir. Port of [demand](https://github.com/jdx/demand).
  """
  @github "https://github.com/gmcabrita/demand"
  def project do
    [
      app: :demand,
      source_url: @github,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs() do
    [
      main: "readme",
      logo: nil,
      extras: ["README.md"]
    ]
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Gonçalo Mendes Cabrita"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
