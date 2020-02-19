defmodule HPS.Repo do
  use Ecto.Repo,
    otp_app: :hps,
    adapter: Ecto.Adapters.Postgres
end
