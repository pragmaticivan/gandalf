defmodule Gandalf.Stub do
  defmodule AppAuthorization do
    def grant(%{"user" => _, "client_id" => _, "redirect_uri" => _, "scope" => _}),
      do: send(self(), :ok)

    def revoke(%{"user" => _, "id" => _}), do: send(self(), :ok)
  end
end
