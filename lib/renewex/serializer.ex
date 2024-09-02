defmodule Renewex.Serializer do
  @moduledoc """

  """
  alias Renewex.Serializer
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Grammar
  alias Renewex.Tokenizer

  @doc """

  """
  defstruct [
    :grammar,
    :refs,
    :used_refs,
    :output
  ]

  @doc """

  """
  def new(refs, grammar) do
    %Serializer{
      grammar: grammar,
      refs: refs,
      used_refs: Map.new(),
      output: []
    }
  end

  @doc """

  """
  def serialize_storable(serializer, storable, expected_rule \\ nil)

  def serialize_storable(%Serializer{} = serializer, nil, _) do
    {:ok, append(serializer, "NULL")}
  end

  def serialize_storable(
        %Serializer{used_refs: used_refs, refs: all_refs} = serializer,
        {:ref, ref},
        expected_rule
      )
      when is_integer(ref) do
    storable = Enum.at(all_refs, ref)

    if is_nil(expected_rule) or
         Hierarchy.is_implementation_of(serializer.grammar, storable.class_name, expected_rule) or
         Hierarchy.is_subtype_of(serializer.grammar, storable.class_name, expected_rule) do
      case Map.get(used_refs, ref) do
        nil ->
          new_ref = map_size(used_refs) + 1

          serialize_storable(
            %Serializer{serializer | used_refs: Map.put(used_refs, ref, new_ref)},
            storable,
            expected_rule
          )

        idx when is_integer(idx) ->
          {:ok, append(serializer, ["REF ", Integer.to_string(idx)])}
      end
    else
      {:error, {storable.class_name, expected_rule}}
    end
  end

  def serialize_storable(
        %Serializer{} = serializer,
        %Storable{class_name: class_name, fields: fields},
        expected_rule
      ) do
    if is_nil(expected_rule) or
         Hierarchy.is_implementation_of(serializer.grammar, class_name, expected_rule) or
         Hierarchy.is_subtype_of(serializer.grammar, class_name, expected_rule) do
      serialize_grammar_rule(append(serializer, class_name), class_name, fields)
    else
      {:error, {class_name, expected_rule}}
    end
  end

  @doc """

  """
  def serialize_list(%Serializer{} = serializer, list, ser_fn) do
    list
    |> Enum.reduce({:ok, append_token(serializer, {:int, Enum.count(list)})}, fn
      item, {:ok, ser} ->
        ser_fn.(item, ser)

      _, {:error, _} = e ->
        e
    end)
  end

  @doc """

  """
  def serialize_grammar_rule(%Serializer{} = serializer, rule, fields) do
    if Hierarchy.is_defined(serializer.grammar, rule) do
      cond do
        Grammar.should_skip_super(serializer.grammar, rule) ->
          Grammar.serialize(serializer, rule, fields)

        super_rule =
            Hierarchy.get_super(serializer.grammar, rule) ->
          with {:ok, ser} <- serialize_grammar_rule(serializer, super_rule, fields) do
            ser |> Grammar.serialize(rule, fields)
          else
            {:error, e} -> {:error, e}
          end

        true ->
          Grammar.serialize(serializer, rule, fields)
      end
    else
      {:error, rule}
    end
  end

  @doc """

  """
  def append_token(%Serializer{} = serializer, {type, value}, space \\ true) do
    append(serializer, Tokenizer.token_to_binary(type, value), space)
  end

  @doc """

  """
  def prepend_token(%Serializer{} = serializer, {type, value}, space \\ true) do
    prepend(serializer, Tokenizer.token_to_binary(type, value), space)
  end

  @doc """

  """
  def append(%Serializer{output: prev_output} = serializer, new_out, space \\ true) do
    %Serializer{
      serializer
      | output: [
          prev_output,
          if(not Enum.empty?(prev_output) and space, do: [" "], else: []),
          new_out
        ]
    }
  end

  @doc """

  """
  def prepend(%Serializer{output: prev_output} = serializer, new_out, space \\ true) do
    %Serializer{
      serializer
      | output: [
          new_out,
          if(not Enum.empty?(prev_output) and space, do: [" "], else: []) | prev_output
        ]
    }
  end

  @doc """

  """
  def get_output_string({:ok, %Serializer{output: output}}) do
    :erlang.iolist_to_binary(output)
  end

  def get_output_string(%Serializer{output: output}) do
    :erlang.iolist_to_binary(output)
  end
end
