defmodule ActorModel.MixProject do
  use Mix.Project

  def project do
    [
      app: :actor_model,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:eventsource_ex, "~> 0.0.2"},
    ]
  end
end
