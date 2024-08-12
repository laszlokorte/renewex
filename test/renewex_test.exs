defmodule RenewexTest do
  use ExUnit.Case
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Tokenizer
  alias Renewex.Parser
  doctest Renewex

  @example_dir Path.join([__DIR__, "fixtures", "selected_examples"])
  @full_examples_dir Path.join([__DIR__, "fixtures", "valid_files"])
  @invalid_examples_dir Path.join([__DIR__, "fixtures", "invalid_files"])
  @invalid_encodings_dir Path.join([__DIR__, "fixtures", "not_unicode"])

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

    assert Enum.count(files) > 0, "test files exist"

    for file <- files do
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

    assert Enum.count(files) > 0, "test files exist"

    for file <- files do
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

  @tag :slow
  test "all files" do
    {:ok, files} = File.ls(@full_examples_dir)

    assert Enum.count(files) > 0, "test files exist"

    for file <- files do
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

  test "invalid files" do
    {:ok, files} = File.ls(@invalid_examples_dir)
    assert Enum.count(files) > 0, "test files exist"

    for file <- files do
      assert {:ok, example} = File.read(Path.join(@invalid_examples_dir, file)),
             "can read #{file}"

      assert {:error, _, _} = Renewex.parse_string(example), "can not parse #{file}"
    end
  end

  test "invalid encodings" do
    {:ok, files} = File.ls(@invalid_encodings_dir)
    assert Enum.count(files) > 0, "test files exist"

    for file <- files do
      assert {:ok, example} = File.read(Path.join(@invalid_encodings_dir, file)),
             "can read #{file}"

      assert_raise ArgumentError, fn ->
        Renewex.parse_string(example)
      end
    end
  end
end
