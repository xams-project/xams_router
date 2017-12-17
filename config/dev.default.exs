use Mix.Config

config :xams_router, :mqtt,
  topics: ["xams/#"],
  host: "localhost",
  port: 1883,
  ssl?: false,
  username: "xams",
  password: "passw0rd"
