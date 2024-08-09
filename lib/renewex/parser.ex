defmodule Renewex.Parser do
  alias Renewex.Tokenizer
  alias Renewex.Grammar
  defstruct [:grammar, :tokens, :ref_list]

  @auto_version 11

  def new(grammar, tokens) do
    %Renewex.Parser{
      grammar: grammar,
      tokens: tokens,
      ref_list: []
    }
  end

  def detect_document_version([{:int, version} | tokens]) do
    Renewex.Parser.new(Grammar.new(version), tokens)
  end

  def detect_document_version(tokens) do
    Renewex.Parser.new(Grammar.new(-1), tokens)
  end

  def detect_and_parse_document(tokens) do
    state = detect_document_version(tokens)
  end

  def parse_document(tokens, version \\ @auto_version) do
    state = Renewex.Parser.new(Grammar.new(version), tokens)
  end

  defp parse_token(
         %Renewex.Parser{tokens: [{type, value} | rest_tokens]} = parser,
         type
       ) do
    {:ok, value,
     %Renewex.Parser{
       parser
       | tokens: rest_tokens
     }}
  end

  defp parse_token(
         %Renewex.Parser{tokens: []},
         type
       ) do
    {:error, :eof, type}
  end

  defp parse_token(
         %Renewex.Parser{tokens: [{actual_type, actual_value} | _]},
         type
       ) do
    {:error, {actual_type, actual_value}, type}
  end

  Tokenizer.token_types()
  |> Enum.each(fn name ->
    def unquote(:parse_primitive)(parser, unquote(name)), do: parse_token(parser, unquote(name))
  end)
end
