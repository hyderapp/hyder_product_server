defmodule HPSWeb.Admin.PackageView do
  use HPSWeb, :view
  alias HPSWeb.Admin.PackageView

  def render("index.json", %{packages: packages}) do
    %{success: true, data: render_many(packages, PackageView, "package.json")}
  end

  def render("show.json", %{package: package}) do
    %{success: true, data: render_one(package, PackageView, "package.json")}
  end

  def render("package.json", %{package: package}) do
    %{version: package.version}
  end

  def render("delete.json", %{}) do
    %{success: true}
  end
end
