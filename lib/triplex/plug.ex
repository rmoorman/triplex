defmodule Triplex.Plug do
  @moduledoc """
  This module have some basic functions for our triplex plugs.
  """

  import Plug.Conn

  @doc """
  Puts the given tenant as an assign on the given conn, but only if the
  tenant is not reserved.

  See `Triplex.PlugConfig` to the allowed configuration flags.
  """
  def put_tenant(conn, tenant, config) do
    tenant = tenant_handler(tenant, config.tenant_handler)

    if Triplex.reserved_tenant?(tenant) || conn.assigns[config.assign] do
      conn
    else
      assign(conn, config.assign, tenant)
    end
  end

  @doc """
  Ensure the tenant is loaded, and if not, halts the conn.

  See `Triplex.PlugConfig` to the allowed configuration flags.
  """
  def ensure_tenant(conn, tenant, config) do
    tenant = tenant_handler(tenant, config.tenant_handler)

    if conn.assigns[config.assign] do
      callback(conn, tenant, config.callback)
    else
      conn
      |> callback(tenant, config.failure_callback)
      |> halt()
    end
  end

  defp tenant_handler(tenant, nil),
    do: tenant
  defp tenant_handler(tenant, handler) when is_function(handler),
    do: handler.(tenant)

  defp callback(conn, _, nil),
    do: conn
  defp callback(conn, tenant, callback) when is_function(callback),
    do: callback.(conn, tenant)
end

