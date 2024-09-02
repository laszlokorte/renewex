defmodule Renewex do
  @moduledoc """
  The `Renewex` module provides functionality for parsing [Renew](http://renew.de) source files (*.rnw).
  """

  alias Renewex.Serializer
  alias Renewex.Grammar
  alias Renewex.Document
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
  def parse_document(input) do
    with {:ok, document, parser} <-
           input
           |> Tokenizer.scan()
           |> Tokenizer.skip_whitespace()
           |> Parser.detect_document_version()
           |> Parser.parse_storable(nil, false) do
      with {parser, size} <- parse_size(parser),
           version <- Parser.get_version(parser),
           {:ok, refs} <- Parser.finalize(parser) do
        {:ok, Document.new(version, document, refs, size)}
      end
    else
      e -> e
    end
  end

  @doc """

  """
  def serialize_document(%Document{version: version, root: root, refs: refs, size: size}) do
    serializer = Serializer.new(refs, Grammar.new(version))

    with {:ok, ser} <- Serializer.serialize_storable(serializer, root) do
      ser =
        if version == -1,
          do: ser,
          else: Serializer.prepend_token(ser, {:int, version})

      ser =
        if size == nil,
          do: ser,
          else:
            Enum.reduce(Tuple.to_list(size), ser, fn s, ser ->
              Serializer.append_token(ser, {:int, s})
            end)

      {:ok, Serializer.get_output_string(ser)}
    else
      err -> err
    end
  end

  defp parse_size(parser) do
    case Parser.try_parse(parser, [:int, :int, :int, :int]) do
      {:none, parser} -> {parser, nil}
      {[{:int, x}, {:int, y}, {:int, w}, {:int, h}], parser} -> {parser, {x, y, w, h}}
    end
  end
end
