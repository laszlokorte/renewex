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
      {:error, {:int, 1, _}, next_parser} -> {:ok, true, next_parser}
      {:error, {:int, 0, _}, next_parser} -> {:ok, false, next_parser}
      {:error, {:int, 1}, next_parser} -> {:ok, true, next_parser}
      {:error, {:int, 0}, next_parser} -> {:ok, false, next_parser}
      e -> e
    end
  end

  def parse_storable(
        %Renewex.Parser{
          tokens: [{current_type, current_value} | rest_tokens],
          ref_list: ref_list
        } = parser,
        expected_type \\ nil
      ) do
    next_parser = %Renewex.Parser{
      parser
      | tokens: rest_tokens
    }

    case current_type do
      :null ->
        {:ok, nil, next_parser}

      :ref ->
        {:ok, {:ref, current_value}, next_parser}

      :class_name ->
        class_name = Aliases.resolve_alias(current_value)

        if is_nil(expected_type) or class_name == expected_type or
             Enum.member?(
               Hierarchy.interfaces_of(parser.grammar, class_name),
               expected_type
             ) do
          with {:ok, result, p} <-
                 parse_grammar_rule(next_parser, class_name, Storable.new(class_name)) do
            {:ok, result,
             %Renewex.Parser{
               p
               | ref_list: [result | ref_list]
             }}
          else
            err -> err
          end
        else
          {:error, {class_name, expected_type}, next_parser}
        end

      _ ->
        {:error, {current_type, current_value}, next_parser}
    end
  end

  def parse_grammar_rule(parser, rule) do
    parse_grammar_rule(parser, rule, Storable.new(rule))
  end

  def parse_grammar_rule(parser, rule, storable) do
    base =
      if super_rule = Hierarchy.get_super(parser.grammar, rule) do
        parse_grammar_rule(parser, super_rule, storable)
      else
        {:ok, storable, parser}
      end

    with {:ok, storable, parser} <- base,
         {:ok, value, parser} <- Grammar.parse(parser, rule, storable) do
      {:ok, value, parser}
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

  def skip_any(
        %Renewex.Parser{tokens: [{current_type, _} = current_token | rest]} = parser,
        skippables
      ) do
    if Enum.member?(skippables, current_type) do
      {:ok, nil, %Renewex.Parser{parser | tokens: rest}}
    else
      {:error, current_token, %Renewex.Parser{parser | tokens: rest}}
    end
  end

  def is_eof(%Renewex.Parser{tokens: []}), do: true
  def is_eof(%Renewex.Parser{tokens: [_ | _]}), do: false

  def finalize(%Renewex.Parser{tokens: [], ref_list: ref_list}) do
    {:ok, Enum.reverse(ref_list)}
  end

  def finalize(%Renewex.Parser{tokens: [current_token | _]}) do
    {:error, current_token}
  end

  def try_skip({:ok, result, %Renewex.Parser{} = parser}, skips) do
    {:ok, result, try_skip(parser, skips)}
  end

  def try_skip(%Renewex.Parser{tokens: tokens} = parser, skips) do
    matching_skips =
      Enum.zip_with(tokens, skips, fn {actual_type, _}, skip_type -> skip_type == actual_type end)

    if Enum.all?(matching_skips) and Enum.count(matching_skips) == Enum.count(skips) do
      %Renewex.Parser{parser | tokens: Enum.drop(parser.tokens, Enum.count(skips))}
    else
      parser
    end
  end
end
