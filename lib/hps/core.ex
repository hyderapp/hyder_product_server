defmodule HPS.Core do
  @moduledoc """
  Hyder Package Server.
  """

  alias HPS.Core.Product
  alias HPS.Core.Package
  alias HPS.Core.Policy
  alias HPS.Repo

  import Ecto.Query, only: [from: 2]

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products(namespace \\ "default")

  def list_products(namespace) do
    Repo.all(from(p in Product, where: p.namespace == ^namespace))
    |> Repo.preload(:online_packages)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  def get_product_by_name(name, namespace \\ "default", opts \\ [])

  def get_product_by_name(name, namespace, opts) do
    from(p in Product, where: p.namespace == ^namespace and p.name == ^name)
    |> Repo.one()
    |> Repo.preload(Keyword.get(opts, :preload, []))
    |> case do
      %Product{} = product ->
        {:ok, product}

      nil ->
        {:error, :not_found}
    end
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.create_changeset(attrs)
    |> Repo.insert()
    |> refresh_store()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{source: %Product{}}

  """
  def change_product(%Product{} = product) do
    Product.update_changeset(product, %{})
  end

  @doc """
  Returns the list of packages.

  ## Examples

      iex> list_packages(%Product{name: ..., id: ...})
      [%Package{}, ...]

  """
  def list_packages(%Product{} = product) do
    Repo.all(from(p in Package, where: p.product_id == ^product.id))
  end

  @doc """
  Gets a single package.

  Raises `Ecto.NoResultsError` if the Package does not exist.

  ## Examples

      iex> get_package!(123)
      %Package{}

      iex> get_package!(456)
      ** (Ecto.NoResultsError)

  """
  def get_package!(id), do: Repo.get!(Package, id)

  @doc """
  Get a package from a product by its version.
  """
  def get_package_by_version(_, nil), do: {:error, :not_found}

  def get_package_by_version(%Product{id: id}, version),
    do: get_package_by_version(id, version)

  def get_package_by_version(product_id, version) do
    Repo.one(from(p in Package, where: p.version == ^version and p.product_id == ^product_id))
    |> Repo.preload([:files])
    |> case do
      nil ->
        {:error, :not_found}

      %Package{} = package ->
        {:ok, package}
    end
  end

  @doc """
  Get a package from a product by its version.
  Raise an error if not found.
  """
  def get_package_by_version!(product, version) do
    get_package_by_version(product, version)
    |> case do
      {:ok, package} ->
        package

      {:error, reason} ->
        raise(reason)
    end
  end

  @doc """
  Create or update a package.
  """
  def create_or_update_package(product, attrs) do
    case create_package(product, attrs) do
      {:ok, %Package{} = _package} ->
        update_package(product, attrs)

      {:error, %Ecto.Changeset{} = changeset} ->
        if version_conflict?(changeset) do
          update_package(product, attrs)
        else
          {:error, changeset}
        end

      other ->
        other
    end
  end

  defp version_conflict?(%{errors: errors}) when is_list(errors) do
    match?(
      {"has already been taken", _},
      Keyword.get(errors, :version)
    )
  end

  defp version_conflict?(_), do: false

  defp create_package(_product, attrs) do
    %Package{}
    |> Package.create_changeset(attrs)
    |> Repo.insert()
  end

  def save_archive(product, package) do
    path = archive_path(product.name, package.version)

    with :ok <- File.mkdir_p(Path.dirname(path)),
         :ok <- File.write(path, package.archive) do
      package
    end
  end

  def archive_path(name, version) do
    Path.join([:code.priv_dir(:hps), "archive", "#{name}-#{version}.zip"])
  end

  @doc """
  Update a package.
  """
  def update_package(%Product{} = product, attrs) do
    version = attrs[:version] || attrs["version"]
    {:ok, package} = get_package_by_version(product.id, version)

    package
    |> Repo.preload([:product, :files])
    |> Package.update_changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, package} ->
        {:ok, save_archive(package.product, package)}
        |> refresh_store()

      other ->
        other
    end
  end

  @doc """
  Deletes a Package.

  ## Examples

      iex> delete_package(package)
      {:ok, %Package{}}

      iex> delete_package(package)
      {:error, %Ecto.Changeset{}}

  """
  def delete_package(%Package{} = package) do
    Repo.delete(package)
  end

  @doc """
  Get all online (actively using) packages of a product.
  """
  def online_packages(%Product{} = product) do
    product
    |> Repo.preload(:online_packages)
    |> Map.get(:online_packages)
  end

  def offline_packages(%Product{} = product, filter \\ fn _ -> true end) do
    product
    |> Repo.preload(:offline_packages)
    |> Map.get(:offline_packages)
    |> Enum.filter(filter)
  end

  alias HPS.Core.Rollout

  @doc """
  Returns the list of rollouts.

  ## Examples

      iex> list_rollouts(product)
      [%Rollout{}, ...]

  """
  def list_rollouts(%Product{} = product) do
    from(r in Rollout, where: r.product_id == ^product.id)
    |> Repo.all()
  end

  @doc """
  Gets a single rollout.

  Raises `Ecto.NoResultsError` if the Rollout does not exist.

  ## Examples

      iex> get_rollout!(123)
      %Rollout{}

      iex> get_rollout!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rollout!(id), do: Repo.get!(Rollout, id)

  @doc """
  Creates a rollout.

  ## Examples

      iex> create_rollout(product, package)
      {:ok, %Rollout{}}

      iex> create_rollout(product, package)
      {:error, %Ecto.Changeset{}}

  """
  def create_rollout(%Product{} = product, %Package{} = package, policy \\ "default") do
    rollout = %Rollout{
      policy: policy,
      product: product,
      product_id: product.id,
      package: package,
      package_id: package.id,
      target_version: package.version,
      previous_version: product_current_version(product)
    }

    {insert, standout, drawback} = Policy.up_strategy(policy, rollout)

    Repo.transaction(fn ->
      standout.(rollout)
      drawback.(rollout)
      insert.(rollout)
    end)
    |> refresh_store()
  end

  @doc """
  Get product's current online package version.
  """
  def product_current_version(product) do
    case current_rollout(product) do
      nil ->
        nil

      %{target_version: v} ->
        v
    end
  end

  @doc """
  Get most recent done rollout of a product.
  """
  def current_rollout(%Product{} = product) do
    query =
      from(r in Rollout,
        where: r.status == "done" and r.product_id == ^product.id,
        limit: 1,
        order_by: [desc: :done_at]
      )

    query
    |> Repo.one()
  end

  @doc """
  Get rollout by target version.
  """
  def get_rollout_by_version(%Product{} = product, version) do
    from(r in Rollout,
      where: r.product_id == ^product.id and r.target_version == ^version
    )
    |> Repo.one()
  end

  @doc """
  Updates a rollout.

  ## Examples

      iex> update_rollout(rollout, %{progress: 0.5})
      {:ok, %Rollout{}}

      iex> update_rollout(rollout, %{progress: 0})
      {:error, %Ecto.Changeset{}}

  """
  def update_rollout(%Rollout{} = rollout, attrs) do
    rollout
    |> Rollout.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Rollout.

  ## Examples

      iex> rollback(rollout)
      :ok

      iex> rollback(rollout)
      {:error, %Ecto.Changeset{}}

  """
  def rollback(%Rollout{} = rollout) do
    rollout = Repo.preload(rollout, :package)
    {del, standout, drawback} = Policy.down_strategy(rollout.policy, rollout)

    Repo.transaction(fn ->
      standout.(rollout)
      drawback.(rollout)
      del.(rollout)
    end)
    |> refresh_store()
  end

  defp refresh_store(ret) do
    refresh = &HPS.Store.Product.refresh/0

    case ret do
      :ok ->
        refresh.()

      {:ok, _} ->
        refresh.()

      _ ->
        nil
    end

    ret
  end
end
