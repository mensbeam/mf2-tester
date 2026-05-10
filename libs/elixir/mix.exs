defmodule MicroformatsTester.MixProject do
  use Mix.Project

  def project do
    [
      app: :testone,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      escript: [
        main_module: MicroformatsTester,
        path: "./test-one"
        ],
      deps: [
        {:microformats2, "~> 1.0.0"},
        {:json, "~> 1.4"}
      ]
    ]
  end
end
