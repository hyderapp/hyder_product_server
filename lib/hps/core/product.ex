defmodule HPS.Core.Product do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias HPS.Core.{Package, Rollout}

  schema "products" do
    field(:name, :string)
    field(:namespace, :string, default: "default")
    field(:title, :string)

    has_many(:packages, Package)
    has_many(:online_packages, Package, where: [online: true])
    has_many(:offline_packages, Package, where: [online: false])

    has_many(:rollouts, Rollout)
    has_many(:done_rollouts, Rollout, where: [status: "done"])

    has_many(:rolled_packages, through: [:rollouts, :package])

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

  def to_hyder_struct(%__MODULE__{} = product) do
    Map.from_struct(product)
    |> Map.take([:name, :namespace, :title, :packages])
    |> Map.update!(:packages, fn packages ->
      Enum.map(packages, &HPS.Core.Package.to_hyder_struct/1)
    end)
    |> Hyder.Product.__struct__()
  end
end
