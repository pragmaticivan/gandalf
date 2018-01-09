defmodule Gandalf.DB.Test.Repo do
  use Ecto.Repo, otp_app: :gandalf

  def log(_cmd), do: nil
end
