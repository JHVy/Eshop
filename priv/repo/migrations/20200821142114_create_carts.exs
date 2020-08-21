defmodule Eshop.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(default: fragment("NOW()"))
    end

    create index(:carts, [:user_id])
  end
end
