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
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:path, :digest, :size])
    |> validate_required([:path, :digest, :size])
  end
end
