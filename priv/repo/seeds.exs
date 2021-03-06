# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AfterGlow.Repo.insert!(%AfterGlow.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule AfterGlow.Repo.Seed do
  alias AfterGlow.Repo
  alias AfterGlow.PermissionSet
  alias AfterGlow.UserPermissionSet
  alias AfterGlow.Permission
  alias AfterGlow.User
  import Ecto.Query

  def find_or_create_permission_set(name) do
    Repo.get_by(PermissionSet, %{name: name}) ||
      Repo.insert!(PermissionSet.changeset(%PermissionSet{}, %{name: name}))
  end

  def find_or_create_permission(name, permission_set_id) do
    Repo.get_by(Permission, %{name: name, permission_set_id: permission_set_id}) ||
      Repo.insert!(
        Permission.changeset(%Permission{}, %{name: name, permission_set_id: permission_set_id})
      )
  end

  def seed do
    IO.inspect("Running Seeds...")

    [admin, viewer, creator] =
      ["Admin", "Viewer", "Creator"]
      |> Enum.map(fn x ->
        find_or_create_permission_set(x)
      end)

    [admin, viewer, creator]
    |> Enum.each(fn x ->
      ["Dashboard.show", "Question.show"]
      |> Enum.each(fn y ->
        find_or_create_permission(y, x.id)
      end)
    end)

    [creator, admin]
    |> Enum.each(fn x ->
      [
        "Dashboard.edit",
        "Dashboard.create",
        "Dashboard.delete",
        "Question.edit",
        "Question.create",
        "Question.delete"
      ]
      |> Enum.each(fn y ->
        find_or_create_permission(y, x.id)
      end)
    end)

    find_or_create_permission("Settings.all", admin.id)

    if Application.get_env(:afterglow, :admin_email) do
      admin_user =
        Repo.one(
          from(u in User, where: u.email == ^Application.get_env(:afterglow, :admin_email))
        )

      admin_user =
        unless admin_user do
          Repo.insert!(
            User.changeset(%User{}, %{email: Application.get_env(:afterglow, :admin_email)})
          )
        else
          admin_user
        end

      Repo.get_by(UserPermissionSet, %{
        user_id: admin_user.id,
        permission_set_id: admin.id
      }) ||
        Repo.insert!(
          UserPermissionSet.changeset(%UserPermissionSet{}, %{
            user_id: admin_user.id,
            permission_set_id: admin.id
          })
        )
    end
  end
end

AfterGlow.Repo.Seed.seed()
