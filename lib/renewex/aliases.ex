defmodule Renewex.Aliases do
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

  def resolve_alias(name), do: Map.get(@aliases, name, name)
end
