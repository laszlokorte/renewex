defmodule Renewex.Hierarchy do
  @moduledoc """
  The grammar for parsing a [Renew](http://renew.de) `*.rnw` file is defined by the 
  object oriented class hierarchy of java classes in the original Java Renew implementation.

  In order to parse all Renew `*.rnw` files correctly, this hierarchical model has to be reproduced 
  as desribed in the Renewex.Grammar module. 

  This module provides utility functions to query the hierarchy of a given `Renewex.Grammar`. For example you can query if Java 
  class of a given name is defined inside the hierarchy or if some class a sub class of another class.
  """
  alias Renewex.Grammar

  @doc """
  Check if a class of a given name is defined inside the hierarchy of the given grammar.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with
  - `name`: The fully qualified name of a Java class

  ## Returns
  `true` if the class of the given name is defined inside the `grammar`,
  `false` otherwise.
  """
  def is_defined(%Grammar{} = grammar, name) when is_binary(name) do
    Map.has_key?(grammar.hierarchy, name)
  end

  @doc """
  Get the name of the super class of the given class inside the given hierarchy.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with
  - `name`: The fully qualified name of a Java class

  ## Returns
  The name of the super class, if it is defined.
  `nil` if the class of the given name is defined but has no super class.
  `:undefined` if the class of the given name is not defined in the given `grammar`.
  """
  def get_super(%Grammar{} = grammar, name) when is_binary(name) do
    case grammar.hierarchy[name] do
      nil -> :undefined
      def -> Map.get(def, :super, nil)
    end
  end

  @doc """
  Check if one class is a subtype of another class or interface.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with
  - `subtype`: The fully qualified name of a Java class
  - `supertype`: The fully qualified name of a Java class

  ## Returns
  `true` if the class `subtype` is defined as a subtype of the class `supertype` in the given `grammar`.
  `false` if subtype is `nil` or if its not defiend to be a `subtype` of `supertype`.
  """
  def is_subtype_of(grammar, subtype, supertype)

  def is_subtype_of(%Grammar{} = grammar, same, same), do: is_defined(grammar, same)

  def is_subtype_of(%Grammar{}, nil, _), do: false

  def is_subtype_of(%Grammar{} = grammar, subtype, supertype) do
    not is_nil(subtype) and
      (supertype == get_super(grammar, subtype) or
         is_subtype_of(grammar, get_super(grammar, subtype), supertype))
  end

  @doc """
  Get a list of all classes in the grammars hierarchy that have no super class.
    Check if one class is a subtype of another class or interface.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with

  ## Returns
  A list of fully qualified Java class names that have no super classes according to the given grammar.
  """
  def roots(%Grammar{} = grammar) do
    grammar.hierarchy |> Map.keys() |> Enum.filter(fn k -> is_nil(get_super(grammar, k)) end)
  end

  @doc """
  Get a list of all classes defined in the grammars hierarchy.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with

  ## Returns
  A list of all rules defined in the given grammar as fully qualified java class names.
  """
  def all_rules(%Grammar{} = grammar) do
    grammar.hierarchy |> Map.keys()
  end

  @doc """
  Get a list of all supetypes of one or many given supertypes defined in the grammar hierarchy.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with
  - `supetypes`: Either a single fully qualified Java class name as string or a list of class names.

  ## Returns
  A list of all class names that are subtypes of the given class according to the given grammar definition.
  """
  def subtypes_of(grammar, supertypes)

  def subtypes_of(%Grammar{} = grammar, supertypes) when is_list(supertypes) do
    grammar
    |> all_rules
    |> Enum.filter(fn
      k -> Enum.any?(supertypes, fn super -> k == super or is_subtype_of(grammar, k, super) end)
    end)
  end

  def subtypes_of(%Grammar{} = grammar, supertype) when is_binary(supertype) do
    grammar
    |> all_rules
    |> Enum.filter(fn
      k -> k == supertype or is_subtype_of(grammar, k, supertype)
    end)
  end

  @doc """
  The the list of all classes that are defined to implement a given interface inside the hierarchy of the grammar.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with
  - `interface`: A single fully qualified name of a Java interface

  ## Returns
  A list of all class names that are implement the given interface according to the `grammar` definition.
  """
  def implementors_of(%Grammar{} = grammar, interface) do
    grammar
    |> all_rules
    |> Enum.filter(fn
      k -> Enum.member?(interfaces_of(grammar, k), interface)
    end)
  end

  @doc """
  Get the list of all interfaces that a given class is defined to implement by the hierarchy of the given grammar.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with
  - `name`: The fully qualified name of a Java class

  ## Returns
  If the given class is defined inside the `grammar`:
  A list of all interfaces that the given class implements according to the `grammar` definition.
  Otherwise returns `:undefined`.
  Returns an empty list if `nil` is given as `name`.
  """
  def interfaces_of(grammar, name)

  def interfaces_of(%Grammar{}, nil), do: []

  def interfaces_of(%Grammar{} = grammar, name) do
    if Map.has_key?(grammar.hierarchy, name) do
      Enum.concat(
        grammar.hierarchy[name].interfaces,
        interfaces_of(grammar, get_super(grammar, name))
      )
    else
      :undefined
    end
  end

  @doc """
  Check if `subtype` is an implementation of given `interface_or_class` or 
  if subtype is identical to the given `interface_or_class`.

  ## Parameters
  - `grammar`: The grammar that contains the definition of the rules to work with
  - `interface_or_class`: The fully qualified name of a Java class or interface

  ## Returns
  `true` if the given `subtype` is defined in the given `grammar` and is either a subclass of the 
  given super class or an implementation of the given interface.
  `false` if the given `subtype` is defined in the `grammar` but is neither a subclass nor an implementation of `interface_or_class`.
  `:undefined` if the `subtype` is not even defined inside the given `grammar` 
  """
  def is_implementation_of(%Grammar{} = grammar, subtype, interface_or_class) do
    if is_defined(grammar, subtype) do
      subtype == interface_or_class or
        Enum.member?(
          interfaces_of(grammar, subtype),
          interface_or_class
        )
    else
      :undefined
    end
  end
end
