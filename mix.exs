defmodule XAMSRouter.Mixfile do
  use Mix.Project

  def project do
    [app: :xams_router,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:lager,
                          :logger,
                          :p1_utils],
     mod: {XAMSRouter.Supervisor, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:romeo, "~> 0.7"}, # For the XMPP connector.
     {:emqttc, github: "emqtt/emqttc"}, # For connecting to MQTT broker.
     {:exirc, github: "bitwalker/exirc"}, # For the IRC connector.
     {:poison, "~> 3.0"}, # For encoding/decoding JSON.
     {:msgpax, "~> 2.0"}, # For encoding/decoding MsgPack.
     {:distillery, "~> 1.4", runtime: false, warn_missing: false}, # For deployment.
     {:edeliver, "~> 1.4.3"}] # For deployment.
  end
end
