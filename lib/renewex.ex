defmodule Renewex do
  alias Renewex.Tokenizer

  def parse_string(input) do
    input |> Tokenizer.scan()
  end
end
