defmodule HPS.Repo.Migrations.AddOnlineFieldToPackages do
  use Ecto.Migration

  def change do
    alter table(:packages) do
      add :online, :boolean, default: false, null: false
    end

    create index(:packages, :online)
  end
end
