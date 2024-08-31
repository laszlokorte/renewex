defmodule Renewex.Serializer do
  alias Renewex.Serializer
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Grammar

  defstruct [
    :grammar,
    :refs,
    :used_refs,
    :output
  ]

  def new(refs, grammar) do
    %Serializer{
      grammar: grammar,
      refs: refs,
      used_refs: Map.new(),
      output: []
    }
  end

  def serialize_document(serializer, storable, size \\ nil)

  def serialize_document(
        %Serializer{} = serializer,
        storable,
        nil
      ) do
    %Serializer{grammar: %Grammar{version: version}} = serializer

    with {:ok, ser} <- serialize_storable(serializer, storable) do
      if version == -1 do
        {:ok, ser}
      else
        {:ok, prepend(ser, Integer.to_string(version))}
      end
    else
      err -> err
    end
  end

  def serialize_document(%Serializer{} = serializer, storable, {x, y, w, h})
      when is_integer(x) and is_integer(y) and is_integer(w) and is_integer(h) do
    size = Enum.map([x, y, w, h], &Integer.to_string/1) |> Enum.intersperse(" ")

    with {:ok, ser} <- serialize_document(serializer, storable, nil) do
      {:ok, append(ser, size)}
    else
      err -> err
    end
  end

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

  def serialize_list(%Serializer{} = serializer, list, ser_fn) do
    list
    |> Enum.reduce({:ok, append_value(serializer, Enum.count(list), :int)}, fn
      item, {:ok, ser} ->
        ser_fn.(item, ser)

      _, {:error, _} = e ->
        e
    end)
  end

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

  def append_value(%Serializer{} = serializer, value, expected_type, space \\ true) do
    append(serializer, to_io_list(value, expected_type), space)
  end

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

  def prepend(%Serializer{output: prev_output} = serializer, new_out, space \\ true) do
    %Serializer{
      serializer
      | output: [
          new_out,
          if(not Enum.empty?(prev_output) and space, do: [" "], else: []) | prev_output
        ]
    }
  end

  def to_io_list(value, :string) when is_binary(value),
    do: inspect(value, charlists: :as_charlists)

  def to_io_list(value, :float) when is_float(value), do: Float.to_string(value)
  def to_io_list(value, :storable) when is_nil(value), do: "NULL"
  def to_io_list(value, :int) when is_integer(value), do: Integer.to_string(value)
  def to_io_list(value, :boolean) when is_boolean(value), do: if(value, do: "1", else: "0")

  def get_output_string({:ok, %Serializer{output: output}}) do
    :erlang.iolist_to_binary(output)
  end

  def get_output_string(%Serializer{output: output}) do
    :erlang.iolist_to_binary(output)
  end
end
