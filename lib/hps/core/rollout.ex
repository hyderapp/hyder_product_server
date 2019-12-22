defmodule HPS.Core.Rollout do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias HPS.Core.{Product, Package}
  alias HPS.Repo

  schema "rollouts" do
    field(:policy, :string, default: "default")
    field(:progress, :float, default: 0.0)
    field(:status, :string, default: "ready")
    field(:target_version, :string)
    field(:previous_version, :string)
    field(:done_at, :utc_datetime)

    belongs_to(:product, Product)
    belongs_to(:package, Package)

    timestamps()
  end

  @doc false
  def create_changeset(rollout, attrs) do
    rollout
    |> cast(attrs, [
      :policy,
      :product_id,
      :package_id,
      :target_version,
      :previous_version
    ])
    |> validate_required([:policy, :progress, :product_id, :package_id, :target_version])
    |> unsafe_validate_unique(:package_id, Repo, message: "each package can have only one rollout")
    |> unsafe_validate_unique([:product_id, :target_version], Repo,
      message: "a product can have only one rollout of specific version"
    )
  end

  @doc false
  def update_changeset(rollout, attrs) do
    only_forward = fn :progress, p ->
      if p <= rollout.progress do
        [
          progress:
            "can only be increased, if you want to decrease it, you may want to use rollback changeset instead"
        ]
      else
        []
      end
    end

    rollout
    |> Repo.preload([:product, :package])
    |> cast(attrs, [:progress])
    |> validate_required([:progress])
    |> validate_number(:progress, less_than_or_equal_to: 1.0, greater_than_or_equal_to: 0.0)
    |> validate_change(:progress, only_forward)
    |> update_package()
    |> update_status()
  end

  defp update_package(%{valid?: true, changes: %{progress: p}} = changeset) do
    changeset
    |> put_assoc(
      :package,
      Package.online_status_changeset(changeset.data.package, %{online: p > 0.0})
    )
  end

  defp update_package(changeset), do: changeset

  defp update_status(%{valid?: true, changes: %{progress: 1.0}} = changeset) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    changeset
    |> put_change(:status, "done")
    |> put_change(:done_at, now)
  end

  defp update_status(%{valid?: true} = changeset) do
    changeset
    |> put_change(:status, "active")
  end

  defp update_status(changeset), do: changeset

  @doc false
  def rollback_changeset(rollout) do
    rollout
    |> Repo.preload(:package)
    |> cast(%{}, [])
    |> put_change(:status, "rollback")
    |> put_change(:progress, 0.0)
    |> update_package()
  end
end
