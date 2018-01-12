defmodule Gandalf do
  @moduledoc """
  Documentation for Gandalf.
  """

  use Application

  @repo Application.get_env(:gandalf, :repo)

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(@repo, [])
    ]

    opts = [strategy: :one_for_one, name: Gandalf.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
