defmodule QbProxy.Repo.Migrations.AddTokensTable do
  use Ecto.Migration

  def change do
    create table(:tokens, primary_key: false) do
      add :key, :text
      add :value, :text
    end
  end
end
