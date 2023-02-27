defmodule Gravie.Repo.Migrations.CreateRentals do
  use Ecto.Migration

  def change do
    create table(:rentals) do
      add :email, :string
      add :game_guid, :string

      timestamps()
    end
  end
end
