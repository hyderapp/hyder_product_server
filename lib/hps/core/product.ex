defmodule HPS.Core.Product do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field(:name, :string)
    field(:namespace, :string, default: "default")
    field(:title, :string)

    timestamps()
  end

  @doc false
  def create_changeset(product, attrs) do
    product
    |> cast(attrs, [:namespace, :name, :title])
    |> validate_required([:namespace, :name])
  end

  @doc false
  def update_changeset(product, attrs) do
    product
    |> cast(attrs, [:title])
    |> validate_required([:namespace, :name])
  end
end
