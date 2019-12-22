defmodule HPS.Core.Package do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias HPS.Core.{Product, File, Rollout}
  alias Hyder.Util.Zip

  schema "packages" do
    field(:version, :string)
    field(:archive, :binary, virtual: true)
    field(:online, :boolean, default: false)

    belongs_to(:product, Product)
    has_many(:files, File, on_delete: :delete_all, on_replace: :delete)
    has_one(:rollout, Rollout, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def create_changeset(package, attrs) do
    package
    |> cast(attrs, [:version, :product_id])
    |> validate_required([:version, :product_id])
    |> validate_change(:version, &validate_version/2)
    |> assoc_constraint(:product)
    |> unsafe_validate_unique([:version, :product_id], HPS.Repo)
  end

  defp validate_version(:version, version) do
    case Version.parse(version) do
      :error ->
        [version: "is invalid"]

      _ ->
        []
    end
  end

  @doc false
  def update_changeset(package, attrs) do
    package
    |> cast(attrs, [:archive])
    |> validate_required([:archive])
    |> auto_build_files()
  end

  @doc false
  def online_status_changeset(package, attrs) do
    package
    |> cast(attrs, [:online])
    |> validate_required([:online])
  end

  defp auto_build_files(%{valid?: true, changes: %{archive: archive}} = changeset) do
    files =
      archive
      |> Zip.zip_entries(struct: Map)
      |> Enum.map(fn file ->
        File.create_changeset(%File{}, Map.put(file, :package_id, changeset.data.id))
      end)

    changeset |> put_assoc(:files, files)
  end

  defp auto_build_files(changeset), do: changeset
end
