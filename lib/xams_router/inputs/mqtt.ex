defmodule XAMS.Inputs.MQTT do
  require Logger
  use GenServer

  @name __MODULE__

  def start_link(topics) do
    GenServer.start_link(@name, topics, name: @name)
  end

  def init(topics) do
    {:ok, conn} = :emqttc.start_link(host: '127.0.0.1',
      logger: :error)
    
    Logger.info("MQTT client now attempting to connect to broker.")
    {:ok, %{conn: conn,
           topics: topics}}
  end

  def handle_info({:mqttc, conn, :connected}, %{conn: conn,
                                                topics: topics} = state) do
    Logger.info("Success. MQTT client connected!")

    # Map over topic list and subscribe.
    # Stock configuration is `["xams/#"], which subscribes to *all*
    # topics under that namespace.
    Enum.map(topics, fn (t) ->
      Logger.debug("Router about to subscribe to topic -> #{t}")
      :emqttc.subscribe(conn, t, :qos0)
      Logger.debug("Router now subscribed to topic -> #{t}")
    end)

    Logger.info("Finished subscribing phase.")
    {:noreply, state}
  end
  def handle_info({:mqttc, conn, :disconnected}, %{conn: conn,
                                                   topics: _topics} = state) do
    Logger.info("MQTT client disconnected. Network failure?")
    {:noreply, state}
  end
  def handle_info({:publish, topic, payload}, %{conn: _conn,
                                                topics: _topics} = state) do

    Logger.debug("Received a new message from the broker.")
    Logger.debug("Topic -> #{topic}")
    Logger.debug("Payload -> #{payload}")

    json_body = Poison.decode!(payload)

    device_uuid = get_in(json_body,
      ["identity",
       "uuid"])
    
    Logger.debug("Router received a CONNREQ from a device.\nDevice UUID -> #{device_uuid}")

    {:noreply, state}
  end
end
