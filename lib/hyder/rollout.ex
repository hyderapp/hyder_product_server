defmodule Hyder.Rollout do
  @moduledoc """
  Hyder Rollout represents the concept of the releasing processes.

  In order to make a package available to users, you need to build
  a rollout for the package. When the rollout is finished, the package
  will be added to product's packages list.

  Rollout is initialized with a progress of `0`. When progress reaches
  `1`, the releaseing progress is then finished.

  There are different status of a rollout:

  * `ready` - the rollout is initialized, ready to deploy;
  * `active` - the rollout is being deployed, but not finished;
  * `done` - the rollout is fully deployed to all users.

  A package can have one rollout at most. When the rollout's progress
  reaches 1.0, it get elected as the official rollout of the product.
  Meanwhile the package takes place, replacing former official package.
  In the end, the rollout's status becomes `:done`.
  """

  defstruct status: :ready, progress: 0, policy: :default, product: nil, package: nil

  alias Hyder.{Product, Package}

  @type t :: map()
  @type policy :: :default | :progressive

  @doc """
  Create a rollout from product and package.
  """
  @spec create(Product.t(), Package.t(), policy()) :: t()
  def create(product, package, policy \\ :default) do
    %__MODULE__{product: product, package: package, policy: policy}
  end

  @doc """
  Publish a rollout, releasing it to production environment.
  Publishing means to push the package online for users to
  download and use, and it will NOT cause other online packages
  offline.
  """
  @spec publish(t()) :: t()
  def publish(rollout), do: %{rollout | status: :active}

  @doc """
  Elect a rollout, make the package it bound as the ONLY online
  package of the prouct. It will cause any other onlne packages
  going offline.
  """
  def elect(rollout), do: %{rollout | status: :done}

  def update_progress(%{progress: p}, progress) when progress <= p do
    {:error, :rollouts_never_go_back}
  end

  def update_progress(rollout, progress) do
    {:ok, Map.put(rollout, :progress, progress |> max(1.0) |> min(0))}
  end
end
