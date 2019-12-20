defmodule HPS.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :path, :string, null: false
      add :digest, :string, null: false
      add :size, :integer, null: false
      add :package_id, references(:packages, on_delete: :nothing)

      timestamps()
    end

    create index(:files, [:package_id])
    create unique_index(:files, [:package_id, :path])
  end
end
