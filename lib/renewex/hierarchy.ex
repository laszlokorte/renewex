defmodule Renewex.Hierarchy do
  def is_defined(grammar, name) do
    Keyword.has_key?(grammar.hierarchy, name)
  end

  def get_super(grammar, name) do
    Map.get(grammar.hierarchy[name], :super, nil)
  end

  def is_child_of(grammar, child, parent) do
    not is_nil(child) and
      (parent == get_super(grammar, child) or
         is_child_of(grammar, get_super(grammar, child), parent))
  end

  def roots(grammar) do
    grammar.hierarchy |> Map.keys() |> Enum.filter(fn k -> is_nil(get_super(grammar, k)) end)
  end

  def all_rules(grammar) do
    grammar.hierarchy |> Map.keys()
  end

  def descendants_of(grammar, kinds) do
    grammar
    |> all_rules
    |> Enum.filter(fn
      k -> Enum.any?(kinds, fn kind -> k == kind or is_child_of(grammar, k, kind) end)
    end)
  end

  def is_descendant_of(grammar, child, parent) do
    Enum.member?(descendants_of(grammar, [parent]), child)
  end

  def implementors_of(grammar, interface) do
    grammar
    |> all_rules
    |> Enum.filter(fn
      k -> Enum.member?(interfaces_of(grammar, k), interface)
    end)
  end

  def interfaces_of(_grammar, nil), do: []

  def interfaces_of(grammar, name) do
    Enum.concat(
      grammar.hierarchy[name].interfaces,
      interfaces_of(grammar, get_super(grammar, name))
    )
  end
end
