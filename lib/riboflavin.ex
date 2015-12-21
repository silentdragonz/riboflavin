defmodule Riboflavin do
  use Application
  def start(_type, _args) do
    Riboflavin.B2Auth.start_link
  end
end
