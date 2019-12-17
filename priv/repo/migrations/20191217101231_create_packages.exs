defmodule HPS.Repo.Migrations.CreatePackages do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :version, :string, null: false
      add :product_id, references(:products)

      timestamps()
    end

    create unique_index(:packages, [:product_id, :version])
  end
end
