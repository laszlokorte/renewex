defmodule Renewex.Serializer do
  @moduledoc """
  This module implements the core of the serializer for generating [Renew](http://renew.de) `*.rnw` files.
  The grammar to be used for serialization is defined by `Renewex.Grammar`.

  The counter part for reading/parsing [Renew](http://renew.de) `*.rnw` files is defined in `Renewex.Parser`.

  This `Renewex.Serializer` manages the overall serializer state and provides function for converting 
  `Renewex.Storable.__struct__/0` structs into strings.
  """
  alias Renewex.Storable
  alias Renewex.Serializer
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Grammar
  alias Renewex.Tokenizer

  @doc """
  The state of the serializer consists of 4 fields:

  - `grammar`: The grammar definition to be used for serialization.
  - `refs`: The list of all `Renewex.Storable.__struct__/0`s that might take part the serialization process. 
    This list is used to allow `Renewex.Storable.__struct__/0`s to reference each other via index into this list. 
    This may occure because the [Renew](http://renew.de) file format is based a Java object graph that might
    contain cyclic references.
  - `used_refs`: A map to mark already serialized references. Any given `Renewex.Storable.__struct__/0` is serialized 
    the first time it occures during the serialization process. 
    Afterwards it is back referenced via integer index pointing at its first occurence. 
    The `used_refs` map keeps track of already serialized references and their corresponding index.
  - `output`: An iolist into which the result of the serialization is accumulated.
  """
  defstruct [
    :grammar,
    :refs,
    :used_refs,
    :output
  ]

  @doc """
  Initiliaze a serializer state from a list of `refs` and a `grammar` definition.

  ## Parameters:
  - `refs`: A list of `Renewex.Storable.__struct__/0` that might reference each other via index into this list.
  - `grammar`: The grammar definition be used for serialization.

  # Returns
  A fresh `%Serializer{}` struct with empty output and no used refs.
  """
  def new(refs, %Grammar{} = grammar) when is_list(refs) do
    %Serializer{
      grammar: grammar,
      refs: refs,
      used_refs: Map.new(),
      output: []
    }
  end

  @doc """
  Serialize a `Storable` of `expected_type` into the `serializer`.

  ## Parameters
  - `serializer`: The serializer to write the result into.
  - `storable`: The struct to serialize.
  - `expected_type`: The name of a Java class or interface that the storable is expected to be a subtype of. 
    See `Renewex.Grammar` for details on how the [Renew](http://renew.de) file format is based on a Java class 
    hierarchy that is emulated here.

  ## Returns
  Either a tuple `{:ok, serializer}` with the serialized data appended to the `serializer`s outout if successful.
  Or `{:error, reason}` if the serialization failed for some `reason`.
  """
  def serialize_storable(serializer, storable, expected_type \\ nil)

  def serialize_storable(%Serializer{} = serializer, nil, _) do
    {:ok, append(serializer, "NULL")}
  end

  def serialize_storable(
        %Serializer{used_refs: used_refs, refs: all_refs} = serializer,
        {:ref, ref},
        expected_type
      )
      when is_integer(ref) do
    storable = Enum.at(all_refs, ref)

    if is_nil(expected_type) or
         Hierarchy.is_implementation_of(serializer.grammar, storable.class_name, expected_type) or
         Hierarchy.is_subtype_of(serializer.grammar, storable.class_name, expected_type) do
      case Map.get(used_refs, ref) do
        nil ->
          new_ref = map_size(used_refs) + 1

          serialize_storable(
            %Serializer{serializer | used_refs: Map.put(used_refs, ref, new_ref)},
            storable,
            expected_type
          )

        idx when is_integer(idx) ->
          {:ok, append(serializer, ["REF ", Integer.to_string(idx)])}
      end
    else
      {:error, {storable.class_name, expected_type}}
    end
  end

  def serialize_storable(
        %Serializer{} = serializer,
        %Storable{class_name: class_name, fields: fields},
        expected_type
      ) do
    if is_nil(expected_type) or
         Hierarchy.is_implementation_of(serializer.grammar, class_name, expected_type) or
         Hierarchy.is_subtype_of(serializer.grammar, class_name, expected_type) do
      serialize_grammar_rule(append(serializer, class_name), class_name, fields)
    else
      {:error, {class_name, expected_type}}
    end
  end

  @doc """
  Serialize a `list` of values according to callback (`ser_fn`) into the `serializer`.

  ## Parameters
  - `serializer`: The serializer to write the result into.
  - `list`: The list to be serialized
  - `ser_fn/2`: The function the defined the serialization of each list item. 
    Receives two arguments: `list_item, serializer`, where serializer is the accumulated state of the serializer.

  ## Returns
  Either a tuple `{:ok, serializer}` with the serialized data appended to the `serializer`s outout if successful.
  Or `{:error, reason}` if the serialization failed for some `reason`.
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
  Serialize a map of `fields` according to the grammar `rule` into the `serializer`.

  ## Parameters
  - `serializer`: The serializer to write the result into.
  - `rule`: The name of the grammar rule to use (the grammar definition itself comes from the serializer).
  - `fields`: The map containing the data to be serialized.

  ## Returns
  Either a tuple `{:ok, serializer}` with the serialized data appended to the `serializer`s outout if successful.
  Or `{:error, reason}` if the serialization failed for some `reason`.
  """
  def serialize_grammar_rule(%Serializer{} = serializer, rule, %{} = fields)
      when is_binary(rule) do
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
  Appends some token to the output of the serializer.

  ## Parameters
  - `serializer`: The serializer to which output to append the token.
  - `token`: `{type, value}` tuple representing the token to append.

  # Returns
  The serializer with the appended output.
  """
  def append_token(%Serializer{} = serializer, {type, value}) do
    append(serializer, Tokenizer.token_to_binary(type, value))
  end

  @doc """
  Prepends some token to the output of the serializer.

  ## Parameters
  - `serializer`: The serializer to which output to prepend the token.
  - `token`: `{type, value}` tuple representing the token to prepend.

  # Returns
  The serializer with the prepended output.
  """
  def prepend_token(%Serializer{} = serializer, {type, value}) do
    prepend(serializer, Tokenizer.token_to_binary(type, value))
  end

  # append some `string` to the serializers output
  defp append(%Serializer{output: prev_output} = serializer, string) do
    %Serializer{
      serializer
      | output: [
          prev_output,
          if(not Enum.empty?(prev_output), do: [" "], else: []),
          string
        ]
    }
  end

  # prepend some `string` to the serializers output
  defp prepend(%Serializer{output: prev_output} = serializer, string) do
    %Serializer{
      serializer
      | output: [
          string,
          if(not Enum.empty?(prev_output), do: [" "], else: []) | prev_output
        ]
    }
  end

  @doc """
  Retreive the accumulated output of the serializer as binary string.

  ## Parameters
  - `serializer_or_ok_serializer`: A tuple `{:ok, serializer}` or the `serializer` to get the output from.

  ## Returns
  The result of the serialization as binary string.
  """
  def get_output_string(serializer_or_ok_serializer)

  def get_output_string({:ok, %Serializer{output: output}}) do
    :erlang.iolist_to_binary(output)
  end

  def get_output_string(%Serializer{output: output}) do
    :erlang.iolist_to_binary(output)
  end
end
