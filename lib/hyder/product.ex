defmodule Hyder.Product do
  @moduledoc """
  A Hyder Product (Product for short later) is where the high level bussiness
  overview of a hyder application lays.

  Products can have a `namespace` setting. There can be different products
  with same names but in different namespaces. In one namespace, product names
  should be unique.
  """

  defstruct namespace: nil, name: nil, title: nil, packages: []

  @type t :: __MODULE__

  @doc """
  Build a new product with attributes

  ## Example

      iex> Hyder.Product.new("foo", "bar")
      %Hyder.Product{name: "foo", title: "bar", packages: []}

      iex> Hyder.Product.new("fooo")
      %Hyder.Product{name: "fooo", title: nil, packages: []}
  """
  @spec new(binary(), binary() | nil) :: t()

  def new(name, title \\ nil) do
    %__MODULE__{name: name, title: title}
  end

  @doc """
  Adds a package to an exsiting product.

  ## Example

      iex> product = Hyder.Product.new("foo")
      ...> package = Hyder.Package.new("1.0.0")
      ...> add_package(product, package)
      %Hyder.Product{name: "foo", title: nil, packages: [%Hyder.Package{version: "1.0.0"}]}

  Packages are uniq on their `version` values.

      iex> product = Hyder.Product.new("bar")
      ...> package1 = Hyder.Package.new("1.0.0")
      ...> package2 = Hyder.Package.new("1.0.0")
      ...> product |> add_package(package1) |> add_package(package2)
      %Hyder.Product{name: "bar", title: nil, packages: [%Hyder.Package{version: "1.0.0"}]}

  Packages are all online at core level. That is to say:
  - to release a package to user, put it into the product's `packages` list;
  - to draw a package back, just remove it from the `packages` list.
  """
  @spec add_package(t(), Hyder.Package.t()) :: t()
  def add_package(%{packages: packages} = product, p) do
    packages = [p | packages] |> Enum.uniq_by(& &1.version)

    %{product | packages: packages}
  end

  @doc """
  Remove a package. This will remove the package from online packages list.
  Users would be no longer able to reach out to this package again.

  ## Example

      iex> product = Hyder.Product.new("foo")
      ...> package1 = Hyder.Package.new("1.0.0")
      ...> package2 = Hyder.Package.new("1.1.0")
      ...> product
      ...> |> add_package(package1)
      ...> |> add_package(package2)
      ...> |> remove_package("1.1.0")
      %Hyder.Product{name: "foo", title: nil, packages: [%Hyder.Package{version: "1.0.0"}]}
  """
  @spec remove_package(t(), binary()) :: t()
  def remove_package(%{packages: packages} = product, version) do
    %{product | packages: Enum.reject(packages, &(&1.version == version))}
  end

  @doc """
  Get the latest package. Returns the package with the highest version value.

  ## Example

      iex> product = Hyder.Product.new("foo")
      ...> package1 = Hyder.Package.new("1.2.0")
      ...> package2 = Hyder.Package.new("1.10.0")
      ...> package3 = Hyder.Package.new("0.1.0")
      ...> product
      ...> |> add_package(package1)
      ...> |> add_package(package2)
      ...> |> add_package(package3)
      ...> |> latest_package()
      %Hyder.Package{version: "1.10.0"}

  Or use lists:

      iex> package1 = Hyder.Package.new("1.2.0")
      ...> package2 = Hyder.Package.new("1.10.0")
      ...> package3 = Hyder.Package.new("0.1.0")
      ...> latest_package([package1, package2, package3])
      %Hyder.Package{version: "1.10.0"}

  Notice: `version` values of the packages should be all valid with
  Elixir's version specification, otherwise comparing will not work
  and the result is not expected.

  @see https://hexdocs.pm/elixir/Version.html#module-versions
  """
  def latest_package(%{packages: packages}), do: latest_package(packages)

  def latest_package(packages) when is_list(packages),
    do: packages |> Enum.max_by(&Version.parse(&1.version))

  @doc """
  Given a list of products, return all file paths of their latest packages.
  """
  def all_paths(products) do
    products
    |> Stream.flat_map(fn product -> latest_package(product).files end)
    |> Stream.map(fn %{path: path} -> path end)
    |> Enum.uniq()
  end
end
