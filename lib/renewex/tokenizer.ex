defmodule Renewex.Tokenizer do
  @moduledoc """
  This module implements a simple tokenizer for splitting a string into lexems that are needed to parse [Renew](http://renew.de) `*.rnw` files.

  [Renew](http://renew.de) `*.rnw` files are text files containing a human readable serialization of Renew Java Objects.

  For reading such a file the text content must first be split into tokens/lexems that are similar to Java tokens.
  In the original  [Renew](http://renew.de) Java implementation the Java tokenizer is used but the Renew file format does not
  make use of all the tokens defined by the Java language. Hence this module defines only a sub set Java syntax tokens.

  `*.rnw` contain an object graph. Each node starts with the name of java class. This class name determines how the following tokens shall be
  parsed. Primitive values like integer, float or String are the leaf nodes.
  A  `*.rnw` may contain cyclic references. These are represented by `REF <int>` tokens that represent a reference to a previously parsed object.
  The <int> is an index into the array of already parsed objects. For example `REF 5` points to the fifth object that has occured while parsing the file.

  A `REF <int>` token must not contain an integer that is larger that the number of already parsed objects, ie. no forward references are possible. 
  """

  # The tokens recognized by this tokenizer:
  @tokens [
    # Any whitespace characters
    %{name: :white, pattern: ~r/\s+/},
    # Simplified syntax of floating point numbers
    %{name: :float, pattern: ~r/-?\d+\.\d+/},
    # Simplified syntax for integers
    %{name: :int, pattern: ~r/-?\d+/},
    # A boolean can be either true,false,0 or one
    %{
      name: :boolean,
      pattern: ~r/true|false|0|1/
    },
    # the null literal
    %{name: :null, pattern: ~r/NULL/},
    # An integer reference to a previously parsed object.
    %{name: :ref, pattern: ~r/\d+/, prefix: ~r/REF\s+/},
    # The name of a Java class
    %{
      name: :class_name,
      pattern: ~r/[_a-zA-Z]+(?:\.[_a-zA-Z][_a-zA-Z0-9]*)*/
    },
    # Simplified syntax for a String literal
    %{
      name: :string,
      pattern: ~r/\"(?:(?:\\\\)*\\\"|[^\"])*\"/
    }
  ]

  # list of tokens regarded as white space. These tokens may be skipped before parsing
  @whitespace [:white]

  # Compile the list of tokens into a single regular expression at compile time:
  @pattern @tokens
           |> Enum.map(fn
             # the token type may have defined some prefix pattern that will not be captured
             %{name: name, pattern: pattern, prefix: prefix} ->
               "#{prefix.source}(?<#{name}>#{pattern.source})"

             # or the token type has no required prefix
             %{name: name, pattern: pattern} ->
               "(?<#{name}>#{pattern.source})"
           end)
           # Join list of patterns into a single alternative
           |> Enum.join("|")
           # parenthesis required but do not capture the overall match
           |> then(&"(?:#{&1})")
           # Compile regex in unicode(u) and multiline(m) mode.
           |> Regex.compile!("um")

  # Extract the names of the capture groupes (ie. the names of the token types) back from the
  # compiled regex in the correct order.
  # Somehow the order of the capture groups may be different than the order of tokens types
  # defined in the `@tokens` list above.
  @token_types Regex.names(@pattern) |> Enum.map(&String.to_atom/1)

  @doc """
  Get the list of token types defined by the tokenizer.

  ## Returns
  [:white,:float,:int,:boolean,:null,:ref,:class_name,:string] in order determined by the capture groups in the compiled regex
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
  Takes a list of tokens and removes all tokens that are regarded as white space.
  """
  def skip_whitespace(tokens) do
    tokens
    |> Enum.reject(&is_whitespace_token/1)
  end

  # Check if the given token is a whitespace token that can be skipped
  defp is_whitespace_token({token_type, _}) do
    Enum.member?(@whitespace, token_type)
  end

  @doc """
  Convers a given string into a given type.
  """
  def cast_value(type, string) when is_binary(string) do
    case type do
      :white -> string
      :float -> Float.parse(string) |> elem(0)
      :int -> Integer.parse(string, 10) |> elem(0)
      :boolean -> Enum.member?(["1", "true"], string)
      :null -> nil
      :ref -> Integer.parse(string, 10) |> elem(0)
      :class_name -> string
      :string -> read_string_literal(string)
    end
  end

  # takes a string that contains a string literal and returns the string it represents.
  # Eg takes "\"Hello\\nWorld\"" and returns "Hello\nWorld"
  defp read_string_literal(string_literal) do
    Macro.unescape_string(String.slice(string_literal, 1, String.length(string_literal) - 2))
  end
end
