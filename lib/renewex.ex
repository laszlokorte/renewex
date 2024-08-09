defmodule Renewex do
  alias Renewex.Tokenzier

  def parse_string(input) do
    input |> Tokenzier.scan()
  end
end
