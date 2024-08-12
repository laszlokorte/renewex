defmodule Renewex do
  alias Renewex.Parser
  alias Renewex.Tokenizer

  def parse_string(input) do
    with {:ok, root, parser} <-
           input
           |> Tokenizer.scan()
           |> Tokenizer.skip_whitespace()
           |> Parser.detect_document_version()
           |> Parser.parse_storable(nil, false)
           |> Parser.try_skip([:int, :int, :int, :int]),
         {:ok, refs} <- Parser.finalize(parser) do
      {:ok, root, refs}
    else
      e -> e
    end
  end
end
