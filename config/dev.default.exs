use Mix.Config

config :xams, :mqtt,
  topics: ["xams/#"],
  host: "localhost",
  port: 1883,
  ssl?: false,
  username: "xams",
  password: "passw0rd"
