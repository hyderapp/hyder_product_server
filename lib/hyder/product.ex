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
  Get the latest package. Returns the package with the latest rollout done.

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

  def latest_package(packages) when is_list(packages) do
    packages
    |> Enum.sort_by(&Version.parse(&1.version), &>=/2)
    |> Enum.max_by(&(&1.rollout && &1.rollout.done_at))
  end

  @doc """
  Given a list of products, return all file path of their latest packages.
  Paths are uniqued based on files. This is similar to `all_files/2` but
  only contains the path.
  """
  def all_paths(products, base \\ %{})

  def all_paths(products, base) do
    all_files(products, base)
    |> Enum.map(& &1.path)
  end

  @doc """
  Given a list of products, return all files of their latest packages.
  Files are uniqued.
  """
  def all_files(products, base),
    do: _all_files(products, parse_base(base))

  defp _all_files(products, []) do
    products
    |> Stream.flat_map(&latest_package(&1).files)
    |> Enum.uniq()
  end

  defp _all_files(products, base) do
    Enum.reduce(base, _all_files(products, []), fn {name, version}, acc ->
      case get_files(products, name, version) do
        nil ->
          acc

        files ->
          acc -- files
      end
    end)
  end

  defp get_files(data, name, version) do
    Enum.find_value(data, fn product ->
      if product.name == name, do: get_files(product.packages, version)
    end)
  end

  defp get_files(package, version) do
    Enum.find_value(package, fn p ->
      if p.version == version, do: p.files
    end)
  end

  @doc """
  Parse client base version config from string.

  ## Example

      iex> parse_base("home:2.3.4")
      %{"home" => "2.3.4"}

      iex> parse_base("post:1.10.5,about:1.3.1")
      %{"post" => "1.10.5", "about" => "1.3.1"}

      iex> parse_base(nil)
      %{}
  """
  def parse_base(nil), do: %{}

  def parse_base(str) when is_binary(str) do
    String.split(str, ",")
    |> Stream.map(&String.split(&1, ":"))
    |> Stream.map(&List.to_tuple/1)
    |> Enum.to_list()
  end

  def parse_base(base), do: base
end
