defmodule Renewex do
  @moduledoc """
  The `Renewex` module provides functionality for parsing [Renew](http://renew.de) source files (*.rnw).
  """

  alias Renewex.Parser
  alias Renewex.Tokenizer

  @doc """
  Parses the content of a .rnw file saved by [Renew](http://renew.de).

  ## Parameters
  - `input`: The content of the file as string

  ## Returns
    - `{:ok, root, refs}`: On success, returns the root of the parsed document tree and a list of references.
    - `{:error, reason}`: On failure, returns an error tuple with the reason for failure.
  """
  def parse_string(input) do
    with {:ok, document, parser} <-
           input
           |> Tokenizer.scan()
           |> Tokenizer.skip_whitespace()
           |> Parser.detect_document_version()
           |> Parser.parse_storable(nil, false)
           |> Parser.try_skip([:int, :int, :int, :int]),
         {:ok, refs} <- Parser.finalize(parser) do
      {:ok, document, refs}
    else
      e -> e
    end
  end
end
