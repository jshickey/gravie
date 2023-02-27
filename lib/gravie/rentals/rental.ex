defmodule Gravie.Rentals.Rental do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rentals" do
    field :email, :string
    field :game_guid, :string

    timestamps()
  end

  @doc false
  def changeset(rental, attrs) do
    rental
    |> cast(attrs, [:email, :game_guid])
    |> validate_required([:email, :game_guid])
  end
end
