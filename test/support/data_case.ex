defmodule Gandalf.DB.Test.DataCase do
  @moduledoc false
  use ExUnit.CaseTemplate
  alias Gandalf.DB.Test.Repo
  import Gandalf.DB.Test.Support.FileHelpers

  using _opts do
    quote do
      import Gandalf.DB.Test.DataCase
      alias Gandalf.DB.Test.Repo
    end
  end

  setup_all do
    on_exit(fn -> destroy_tmp_dir("priv/temp/gandalf_db_test") end)
    :ok
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    :ok
  end
end
