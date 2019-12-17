# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hps,
  namespace: HPS,
  ecto_repos: [HPS.Repo]

# Configures the endpoint
config :hps, HPSWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zR4Tfs83YBxSVvpByH0wLhFSyhA9pAzYHbA5EdDMQhco6btKwcrqDFfcRZ0eYqJb",
  render_errors: [view: HPSWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HPS.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
