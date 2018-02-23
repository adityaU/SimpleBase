# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
require IEx

# General application configuration
config :afterglow,
  namespace: AfterGlow,
  ecto_repos: [AfterGlow.Repo]

# Configures the endpoint
config :afterglow, AfterGlow.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Tn3BxHU8EtAfwHsjDlEk91rjB9OdR3gXZfzOhO4vfK1XbU14yZPNfWsZjaoUvCTD",
  render_errors: [view: AfterGlow.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AfterGlow.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ja_serializer,
  key_format: :underscored

config :oauth2,
  serializers: %{
    "application/vnd.api+json" => Poison,
    "application/json" => Poison,
    "application/xml" => MyApp.XmlParser,
  }
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

config :flasked,
  otp_app: :afterglow,
  map_file: "priv/env.exs"

import_config "#{Mix.env}.exs"
