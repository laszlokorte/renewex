defmodule Renewex.Document do
  @moduledoc """

  """
  alias Renewex.Document

  @doc """

  """
  defstruct [:version, :root, :refs, :size]

  @doc """

  """
  def new(version, root, refs \\ [], size \\ nil)

  def new(version, root, refs, {_x, _y, _w, _h} = size) do
    %Document{
      version: version,
      root: root,
      refs: refs,
      size: size
    }
  end

  def new(version, root, refs, nil) do
    %Document{
      version: version,
      root: root,
      refs: refs,
      size: nil
    }
  end
end
