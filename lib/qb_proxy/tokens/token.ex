defmodule QbProxy.Tokens.Token do
  use Ecto.Schema

  @primary_key false
  schema "tokens" do
    field :id, :id, primary_key: true
    field :key, :string
    field :value, :string
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> Ecto.Changeset.cast(attrs, [:key, :value])
    |> Ecto.Changeset.validate_required([:key, :value])
  end
end
