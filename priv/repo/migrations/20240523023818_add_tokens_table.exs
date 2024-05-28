defmodule QbProxy.Repo.Migrations.AddTokensTable do
  use Ecto.Migration

  def change do
    create table(:tokens, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :key, :text
      add :value, :text
    end
  end
end
