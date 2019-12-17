defmodule HPS.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :namespace, :string
      add :name, :string, null: false
      add :title, :string

      timestamps()
    end

    create unique_index(:products, [:namespace, :name])
  end
end
