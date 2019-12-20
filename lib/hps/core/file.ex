defmodule HPS.Core.File do
  @moduledoc false

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
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:path, :digest, :size])
    |> validate_required([:path, :digest, :size])
  end
end
