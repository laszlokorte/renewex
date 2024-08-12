defmodule RenewexTest do
  use ExUnit.Case
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Tokenizer
  alias Renewex.Parser
  doctest Renewex

  @example_dir "./example_files"
  @full_examples_dir "./all_test_files"
  @skips [
    "BDIFS.rnw",
    "BDIFS1.rnw",
    "BDIFS2.rnw",
    "BDImain (2).rnw",
    "BDImain8 (2).rnw",
    "BDImain8.rnw",
    "CSexample.rnw",
    # de.uni_hamburg.tgi.renew.marianets.QueryFigure
    "dining-fair+safe.rnw",
    "dining.rnw",
    "mutex (2).rnw",
    ###
    "FSsample.rnw",
    "FSsyntax.rnw",
    "fsTest.rnw",
    "fsTest2.rnw",
    "fsTest3.rnw",
    "joghurt (2).rnw",
    "joghurt.rnw",
    "Main.rnw",
    "RolesGroupsFlat.rnw",
    "Types (3).rnw",
    "Types (4).rnw",
    "Types5.rnw",
    "Types8.rnw",
    "typeTest.rnw",
    "_student.rnw",
    "_Types8.rnw"
  ]

  test "tokenizer" do
    {:ok, example} = "#{@example_dir}/example.rnw" |> File.read()
    assert(3350 == Enum.count(Tokenizer.scan(example)))
  end

  test "aliases" do
    assert(Renewex.Aliases.resolve_alias("foobar") == "foobar")

    assert(
      Renewex.Aliases.resolve_alias("CH.ifa.draw.cpn.TransitionFigure") ==
        "de.renew.gui.TransitionFigure"
    )
  end

  test "hierarchy" do
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

  test "parser example" do
    {:ok, example} = "#{@example_dir}/example.rnw" |> File.read()

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

  test "parse storable" do
    {:ok, example} = "#{@example_dir}/example.rnw" |> File.read()

    assert {:ok, %Storable{}, %Parser{}} =
             example
             |> Tokenizer.scan()
             |> Tokenizer.skip_whitespace()
             |> Parser.detect_document_version()
             |> Parser.parse_storable(nil, false)
  end

  test "parse_storable on example files" do
    dir = "#{@example_dir}/"
    {:ok, files} = File.ls(dir)

    for file <- files |> Enum.filter(&(not Enum.member?(@skips, &1))) do
      assert {:ok, example} = File.read(Path.join(dir, file))

      assert {:ok, %Storable{}, parser} =
               example
               |> Tokenizer.scan()
               |> Tokenizer.skip_whitespace()
               |> Parser.detect_document_version()
               |> Parser.parse_storable(nil, false)
               |> Parser.try_skip([:int, :int, :int, :int])

      assert Parser.is_eof(parser)
    end
  end

  test "parse_string on example files" do
    dir = "#{@example_dir}"
    {:ok, files} = File.ls(dir)
    grammar = Renewex.Grammar.new(11)

    for file <- files |> Enum.filter(&(not Enum.member?(@skips, &1))) do
      assert {:ok, example} = File.read(Path.join(dir, file)), "can read #{file}"
      assert {:ok, %Storable{} = root, refs} = Renewex.parse_string(example), "can parse #{file}"
      assert is_list(refs), "ref list of #{file} is a list"

      assert Hierarchy.is_descendant_of(
               grammar,
               root.class_name,
               "CH.ifa.draw.standard.AbstractFigure"
             )
    end
  end

  test "all files" do
    {:ok, files} = File.ls(@full_examples_dir)

    for file <- files |> Enum.filter(&(not Enum.member?(@skips, &1))) do
      assert {:ok, example} = File.read(Path.join(@full_examples_dir, file)), "can read #{file}"

      assert %Parser{grammar: grammar} =
               example
               |> Tokenizer.scan()
               |> Tokenizer.skip_whitespace()
               |> Parser.detect_document_version()

      assert {:ok, %Storable{} = root, refs} = Renewex.parse_string(example), "can parse #{file}"
      assert is_list(refs), "ref list of #{file} is a list"

      assert Hierarchy.is_descendant_of(
               grammar,
               root.class_name,
               "CH.ifa.draw.standard.AbstractFigure"
             )
    end
  end
end
