defmodule Renewex.Tokenizer do
  @moduledoc """

  """
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
      name: :class_name,
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
           |> Regex.compile!("um")

  @token_types Regex.names(@pattern) |> Enum.map(&String.to_atom/1)

  @doc """

  """
  def token_types do
    @token_types
  end

  @doc """

  """
  def scan(input) do
    Regex.scan(@pattern, input, capture: :all_names)
    |> Stream.map(fn captures ->
      Enum.zip(@token_types, captures)
      |> Enum.filter(fn {_, value} -> value != "" end)
      |> Enum.find_value(fn {type, value} -> {type, cast_value(type, value)} end)
    end)
  end

  @doc """

  """
  def skip_whitespace(tokens) do
    tokens
    |> Enum.filter(fn
      {:white, _} -> false
      _ -> true
    end)
  end

  @doc """

  """
  def cast_value(type, value) do
    case type do
      :white -> value
      :float -> Float.parse(value) |> elem(0)
      :int -> Integer.parse(value, 10) |> elem(0)
      :boolean -> Enum.member?(["1", "true"], value)
      :null -> nil
      :ref -> Integer.parse(value, 10) |> elem(0)
      :class_name -> value
      :string -> read_string_literal(value)
    end
  end

  defp read_string_literal(v) do
    with {:ok, s} when is_binary(s) <- Code.string_to_quoted(v) do
      s
    end
  end
end
