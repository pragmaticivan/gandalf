defmodule Gandalf.Utils.Crypt do
  @moduledoc """
  Crypt utilities
  """

  alias Comeonin.Bcrypt

  @doc """
  Compares string with Bcrypted version of the string.
  Returns true if mathes, otherwise false
  ## Examples
      Gandalf.Utils.Crypt.match_password("12345678",
        "$2b$12$wHkoEnYQ03mWH1CsByPB4ek4xu7QXIFYl5gAC6b8zYs3aj/9DNv3u"
      )
  """
  def match_password(password, crypted_password) do
    Bcrypt.checkpw(password, crypted_password)
  end

  @doc """
  Generate a salt from given string.
  Returns crypted string
  ## Examples
      Gandalf.Utils.Crypt.salt_password("12345678")
      # "$2b$12$wHkoEnYQ03mWH1CsByPB4ek4xu7QXIFYl5gAC6b8zYs3aj/9DNv3u"
  """
  def salt_password(password) do
    Bcrypt.hashpwsalt(password)
  end

  @doc """
  Generates a random string
  ## Examples
      Gandalf.Utils.Crypt.generate_token
      # "ve7LXBsGqsvsXXjiFS1PVQ"
  """
  def generate_token do
    SecureRandom.urlsafe_base64
  end
end
