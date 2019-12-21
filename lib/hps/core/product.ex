defmodule HPS.Core.Product do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias HPS.Core.Package

  schema "products" do
    field(:name, :string)
    field(:namespace, :string, default: "default")
    field(:title, :string)

    has_many(:packages, Package)
    has_many(:online_packages, Package, where: [online: true])
    has_many(:offline_packages, Package, where: [online: false])

    timestamps()
  end

  @doc false
  def create_changeset(product, attrs) do
    product
    |> cast(attrs, [:namespace, :name, :title])
    |> validate_required([:namespace, :name])
    |> unsafe_validate_unique([:namespace, :name], HPS.Repo)
  end

  @doc false
  def update_changeset(product, attrs) do
    product
    |> cast(attrs, [:title])
    |> validate_required([:namespace, :name])
  end
end
