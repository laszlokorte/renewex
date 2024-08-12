defmodule Renewex.Aliases do
  @moduledoc """
  This module defines aliases for [Renew](http://renew.de) class names.

  Some [Renew](http://renew.de) classes have been renamed at some point in time. 
  To be able to load both old and new renew file versions this module keeps a mapping from old to the corresponding
  class names.
  """

  @aliases %{
    "de.renew.gui.fs.AssocArrowTip" => "de.renew.gui.AssocArrowTip",
    "de.renew.gui.fs.IsaArrowTip" => "de.renew.gui.IsaArrowTip",
    "de.renew.diagram.AssocArrowTip" => "de.renew.gui.AssocArrowTip",
    "de.renew.fa.figures.AssocArrowTip" => "de.renew.gui.AssocArrowTip",
    "CH.ifa.draw.cpn.DeclarationFigure" => "de.renew.gui.DeclarationFigure",
    "CH.ifa.draw.cpn.CPNDrawing" => "de.renew.gui.CPNDrawing",
    "CH.ifa.draw.cpn.PlaceFigure" => "de.renew.gui.PlaceFigure",
    "CH.ifa.draw.cpn.TransitionFigure" => "de.renew.gui.TransitionFigure",
    "CH.ifa.draw.cpn.ArcConnection" => "de.renew.gui.ArcConnection",
    "CH.ifa.draw.cpn.CPNTextFigure" => "de.renew.gui.CPNTextFigure"
  }

  @doc """
  This function converts an old [Renew](http://renew.de) class name to its corresponding new class name.
  In case the class name has never been renamed the original name is returned.

  ## Parameters
  - `input`: Fully qualified name of a [Renew](http://renew.de) Java class

  ## Returns
  - The fully qualified new name of the class if it has been renamed
  - The given name otherwise. 
  """
  def resolve_alias(name), do: Map.get(@aliases, name, name)
end
