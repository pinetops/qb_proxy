defmodule QbProxy.Repo do
  use Ecto.Repo,
    otp_app: :qb_proxy,
    adapter: Ecto.Adapters.Postgres
end
