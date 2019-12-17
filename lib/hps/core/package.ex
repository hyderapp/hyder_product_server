defmodule HPS.Core.Package do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias HPS.Core.Product

  schema "packages" do
    field(:version, :string)
    belongs_to(:product, Product)

    timestamps()
  end

  @doc false
  def create_changeset(package, attrs) do
    package
    |> cast(attrs, [:version])
    |> validate_required([:version])
  end
end
