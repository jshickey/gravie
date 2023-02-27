defmodule Gravie.Rentals do
  @moduledoc """
  The Rentals context.
  """

  import Ecto.Query, warn: false
  alias Gravie.Repo

  alias Gravie.Rentals.Rental

  @doc """
  Returns the list of rentals.

  ## Examples

      iex> list_rentals()
      [%Rental{}, ...]

  """
  def list_rentals do
    Repo.all(Rental)
  end

  @doc """
  Gets a single rental.

  Raises `Ecto.NoResultsError` if the Rental does not exist.

  ## Examples

      iex> get_rental!(123)
      %Rental{}

      iex> get_rental!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rental!(id), do: Repo.get!(Rental, id)

  @doc """
  Creates a rental.

  ## Examples

      iex> create_rental(%{field: value})
      {:ok, %Rental{}}

      iex> create_rental(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rental(attrs \\ %{}) do
    %Rental{}
    |> Rental.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rental.

  ## Examples

      iex> update_rental(rental, %{field: new_value})
      {:ok, %Rental{}}

      iex> update_rental(rental, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rental(%Rental{} = rental, attrs) do
    rental
    |> Rental.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rental.

  ## Examples

      iex> delete_rental(rental)
      {:ok, %Rental{}}

      iex> delete_rental(rental)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rental(%Rental{} = rental) do
    Repo.delete(rental)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rental changes.

  ## Examples

      iex> change_rental(rental)
      %Ecto.Changeset{data: %Rental{}}

  """
  def change_rental(%Rental{} = rental, attrs \\ %{}) do
    Rental.changeset(rental, attrs)
  end
end
