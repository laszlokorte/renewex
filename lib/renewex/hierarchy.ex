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
  """
  def is_defined(%Grammar{} = grammar, name) do
    Map.has_key?(grammar.hierarchy, name)
  end

  @doc """
  Get the name of the super class of the given class inside the given hierarchy.
  """
  def get_super(%Grammar{} = grammar, name) do
    Map.get(grammar.hierarchy[name], :super, nil)
  end

  @doc """
  Check if one class is a subtype of another class or interface.
  """
  def is_subtype_of(grammar, subtype, supertype)

  def is_subtype_of(%Grammar{} = grammar, same, same), do: is_defined(grammar, same)

  def is_subtype_of(%Grammar{} = grammar, subtype, supertype) do
    not is_nil(subtype) and
      (supertype == get_super(grammar, subtype) or
         is_subtype_of(grammar, get_super(grammar, subtype), supertype))
  end

  @doc """
  Get a list of all classes in the grammars hierarchy that have no super class.
  """
  def roots(%Grammar{} = grammar) do
    grammar.hierarchy |> Map.keys() |> Enum.filter(fn k -> is_nil(get_super(grammar, k)) end)
  end

  @doc """
  Get a list of all classes defined in the grammars hierarchy.
  """
  def all_rules(%Grammar{} = grammar) do
    grammar.hierarchy |> Map.keys()
  end

  @doc """
  Get a list of all supetypes of one or many given supertypes defined in the grammar hierarchy.
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
      nil
    end
  end

  @doc """
  Check if `subtype` is an implementation of given `interface_or_class` or if subtype is identical to the given `interface_or_class`.
  """
  def is_implementation_of(%Grammar{} = grammar, subtype, interface_or_class) do
    subtype == interface_or_class or
      Enum.member?(
        interfaces_of(grammar, subtype),
        interface_or_class
      )
  end
end
