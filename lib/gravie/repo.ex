defmodule Gravie.Repo do
  use Ecto.Repo,
    otp_app: :gravie,
    adapter: Ecto.Adapters.Postgres
end
