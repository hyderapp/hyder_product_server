defmodule HPS.Core.Package do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias HPS.Core.Product

  schema "packages" do
    field(:version, :string)

    belongs_to(:product, Product)
    has_many(:files, HPS.Core.File)

    timestamps()
  end

  @doc false
  def create_changeset(package, attrs) do
    package
    |> cast(attrs, [:version, :product_id])
    |> validate_required([:version, :product_id])
    |> validate_format(:version, ~r/^\d\S*$/)
    |> unsafe_validate_unique([:version, :product_id], HPS.Repo)
  end
end
