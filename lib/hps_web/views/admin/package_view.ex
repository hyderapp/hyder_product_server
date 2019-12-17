defmodule HPSWeb.Admin.PackageView do
  use HPSWeb, :view
  alias HPSWeb.Admin.PackageView

  def render("index.json", %{packages: packages}) do
    %{data: render_many(packages, PackageView, "package.json")}
  end

  def render("show.json", %{package: package}) do
    %{data: render_one(package, PackageView, "package.json")}
  end

  def render("package.json", %{package: package}) do
    %{id: package.id, version: package.version}
  end
end
