defmodule HPS.Core.Package do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias HPS.Core.{Product, File}

  schema "packages" do
    field(:version, :string)
    field(:archive, :binary, virtual: true)

    belongs_to(:product, Product)
    has_many(:files, File)

    timestamps()
  end

  @doc false
  def create_changeset(package, attrs) do
    package
    |> cast(attrs, [:version, :product_id, :archive])
    |> validate_required([:version, :product_id, :archive])
    |> validate_format(:version, ~r/^\d\S*$/)
    |> assoc_constraint(:product)
    |> unsafe_validate_unique([:version, :product_id], HPS.Repo)
    |> auto_build_files()
  end

  defp auto_build_files(%{valid?: true, changes: %{archive: archive}} = changeset),
    do: changeset |> put_assoc(:files, file_entries(archive))

  defp auto_build_files(changeset), do: changeset

  defp file_entries(archive) do
    archive
    |> Hyder.Util.Zip.zip_entries(struct: Map)
    |> Enum.map(&File.create_changeset/1)
  end
end
