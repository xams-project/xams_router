defmodule XAMSRouter.Supervisor do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    xamsTopics = Application.get_env(:xams,
     :mqtt)[:topics]

    # Define workers and child supervisors to be supervised
    children = [worker(XAMSRouter.MQTT.MQTT, [xamsTopics])]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XAMSRouter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
