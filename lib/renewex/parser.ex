defmodule Renewex.Parser do
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Aliases
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
        {:error, :eof, parser}

      %Renewex.Parser{tokens: [{actual_type, actual_value} | rest_tokens]} ->
        {:error, {actual_type, actual_value},
         %Renewex.Parser{
           parser
           | tokens: rest_tokens
         }}
    end
  end

  Tokenizer.token_types()
  |> Enum.filter(fn
    :boolean -> false
    _ -> true
  end)
  |> Enum.each(fn name ->
    def unquote(:parse_primitive)(parser, unquote(name)), do: parse_token(parser, unquote(name))
  end)

  def parse_primitive(parser, :boolean) do
    with {:ok, bool, next_parser} <- parse_token(parser, :boolean) do
      {:ok, bool, next_parser}
    else
      {:error, {:int, 1}, next_parser} -> {:ok, true, next_parser}
      {:error, {:int, 0}, next_parser} -> {:ok, false, next_parser}
      e -> e
    end
  end

  def parse_storable(
        %Renewex.Parser{
          tokens: [{current_type, current_value} | rest_tokens],
          ref_list: ref_list
        } = parser
      ) do
    next_parser = %Renewex.Parser{
      parser
      | tokens: rest_tokens
    }

    case current_type do
      :null ->
        {:ok, nil}

      :ref ->
        {:ok, {:ref, current_value}}

      :class_name ->
        class_name = Aliases.resolve_alias(current_value)

        with {:ok, result, p} <-
               parse_grammar_rule(next_parser, class_name, Storable.new(class_name)) do
          {:ok, result,
           %Renewex.Parser{
             p
             | ref_list: [result, ref_list]
           }}
        else
          err -> err
        end

      _ ->
        {:error, {current_type, current_value}, next_parser}
    end
  end

  def parse_grammar_rule(parser, rule, storable) do
    storable =
      if super_rule = Hierarchy.get_super(parser.grammar, rule) do
        parse_grammar_rule(parser, super_rule, storable)
      else
        storable
      end

    with {:ok, value, parser} <- Grammar.parse(parser, rule, storable) do
      {:ok, value,
       %Renewex.Parser{
         parser
         | # TODO
           tokens: []
       }}
    else
      err -> err
    end
  end

  def parse_list(parser, fun) do
    {:ok, count, parser} = parse_primitive(parser, :int)

    if count > 0 do
      1..count
      |> Enum.reduce({:ok, [], parser}, fn
        _, {:error, _, _} = a ->
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

  def skip_any(%Renewex.Parser{tokens: []}), do: {:error, :eof}

  def skip_any(%Renewex.Parser{tokens: [_ | rest]} = parser),
    do: %Renewex.Parser{parser | tokens: rest}

  def is_eof(%Renewex.Parser{tokens: []}), do: true
  def is_eof(%Renewex.Parser{tokens: [_ | _]}), do: false
end
