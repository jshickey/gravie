defmodule Gravie.RentalsTest do
  use Gravie.DataCase

  alias Gravie.Rentals

  describe "rentals" do
    alias Gravie.Rentals.Rental

    import Gravie.RentalsFixtures

    @invalid_attrs %{email: nil, game_guid: nil}

    test "list_rentals/0 returns all rentals" do
      rental = rental_fixture()
      assert Rentals.list_rentals() == [rental]
    end

    test "get_rental!/1 returns the rental with given id" do
      rental = rental_fixture()
      assert Rentals.get_rental!(rental.id) == rental
    end

    test "create_rental/1 with valid data creates a rental" do
      valid_attrs = %{email: "some email", game_guid: "some game_guid"}

      assert {:ok, %Rental{} = rental} = Rentals.create_rental(valid_attrs)
      assert rental.email == "some email"
      assert rental.game_guid == "some game_guid"
    end

    test "create_rental/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rentals.create_rental(@invalid_attrs)
    end

    test "update_rental/2 with valid data updates the rental" do
      rental = rental_fixture()
      update_attrs = %{email: "some updated email", game_guid: "some updated game_guid"}

      assert {:ok, %Rental{} = rental} = Rentals.update_rental(rental, update_attrs)
      assert rental.email == "some updated email"
      assert rental.game_guid == "some updated game_guid"
    end

    test "update_rental/2 with invalid data returns error changeset" do
      rental = rental_fixture()
      assert {:error, %Ecto.Changeset{}} = Rentals.update_rental(rental, @invalid_attrs)
      assert rental == Rentals.get_rental!(rental.id)
    end

    test "delete_rental/1 deletes the rental" do
      rental = rental_fixture()
      assert {:ok, %Rental{}} = Rentals.delete_rental(rental)
      assert_raise Ecto.NoResultsError, fn -> Rentals.get_rental!(rental.id) end
    end

    test "change_rental/1 returns a rental changeset" do
      rental = rental_fixture()
      assert %Ecto.Changeset{} = Rentals.change_rental(rental)
    end
  end
end
