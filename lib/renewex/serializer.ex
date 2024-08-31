defmodule Renewex.Serializer do
  alias Renewex.Parser
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

    if version == -1 do
      serialize(serializer, storable)
    else
      prepend(serialize(serializer, storable), Integer.to_string(version))
    end
  end

  def serialize_document(%Serializer{} = serializer, storable, {x, y, w, h})
      when is_integer(x) and is_integer(y) and is_integer(w) and is_integer(h) do
    size = Enum.map([x, y, w, h], &Integer.to_string/1) |> Enum.intersperse(" ")
    append(serialize_document(serializer, storable, nil), size)
  end

  def serialize(serializer, storable)

  def serialize(%Serializer{} = serializer, :null) do
    append(serializer, "NULL")
  end

  def serialize(%Serializer{used_refs: used_refs, refs: all_refs} = serializer, {:ref, ref})
      when is_integer(ref) do
    case Map.get(used_refs, ref) do
      nil ->
        storable = Enum.at(all_refs, ref)
        new_ref = map_size(used_refs) + 1

        serialize(
          %Serializer{used_refs: Map.put(used_refs, ref, new_ref)},
          storable
        )

      idx when is_integer(idx) ->
        append(serializer, ["REF", Integer.to_string(idx)])
    end
  end

  def serialize(
        %Serializer{} = serializer,
        %Storable{class_name: class_name, fields: fields}
      ) do
    serialize_grammar_rule(append(serializer, class_name), class_name, fields)
  end

  def serialize_grammar_rule(%Serializer{} = serializer, rule, fields) do
    if Hierarchy.is_defined(serializer.grammar, rule) do
      cond do
        Grammar.should_skip_super(serializer.grammar, rule) ->
          Grammar.serialize(serializer, rule, fields)

        super_rule =
            Hierarchy.get_super(serializer.grammar, rule) ->
          serialize_grammar_rule(serializer, super_rule, fields)
          |> Grammar.serialize(rule, fields)

        true ->
          Grammar.serialize(serializer, rule, fields)
      end
    else
      raise "unexpected"
    end
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

  def get_output_string(%Serializer{output: output}) do
    :erlang.iolist_to_binary(output)
  end
end
