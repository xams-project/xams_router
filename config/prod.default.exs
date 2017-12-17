use Mix.Config

config :xams_router, :mqtt,
  topics: ["xams/#"],
  host: "mqtt.example.net",
  port: 8883,
  ssl?: true,
  username: "xams",
  password: "passw0rd"
