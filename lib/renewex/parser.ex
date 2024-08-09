defmodule Renewex.Parser do
  alias Renewex.Tokenizer
  alias Renewex.Grammar
  defstruct [:grammar, :tokens, :ref_list]

  @auto_version 11

  def new(tokens, grammar) do
    %Renewex.Parser{
      grammar: grammar,
      tokens: tokens,
      ref_list: []
    }
  end

  def detect_document_version([{:int, version} | tokens]) do
    Renewex.Parser.new(tokens, Grammar.new(version))
  end

  def detect_document_version(tokens) do
    Renewex.Parser.new(tokens, Grammar.new(-1))
  end

  def detect_and_parse_document(tokens) do
    state = detect_document_version(tokens)
  end

  def parse_document(tokens, version \\ @auto_version) do
    state = Renewex.Parser.new(tokens, Grammar.new(version))
  end

  defp parse_token(
         %Renewex.Parser{} = parser,
         type
       ) do
    case parser do
      %Renewex.Parser{tokens: [{^type, value} | rest_tokens]} ->
        {:ok, value,
         %Renewex.Parser{
           parser
           | tokens: rest_tokens
         }}

      %Renewex.Parser{tokens: []} ->
        {:error, :eof}

      %Renewex.Parser{tokens: [{actual_type, actual_value} | _]} ->
        {:error, {actual_type, actual_value}}
    end
  end

  Tokenizer.token_types()
  |> Enum.each(fn name ->
    def unquote(:parse_primitive)(parser, unquote(name)), do: parse_token(parser, unquote(name))
  end)

  def parse_list(parser, fun) do
    {:ok, count, parser} = parse_primitive(parser, :int)

    if count > 0 do
      1..count
      |> Enum.reduce({:ok, [], parser}, fn
        _, {:error, _} = a ->
          a

        _, {:ok, list, parser} ->
          with {:ok, next, p} <- fun.(parser) do
            {:ok, [next | list], p}
          end

        _, _ ->
          raise "Expect function to return tuple {:ok, value, parser} or {:error, reason}"
      end)
    else
      {:ok, []}
    end
  end
end
