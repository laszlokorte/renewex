defmodule Renewex.Tokenzier do
  @tokens [
    %{name: :white, pattern: ~r/\s+/},
    %{name: :float, pattern: ~r/-?\d+\.\d+/},
    %{name: :int, pattern: ~r/-?\d+/},
    %{
      name: :boolean,
      pattern: ~r/true|false|0|1/
    },
    %{name: :null, pattern: ~r/NULL/, cast: fn _ -> nil end},
    %{name: :ref, pattern: ~r/\d+/, prefix: ~r/REF\s+/},
    %{
      name: :className,
      pattern: ~r/[_a-zA-Z]+(?:\.[_a-zA-Z][_a-zA-Z0-9]*)*/
    },
    %{
      name: :string,
      pattern: ~r/\"(?:(?:\\\\)*\\\"|[^\"])*\"/
    }
  ]

  @pattern @tokens
           |> Enum.map(fn
             %{name: name, pattern: pattern, prefix: prefix} ->
               "#{prefix.source}(?<#{name}>#{pattern.source})"

             %{name: name, pattern: pattern} ->
               "(?<#{name}>#{pattern.source})"
           end)
           |> Enum.join("|")
           |> then(&"(?:#{&1})")
           |> Regex.compile!()

  @token_types Regex.names(@pattern) |> Enum.map(&String.to_atom/1)

  def scan(input) do
    for captures <- Regex.scan(@pattern, input, capture: :all_names) do
      Enum.zip(@token_types, captures)
      |> Enum.find_value(fn
        {_, ""} -> nil
        {type, value} -> {type, cast_value(type, value)}
      end)
    end
  end

  def cast_value(type, value) do
    case type do
      :white -> value
      :float -> Float.parse(value) |> elem(0)
      :int -> Integer.parse(value, 10) |> elem(0)
      :boolean -> Enum.member?(["1", "true"], value)
      :null -> nil
      :ref -> Integer.parse(value, 10) |> elem(0)
      :className -> value
      :string -> Renewex.Tokenzier.read_string_literal(value)
    end
  end

  def read_string_literal(v) do
    with {:ok, s} when is_binary(s) <- Code.string_to_quoted(v) do
      s
    else
      _ -> nil
    end
  end
end
