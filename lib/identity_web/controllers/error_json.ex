defmodule IdentityWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  def render("403.json", %{error: error}) do
    %{
      error: %{
        status: error.status,
        reason: error.reason
      }
    }
  end

  def render("401.json", %{error: error}) do
    %{
      error: %{
        status: error.status,
        reason: error.reason
      }
    }
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
