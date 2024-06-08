defmodule Identity.GuardianHelpers do
  alias Identity.Guardian

  def get_current_user(%Plug.Conn{} = conn) do
    case Guardian.Plug.authenticated?(conn) do
      true -> {:ok, Guardian.Plug.current_resource(conn)}
      false -> {:error, :unauthorized}
    end
  end
end
