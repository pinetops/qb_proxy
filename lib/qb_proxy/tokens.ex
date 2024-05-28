defmodule QbProxy.Tokens do
  @moduledoc """
  This module provides functions to interact with tokens.
  """

  alias QbProxy.Repo
  alias QbProxy.Tokens.Token

  @doc """
  Creates a token with the given attributes.

  ## Examples

      iex> create_token(%{key: "example_key", value: "example_value"})
      {:ok, %Token{}}

      iex> create_token(%{key: nil, value: "example_value"})
      {:error, %Ecto.Changeset{}}

  """
  def create_token(attrs \\ %{}) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a token with the given key and value.

  ## Examples

      iex> upsert_token("example_key", "new_value")
      {:ok, %Token{}}

      iex> upsert_token("example_key", "new_value")
      {:ok, %Token{}}

  """
  def upsert_token(key, value) do
    case Repo.get_by(Token, key: key) do
      nil ->
        %Token{}
        |> Token.changeset(%{key: key, value: value})
        |> Repo.insert!()

      %Token{} = token ->
        token
        |> Token.changeset(%{value: value})
        |> Repo.update!()
    end
  end

  @doc """
  Deletes a token.

  ## Examples

      iex> delete_token(token)
      {:ok, %Token{}}

      iex> delete_token(token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_token(%Token{} = token) do
    Repo.delete(token)
  end

  @doc """
  Returns a list of all tokens.

  ## Examples

      iex> list_tokens()
      [%Token{}, ...]

  """
  def list_tokens do
    Repo.all(Token)
  end

  @doc """
  Gets the value of a single token by its key.

  Returns the value as a string if the Token exists, or nil if it does not.

  ## Examples

      iex> get_token_value("example_key")
      "some_value"

      iex> get_token_value("nonexistent_key")
      nil

  """
  def get_token_value(key) do
    case Repo.get_by(Token, key: key) do
      nil -> nil
      %Token{value: value} -> value
    end
  end
end
