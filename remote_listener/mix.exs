defmodule ActorModel.MixProject do
  use Mix.Project

  def project do
    [
      app: :remote_listener,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {RemoteListener, []}
    ]
  end

  defp deps do
    [
      {:eventsource_ex, "~> 0.0.2"},
      {:json, "~> 1.2"},
      {:elixir_xml_to_map, "~> 1.0.1"},
      {:poison, "~> 3.1"}
    ]
  end
end
