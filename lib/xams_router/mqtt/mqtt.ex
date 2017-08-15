defmodule XAMSRouter.MQTT.MQTT do
  require Logger
  use GenServer

  def start_link(topics) do
    GenServer.start_link(__MODULE__, topics, name: __MODULE__)
  end
  
  def init(topics) do
    app_env = Application.get_env(:xams, :mqtt)
    host = app_env[:host]
    port = app_env[:port]
    ssl? = app_env[:ssl?]
    client_id = app_env[:client_id]
    username = app_env[:username]
    password = app_env[:password]

    {:ok, conn} = if ssl? do
      Logger.debug("Connecting with SSL.")
      :emqttc.start_link([{:host, host},
                          {:port, port},
                          :ssl,
                          {:username, username},
                          {:password, password},
                          {:client_id, client_id}])
    else
      Logger.debug("Connecting without SSL.")
      :emqttc.start_link([{:host, host},
                          {:port, port},
                          {:username, username},
                          {:password, password},
                          {:client_id, client_id}])
    end

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
    
    payload = Poison.decode!(payload)
    
    device_uuid = get_in(payload,
      ["identity",
       "deviceUUID"])

    Logger.debug("Router received a payload from device (UUID) -> #{device_uuid}")
    {:noreply, state}
  end
end
