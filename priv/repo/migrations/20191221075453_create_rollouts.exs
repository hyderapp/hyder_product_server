defmodule HPS.Repo.Migrations.CreateRollouts do
  use Ecto.Migration

  def change do
    create table(:rollouts) do
      add :policy, :string
      add :progress, :float
      add :status, :string, null: false
      add :target_version, :string, null: false
      add :previous_version, :string
      add :done_at, :utc_datetime

      add :product_id, references(:products, on_delete: :nothing)
      add :package_id, references(:packages, on_delete: :nothing)

      timestamps()
    end

    create index(:rollouts, [:product_id])
    create index(:rollouts, [:status])
    create unique_index(:rollouts, [:product_id, :target_version])
    create unique_index(:rollouts, [:package_id])
  end
end
