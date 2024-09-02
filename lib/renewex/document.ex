defmodule Renewex.Document do
  @moduledoc """
  `Renewex.Document` captures the concept of a full [Renew](http://renew.de) document as described by the content of an `*.rnw` file. 
  """
  alias Renewex.Document

  @doc """
  A `Renewex.Document` consists of:
  - `version`: The file format version (see `Renewex.Grammar.latest_version/0`),
  - `root`: a root node (a `Renewex.Storable.__struct__/0` or a `{:ref, ...}` to a `Renewex.Storable.__struct__/0`), 
  - `refs`: a list of `Renewex.Storable.__struct__/0` that can reference each other via index into this list,
  - `size`: an optional tuple `{x, y, width, height}` (or `nil`) describing the window dimensions of the Renew application window when the file was saved.
  """
  defstruct [
    :version,
    :root,
    :refs,
    :size
  ]

  @doc """
  Initialize a new `Renewex.Document` struct.

  ## Parameters
  - `version`: The file format version (see `Renewex.Grammar.latest_version/0`)
  - `root`: a root node (a `Renewex.Storable.__struct__/0` or a `{:ref, ...}` to a `Renewex.Storable.__struct__/0`), 
  - `refs`: a list of `Renewex.Storable.__struct__/0` that can reference each other via index into this list,
  - `size`: an optional tuple `{x, y, width, height}` (or `nil`) describing the window dimensions of the Renew application window when the file was saved.
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
