defmodule Gravie.RentalsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gravie.Rentals` context.
  """

  @doc """
  Generate a rental.
  """
  def rental_fixture(attrs \\ %{}) do
    {:ok, rental} =
      attrs
      |> Enum.into(%{
        email: "some email",
        game_guid: "some game_guid"
      })
      |> Gravie.Rentals.create_rental()

    rental
  end
end
