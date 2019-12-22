defmodule HPS.Core.Policy.Default do
  @moduledoc """
  This is the default policy for a rollout.

  When rolling out a package, it puts the package online, and
  put all other online packages of the product offline.
  """

  alias HPS.Core.{Package, Rollout}
  alias HPS.Core
  alias HPS.Repo
  alias Ecto.Changeset

  @doc """
  Rollout up strategy handlers
  """

  @spec up_strategy(Rollout.t()) :: {Policy.handler(), Policy.handler(), Policy.handler()}

  def up_strategy(%Rollout{package: %Package{}} = rollout) do
    {&insert/1, &up_strategy_standout/1, &up_strategy_drawback/1}
  end

  def down_strategy(%Rollout{package: %Package{}} = rollout) do
    {&del/1, &down_strategy_standout/1, &down_strategy_drawback/1}
  end

  defp insert(rollout) do
    Rollout.create_changeset(rollout, %{})
    |> Changeset.put_change(:status, "done")
    |> Changeset.put_change(:progress, 1.0)
    |> Changeset.put_change(:done_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.insert!()
  end

  defp up_strategy_standout(%{package: package}) do
    Package.online_status_changeset(package, %{online: true})
    |> Repo.update!()
  end

  defp up_strategy_drawback(%{previous_version: nil}), do: :ok

  defp up_strategy_drawback(%{product_id: product_id, previous_version: prev_ver}) do
    Core.get_package_by_version!(product_id, prev_ver)
    |> Package.online_status_changeset(%{online: false})
    |> Repo.update!()
  end

  defp del(rollout), do: Repo.delete!(rollout)

  defp down_strategy_standout(%{previous_version: nil}), do: :ok

  defp down_strategy_standout(%{product_id: product_id, previous_version: version}) do
    Core.get_package_by_version!(product_id, version)
    |> Package.online_status_changeset(%{online: true})
    |> Repo.update!()
  end

  defp down_strategy_drawback(%{package: %Package{} = package}) do
    package
    |> Package.online_status_changeset(%{online: false})
    |> Repo.update!()
  end
end
