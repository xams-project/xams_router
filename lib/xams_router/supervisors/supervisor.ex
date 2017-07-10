defmodule XAMS.Supervisors.Supervisor do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    xamsTopics = Application.get_env(:xams,
      :topics)

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: XAMS.Worker.start_link(arg1, arg2, arg3)
      # worker(XAMS.Worker, [arg1, arg2, arg3]),
      worker(XAMS.Inputs.MQTT, [xamsTopics])]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XAMS.Supervisor,
            max_restarts: 45,
            max_seconds: 10]
    Supervisor.start_link(children, opts)
  end
end
