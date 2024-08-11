defmodule RenewexTest do
  use ExUnit.Case
  alias Renewex.Tokenizer
  alias Renewex.Parser
  doctest Renewex

  test "initial test" do
    {:ok, example} = "./example_files/example.rnw" |> File.read()
    assert(3350 == Enum.count(Tokenizer.scan(example)))
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

  test "parser test" do
    {:ok, example} = "./example_files/example.rnw" |> File.read()

    parser =
      example
      |> Tokenizer.scan()
      |> Tokenizer.skip_whitespace()
      |> Parser.detect_document_version()

    assert parser.grammar.version == 11
  end

  test "list parsing" do
    assert {:ok, list_of_5_bools, _} =
             "5 true false 1 0 true"
             |> Tokenizer.scan()
             |> Tokenizer.skip_whitespace()
             |> Parser.new(Renewex.Grammar.new(11))
             |> Parser.parse_list(fn p ->
               Parser.parse_primitive(p, :boolean)
             end)

    assert(list_of_5_bools == [true, false, true, false, true])
  end

  test "test parse storable" do
    {:ok, example} = "./example_files/example.rnw" |> File.read()

    assert {:ok, result, parser} =
             example
             |> Tokenizer.scan()
             |> Tokenizer.skip_whitespace()
             |> Parser.detect_document_version()
             |> Parser.parse_storable()
  end

  test "test example files" do
    dir = "./example_files/"
    {:ok, files} = File.ls(dir)

    for file <- files do
      assert {:ok, example} = File.read(Path.join(dir, file))

      assert {:ok, result, parser} =
               example
               |> Tokenizer.scan()
               |> Tokenizer.skip_whitespace()
               |> Parser.detect_document_version()
               |> Parser.parse_storable()
               |> Parser.try_skip([:int, :int, :int, :int])

      assert Parser.is_eof(parser)
    end
  end

  test "integrations" do
    dir = "./example_files/"
    {:ok, files} = File.ls(dir)

    for file <- files do
      assert {:ok, example} = File.read(Path.join(dir, file))
      assert {:ok, root, refs} = Renewex.parse_string(example)
    end
  end
end
