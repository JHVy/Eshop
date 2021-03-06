defmodule EshopWeb.Ecom.ProductController do
  use EshopWeb, :controller

  alias Eshop.Ecom
  alias Eshop.Ecom.Product

  action_fallback EshopWeb.FallbackController

  def index(conn, params) do
    paging = Ecom.list_products_with_paging(params)

    entries =
      paging.entries
      |> Eshop.Repo.preload([:category, :brand])
      |> Eshop.Utils.StructHelper.to_map()

    conn |> json(%{status: "OK", data: %{paging | entries: entries}})
  end

  def create(conn, params) do
    case Ecom.create_product(params) do
      {:ok, product} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "OK", data: Eshop.Utils.StructHelper.to_map(product)})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "ERROR",
          code: "VALIDATION_FAILED",
          message:
            changeset
            |> EshopWeb.ChangesetView.translate_errors()
            |> Eshop.Utils.Validator.get_validation_error_message()
        })
    end
  end

  def show(conn, %{"id" => id}) do
    product = Ecom.get_product!(id)

    conn |> json(%{status: "OK", data: Eshop.Utils.StructHelper.to_map(product)})
  end

  def update(conn, %{"id" => id} = params) do
    product = Ecom.get_product!(id)

    case Ecom.update_product(product, params) do
      {:ok, product} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "OK", data: Eshop.Utils.StructHelper.to_map(product)})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "ERROR",
          code: "VALIDATION_FAILED",
          message:
            changeset
            |> EshopWeb.ChangesetView.translate_errors()
            |> Eshop.Utils.Validator.get_validation_error_message()
        })
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Ecom.get_product!(id)

    with {:ok, %Product{}} <- Ecom.delete_product(product) do
      conn |> json(%{status: "OK"})
    end
  end
end
