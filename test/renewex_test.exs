defmodule RenewexTest do
  use ExUnit.Case
  doctest Renewex

  test "initial test" do
    {:ok, example} = "./example_files/example.rnw" |> File.read()
    assert(3350 == Enum.count(Renewex.parse_string(example)))
  end

  test "aliases" do
    assert(Renewex.Aliases.resolve_alias("foobar") == "foobar")

    assert(
      Renewex.Aliases.resolve_alias("CH.ifa.draw.cpn.TransitionFigure") ==
        "de.renew.gui.TransitionFigure"
    )
  end

  test "hierarchy test" do
    grammar = Renewex.Grammar.new(11)

    assert(
      Renewex.Hierarchy.implementors_of(grammar, "CH.ifa.draw.figures.PolyLineable") == [
        "de.renew.gui.DoubleArcConnection",
        "CH.ifa.draw.figures.PolyLineFigure",
        "CH.ifa.draw.figures.LineFigure",
        "de.renew.diagram.SynchronousReplyConnection",
        "CH.ifa.draw.figures.LineConnection",
        "de.renew.gui.HollowDoubleArcConnection",
        "de.renew.diagram.AbstractMessageConnection",
        "de.renew.diagram.LifeLineConnection",
        "fs.IsaConnection",
        "de.renew.gui.ArcConnection",
        "CH.ifa.draw.figures.ElbowConnection",
        "de.renew.gui.fs.AssocConnection",
        "de.renew.gui.InhibitorConnection",
        "de.renew.gui.fs.IsaConnection",
        "de.renew.diagram.MessageConnection",
        "de.renew.diagram.SynchronousMessageConnection",
        "de.renew.gui.fs.ConceptConnection",
        "CH.ifa.draw.contrib.PolygonFigure",
        "de.renew.gui.fs.FeatureConnection"
      ]
    )

    assert(
      Renewex.Hierarchy.descendants_of(grammar, [
        "de.renew.gui.fs.IsaConnection",
        "de.renew.gui.ArcConnection"
      ]) ==
        [
          "de.renew.gui.DoubleArcConnection",
          "de.renew.gui.HollowDoubleArcConnection",
          "de.renew.gui.ArcConnection",
          "de.renew.gui.InhibitorConnection",
          "de.renew.gui.fs.IsaConnection"
        ]
    )
  end
end
