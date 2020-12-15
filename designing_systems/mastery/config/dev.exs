import Config

config :mastery_persistence, MasteryPersistence.Repo,
  database: "mastery_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true

config :mastery, :persistence_fn, &MasteryPersistence.record_response/2
