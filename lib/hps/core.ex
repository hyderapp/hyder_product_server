defmodule HPS.Core do
  @moduledoc """
  Hyder Package Server.
  """

  alias HPS.Core.Product
  alias HPS.Core.Package
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

  def get_product_by_name(name, namespace \\ "default") do
    from(p in Product, where: p.namespace == ^namespace and p.name == ^name)
    |> Repo.one()
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
    ret =
      %Product{}
      |> Product.create_changeset(attrs)
      |> Repo.insert()

    case ret do
      {:ok, _} ->
        HPS.Store.Product.refresh()
        ret

      _ ->
        ret
    end
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
end
