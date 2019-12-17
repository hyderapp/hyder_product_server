defmodule HPS.Core.Product do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field(:name, :string)
    field(:namespace, :string)
    field(:title, :string)

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:namespace, :name, :title])
    |> validate_required([:name])
  end
end
