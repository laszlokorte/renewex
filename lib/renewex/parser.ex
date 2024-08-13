defmodule Renewex.Parser do
  @moduledoc """
  This module implements the core of the parser for reading [Renew](http://renew.de) `*.rnw` files.
  The grammar to be used for parsing is defined by Renewex.Grammar.

  This Renewex.Parser manages the overall parser state and provides function to process the whole 
  token stream coming from an `*.rnw` file.
  """

  alias Renewex.Parser
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Aliases
  alias Renewex.Tokenizer
  alias Renewex.Grammar
  defstruct [:grammar, :tokens, :ref_stack, :ref_count]

  @doc """
  Constructs a new parser state for a given list of tokens and a given grammar.
  """
  def new(tokens, grammar) do
    %Renewex.Parser{
      grammar: grammar,
      tokens: tokens,
      ref_stack: [],
      ref_count: 0
    }
  end

  @doc """
  Constructs a new parser state by taking a list of tokens. The grammar to be used for parsing
  Is extract from the version information encoded in the first token.
  If the first token is not an integer it is assumed that the oldest version of Renew had been used to create the file
  that this list of tokens are read from.
  """
  def detect_document_version(tokens) do
    case Enum.take(tokens, 1) do
      [{:int, version}] ->
        Renewex.Parser.new(Stream.drop(tokens, 1) |> Enum.to_list(), Grammar.new(version))

      _ ->
        Renewex.Parser.new(tokens |> Enum.to_list(), Grammar.new(Grammar.min_version()))
    end
  end

  @doc """
  For a given list of tokens deduce that grammar version automatically and use 
  it to parse the complete token stream. 
  """
  def detect_and_parse_document(tokens) do
    detect_document_version(tokens)
    |> Parser.parse_storable(nil)
  end

  @doc """
  Parse the given list of tokens with the given grammar.
  """
  def parse_document(tokens, version \\ Grammar.latest_version()) do
    Renewex.Parser.new(tokens, Grammar.new(version))
    |> Parser.parse_storable(nil)
  end

  # Given the current state of a parser, read a single token of the given type.
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

  @doc """
  Given a current parser state, read a single token of a given primitive type.
  """
  def parse_primitive(parser, type)

  # Define a function for each primitive type to parse a single token of that type.
  Tokenizer.token_types()
  |> Enum.filter(fn
    :boolean -> false
    _ -> true
  end)
  |> Enum.each(fn name ->
    def unquote(:parse_primitive)(parser, unquote(name)), do: parse_token(parser, unquote(name))
  end)

  # For booleans the function is explicitly defined to handle both true/false tokens as well as 1/0 tokens
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
  Given the current parser state, parse the object.
  The object is expected to be either NULL or a REF token or a serialized java class prefixed
  with its class name as next token. This prefix determines which grammar rule is used to continue parsing
  the list of tokens.

  If a serialized java object is read, it is prepedned to the ref_map of the parser.
  You can choose for this function to then eiter return a reference into this ref_map as integer (default)
  or to return the parsed object Storable struct itself (set `return_ref` to true).

  When `expected_type` is given the parsed object is required to be a subtype of the `expected_type` accordings to the grammars
  class hierarhy.
  """
  def parse_storable(
        parser,
        expected_type \\ nil,
        return_ref \\ true
      )

  def parse_storable(
        %Renewex.Parser{
          tokens: [{current_type, current_value} | rest_tokens],
          ref_stack: parent_ref_stack,
          ref_count: parent_ref_count
        } = parser,
        expected_type,
        return_ref
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
             Hierarchy.is_implementation_of(parser.grammar, class_name, expected_type) do
          with {:ok, result,
                %Renewex.Parser{ref_stack: child_ref_stack, ref_count: child_ref_count} = p} <-
                 parse_grammar_rule(
                   %Renewex.Parser{
                     next_parser
                     | ref_stack: [:incomplete_parsed | parent_ref_stack],
                       ref_count: parent_ref_count + 1
                   },
                   class_name,
                   Storable.new(class_name)
                 ) do
            {:ok, if(return_ref, do: {:ref, Enum.count(parent_ref_stack)}, else: result),
             %Renewex.Parser{
               p
               | ref_stack:
                   Enum.concat(
                     Enum.slice(child_ref_stack, 0, child_ref_count - 1 - parent_ref_count),
                     [
                       result | parent_ref_stack
                     ]
                   )
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

  def parse_storable(
        %Renewex.Parser{
          tokens: [current_token | rest_tokens]
        } = parser,
        expected_type,
        _return_ref
      ) do
    {:error, {current_token, {:class_name, expected_type}},
     %Renewex.Parser{parser | tokens: rest_tokens}}
  end

  def parse_storable(
        %Renewex.Parser{
          tokens: []
        } = parser,
        expected_type,
        _return_ref
      ) do
    {:error, {:eof, {:class_name, expected_type}}, parser}
  end

  @doc """
  Given a parser state continue parsing by applying the given rule.
  The rule is the name of a java class defined in the parsers grammars hierarchy.

  In contrast to `parse_storable` no NULL or REF values are allowed and the parsed objects must
  *not* be prefixed with its class name. Instead the given rule explicitly determines which grammar rule to use.
  """
  def parse_grammar_rule(parser, rule) do
    parse_grammar_rule(parser, rule, Storable.new(rule))
  end

  def parse_grammar_rule(parser, rule, storable) do
    if Hierarchy.is_defined(parser.grammar, rule) do
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
    else
      {:error, rule, parser}
    end
  end

  @doc """
  Given the current state of a parser parse a list.
  The next token must be an integer encoding the length of the list (`l`).
  The given function `fun` is a function that must parse single item of the list.
  It is applied `l` times in a row. 
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
            {:error, e, p} -> {:error, {:list, {i, count}, e}, p}
          end

        _, _ ->
          raise "Expect function to return tuple {:ok, value, parser} or {:error, reason}"
      end)
    else
      {:ok, [], parser}
    end
  end

  @doc """
  Given the current state of a parser skip the next token. If list of tokens is already empty return an error.
  """
  def skip_any(parser)

  def skip_any(%Renewex.Parser{tokens: []}), do: {:error, :eof}

  def skip_any(%Renewex.Parser{tokens: [_ | rest]} = parser),
    do: %Renewex.Parser{parser | tokens: rest}

  @doc """
  Given the current state of a parser expect the next tokens type to be one of the given types. Then skip it.
  If list of tokens already empty or the types do not match, return an error
  """
  def skip_any(parser, of_types)

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

  def skip_any(%Renewex.Parser{tokens: []}, _), do: {:error, :eof}

  @doc """
  Check if the list of tokens of the given parser state is empty.
  """
  def is_eof(%Renewex.Parser{tokens: []}), do: true
  def is_eof(%Renewex.Parser{tokens: [_ | _]}), do: false

  @doc """
  Expect the list of tokens to be empty and return the reversed list of parsed objects.
  If the list of tokens is not empty, return an error.
  """
  def finalize(%Renewex.Parser{tokens: [], ref_stack: ref_stack}) do
    {:ok, Enum.reverse(ref_stack)}
  end

  def finalize(%Renewex.Parser{tokens: [current_token | _]}) do
    {:error, current_token}
  end

  @doc """
  Given the current state of a parser try to skip multiple tokens of the expected types.
  If n types are given and the next n tokens match these types, the tokens are skipped.
  If anything does not match the original parser state is returned.

  Another of try_skip that takes not just a parser but a tupkle of {:ok, result, parser} or {:error, result, parser}.
  If `{:error, ...}` simply return the input. If {:ok, result, parser} apply try_skip to the parser.
  """
  def try_skip(%Renewex.Parser{tokens: tokens} = parser, skips) do
    matching_skips =
      Enum.zip_with(tokens, skips, fn {actual_type, _}, skip_type -> skip_type == actual_type end)

    if Enum.all?(matching_skips) and Enum.count(matching_skips) == Enum.count(skips) do
      %Renewex.Parser{parser | tokens: Enum.drop(parser.tokens, Enum.count(skips))}
    else
      parser
    end
  end

  def try_skip({:ok, result, %Renewex.Parser{} = parser}, skips) do
    {:ok, result, try_skip(parser, skips)}
  end

  def try_skip({:error, _, %Renewex.Parser{}} = err, _) do
    err
  end
end
