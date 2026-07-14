defmodule FulfillmentPipeline.Carriers do
  @moduledoc """
  The Carriers context.
  """

  import Ecto.Query, warn: false
  alias FulfillmentPipeline.Repo

  alias FulfillmentPipeline.Carriers.Carrier

  @doc """
  Returns the list of carriers.

  ## Examples

      iex> list_carriers()
      [%Carrier{}, ...]

  """
  def list_carriers do
    Repo.all(Carrier)
  end

  @doc """
  Gets a single carrier.

  Raises `Ecto.NoResultsError` if the Carrier does not exist.

  ## Examples

      iex> get_carrier!(123)
      %Carrier{}

      iex> get_carrier!(456)
      ** (Ecto.NoResultsError)

  """
  def get_carrier!(id), do: Repo.get!(Carrier, id)

  @doc """
  Creates a carrier.

  ## Examples

      iex> create_carrier(%{field: value})
      {:ok, %Carrier{}}

      iex> create_carrier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_carrier(attrs) do
    %Carrier{}
    |> Carrier.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a carrier.

  ## Examples

      iex> update_carrier(carrier, %{field: new_value})
      {:ok, %Carrier{}}

      iex> update_carrier(carrier, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_carrier(%Carrier{} = carrier, attrs) do
    carrier
    |> Carrier.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a carrier.

  ## Examples

      iex> delete_carrier(carrier)
      {:ok, %Carrier{}}

      iex> delete_carrier(carrier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_carrier(%Carrier{} = carrier) do
    Repo.delete(carrier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking carrier changes.

  ## Examples

      iex> change_carrier(carrier)
      %Ecto.Changeset{data: %Carrier{}}

  """
  def change_carrier(%Carrier{} = carrier, attrs \\ %{}) do
    Carrier.changeset(carrier, attrs)
  end
end
