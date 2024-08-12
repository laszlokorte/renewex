defmodule Renewex.Parser do
  @moduledoc """

  """

  alias Renewex.Parser
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Aliases
  alias Renewex.Tokenizer
  alias Renewex.Grammar
  defstruct [:grammar, :tokens, :ref_list]

  @min_version -1
  @auto_version 11

  @doc """

  """
  def min_version, do: @min_version

  @doc """

  """
  def auto_version, do: @auto_version

  @doc """

  """
  def new(tokens, grammar) do
    %Renewex.Parser{
      grammar: grammar,
      tokens: tokens,
      ref_list: []
    }
  end

  @doc """

  """
  def detect_document_version(tokens) do
    case Enum.take(tokens, 1) do
      [{:int, version}] ->
        Renewex.Parser.new(Stream.drop(tokens, 1) |> Enum.to_list(), Grammar.new(version))

      _ ->
        Renewex.Parser.new(tokens |> Enum.to_list(), Grammar.new(@min_version))
    end
  end

  @doc """

  """
  def detect_and_parse_document(tokens) do
    detect_document_version(tokens)
    |> Parser.parse_storable(nil)
  end

  @doc """

  """
  def parse_document(tokens, version \\ @auto_version) do
    Renewex.Parser.new(tokens, Grammar.new(version))
    |> Parser.parse_storable(nil)
  end

  @doc """

  """
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

  @doc """

  """
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

  @doc """

  """
  def parse_storable(
        %Renewex.Parser{
          tokens: [{current_type, current_value} | rest_tokens],
          ref_list: parent_ref_list
        } = parser,
        expected_type \\ nil,
        return_ref \\ true
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

        if is_nil(expected_type) or
             Hierarchy.is_of_type(parser.grammar, class_name, expected_type) do
          with {:ok, result, %Renewex.Parser{ref_list: child_ref_list} = p} <-
                 parse_grammar_rule(
                   %Renewex.Parser{next_parser | ref_list: []},
                   class_name,
                   Storable.new(class_name)
                 ) do
            {:ok, if(return_ref, do: {:ref, Enum.count(parent_ref_list)}, else: result),
             %Renewex.Parser{
               p
               | ref_list: Enum.concat(child_ref_list, [result | parent_ref_list])
             }}
          else
            err -> dbg(err)
          end
        else
          {:error, {class_name, expected_type}, next_parser}
        end

      _ ->
        {:error, {current_type, current_value}, next_parser}
    end
  end

  @doc """

  """
  def parse_grammar_rule(parser, rule) do
    parse_grammar_rule(parser, rule, Storable.new(rule))
  end

  def parse_grammar_rule(parser, rule, storable) do
    base =
      cond do
        Grammar.should_skip_super(parser.grammar, rule) ->
          {:ok, storable, parser}

        super_rule =
            Hierarchy.get_super(parser.grammar, rule) ->
          parse_grammar_rule(parser, super_rule, storable)

        true ->
          {:ok, storable, parser}
      end

    with {:ok, storable, next_parser} <- base,
         {:ok, value, parser} <- Grammar.parse(next_parser, rule, storable) do
      {:ok, value, parser}
    else
      err -> err
    end
  end

  @doc """

  """
  def parse_list(parser, fun) do
    {:ok, count, parser} = parse_primitive(parser, :int)

    if count > 0 do
      1..count
      |> Enum.reduce({:ok, [], parser}, fn
        _, {:error, _, _} = a ->
          a

        i, {:ok, list, parser} ->
          case fun.(parser) do
            {:ok, next, p} -> {:ok, [next | list], p}
            {:err, e, p} -> {:err, {:list, i, e}, p}
          end

        _, _ ->
          raise "Expect function to return tuple {:ok, value, parser} or {:error, reason}"
      end)
    else
      {:ok, [], parser}
    end
  end

  @doc """

  """
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

  @doc """

  """
  def is_eof(%Renewex.Parser{tokens: []}), do: true
  def is_eof(%Renewex.Parser{tokens: [_ | _]}), do: false

  @doc """

  """
  def finalize(%Renewex.Parser{tokens: [], ref_list: ref_list}) do
    {:ok, Enum.reverse(ref_list)}
  end

  def finalize(%Renewex.Parser{tokens: [current_token | _]}) do
    {:error, current_token}
  end

  @doc """

  """
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
