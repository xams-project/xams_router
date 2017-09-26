defmodule XAMSRouter.MQTT.Client do
  require Logger
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    app_env = Application.get_env(:xams, :mqtt)
    host = to_charlist(app_env[:host])
    port = app_env[:port]
    ssl? = app_env[:ssl?]

    username = app_env[:username]
    password = app_env[:password]
    client_id = app_env[:client_id]
    topics = app_env[:topics]

    clean_sess = app_env[:clean_sess]
    logger_lvl = app_env[:logger_lvl]

    mqtt_opts = [
      host: host,
      port: port,
      client_id: client_id,
      logger: logger_lvl,
      clean_sess: clean_sess,
      username: username,
      password: password]

    Logger.info("MQTT client now connecting to broker.")

    {:ok, conn} = if ssl? do
      mqtt_opts = [:ssl | mqtt_opts]
      Logger.debug("Connecting with SSL.", [server: host])
      :emqttc.start_link(mqtt_opts)
    else
      Logger.debug("Connecting without SSL.", [server: host])
      :emqttc.start_link(mqtt_opts)
    end

    {:ok, %{conn: conn,
            topics: topics}}
  end

  def handle_info({:mqttc, conn, :connected}, %{conn: conn,
                                                topics: topics} = state) do
    Logger.info("Success. MQTT client connected.")

    Logger.debug("Begin subscribing phase.")
    # Map over topic list and subscribe.
    # Stock configuration is `["xams/#"], which subscribes to *all*
    # topics nested under that topic
    Enum.map(topics, fn (t) ->
      Logger.debug("Router about to subscribe to topic -> #{t}")
      :emqttc.subscribe(conn, t, 2)
      Logger.debug("Router now subscribed to topic -> #{t}")
    end)

    Logger.debug("Finished subscribing phase.")
    {:noreply, state}
  end
  def handle_info({:mqttc, conn, :disconnected}, %{conn: conn,
                                                   topics: _topics} = state) do
    Logger.warn("MQTT client lost connection! Reviving client...")
    {:noreply, state}
  end
  def handle_info({:publish, topic, payload}, %{conn: _conn,
                                                topics: _topics} = state) do
    Logger.debug("Received a new message from the broker.")
    Logger.debug("Topic -> #{topic}")
    Logger.debug("Payload -> #{payload}")
    {:noreply, state}
  end

  def terminate(_reason, pid) do
    Logger.error("MQTT client terminating... something went wrong!")
    :emqttc.disconnect(pid)
  end
end
