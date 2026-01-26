defmodule Deps.MixProject do
  use Mix.Project

  def project do
    [
      app: :mftester,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: [
        {:microformats2, "~> 1.0.0"},
        {:json, "~> 1.4"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
