defmodule XAMS.Inputs.MQTT do
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_argv) do
    Process.register(self(), :testclient)
    
    {:ok, pid} = Exmqttc.start_link(Exmqtt.Testclient, [name: :xams],
      host: '127.0.0.1')
    
    Exmqttc.subscribe(:xams, "xams/#")
    {:ok, pid}
  end
  
  def handle_info(:connected, state) do
    Logger.info("Connected to MQTT broker.")
    {:noreply, state}
  end
  def handle_info({:publish, topic, msg}, state) do
    Logger.debug("Received message on Topic: #{topic}")
    Logger.debug("Message: #{msg}")
    msg = Poison.decode!(msg)
    cver = msg |> get_in(["xams",
                          "client",
                          "version"]) # Client version.

    Logger.error("Client version: #{cver}")
    {:noreply, state}
  end
  def handle_info(:disconnected, state) do
    Logger.error("Disconnected from MQTT broker.")
    {:noreply, state}
  end
  
end
