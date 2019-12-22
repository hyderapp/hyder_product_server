defmodule HPS.Core.File do
  @moduledoc false

  @derive {Jason.Encoder, only: [:digest, :path, :size]}

  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field(:digest, :string)
    field(:path, :string)
    field(:size, :integer)

    belongs_to(:package, HPS.Core.Package)

    timestamps()
  end

  @doc false
  def create_changeset(file, attrs) do
    file
    |> cast(attrs, [:path, :digest, :size, :package_id])
    |> cast_assoc(:package)
    |> validate_required([:path, :digest, :size, :package_id])
  end

  def to_hyder_struct(%__MODULE__{} = file) do
    Map.from_struct(file)
    |> Map.take([:digest, :path, :size])
    |> Hyder.File.__struct__()
  end
end
