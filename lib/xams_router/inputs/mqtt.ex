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
    c_ver = msg |> get_in(["xams",
                           "client",
                           "version"]) # XAMS client version.
    c_uuid = msg |> get_in(["xams",
                            "client",
                            "uuid"]) # XAMS client UUID.

    Logger.debug("Client (UUID: #{c_uuid}) interacted with us...")
    Logger.debug("Client version: #{c_ver}")
    {:noreply, state}
  end
  def handle_info(:disconnected, state) do
    Logger.error("Disconnected from MQTT broker.")
    {:noreply, state}
  end
end
