defmodule RenewexTest do
  use ExUnit.Case
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Tokenizer
  alias Renewex.Parser
  alias Renewex.Serializer
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
      Renewex.Hierarchy.subtypes_of(grammar, [
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

  @tag :manual
  test "parse storable" do
    {:ok, example} = "#{@example_dir}/example.rnw" |> File.read()

    assert {:ok, %Storable{} = root, %Parser{ref_stack: ref_stack}} =
             example
             |> Tokenizer.scan()
             |> Tokenizer.skip_whitespace()
             |> Parser.detect_document_version()
             |> Parser.parse_storable(nil, false)

    assert root == Enum.at(ref_stack, -1)
    assert not Enum.any?(ref_stack, &(&1 == :incomplete_parsed))

    assert root.fields.figures
           |> Enum.chunk_every(2, 1, :discard)
           |> Enum.all?(fn [{:ref, a}, {:ref, b}] -> a < b end)
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
    {:ok, files} = File.ls(@example_dir)
    grammar = Renewex.Grammar.new(11)

    assert Enum.count(files) > 0, "test files exist"

    for file <- files do
      assert {:ok, example} = File.read(Path.join(@example_dir, file)), "can read #{file}"
      assert {:ok, %Storable{} = root, refs} = Renewex.parse_string(example), "can parse #{file}"
      assert is_list(refs), "ref list of #{file} is a list"

      assert root == Enum.at(refs, 0)
      assert not Enum.any?(refs, &(&1 == :incomplete_parsed))

      assert Hierarchy.is_subtype_of(
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

      assert root == Enum.at(refs, 0)
      assert not Enum.any?(refs, &(&1 == :incomplete_parsed))

      assert Hierarchy.is_subtype_of(
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

  test "simple serializer" do
    grammar = Renewex.Grammar.new(11)
    serializer = Serializer.new([], grammar)

    document =
      Storable.new("CH.ifa.draw.standard.StandardDrawing", %{
        figures: [
          Storable.new("CH.ifa.draw.figures.RoundRectangleFigure", %{
            x: 4,
            y: 8,
            w: 15,
            h: 16,
            arc_width: 23,
            arc_height: 42,
            attributes:
              Storable.new("CH.ifa.draw.figures.FigureAttributes", %{
                attributes: [
                  {"Fill", "Color", {:rgba, 32, 64, 128, 255}},
                  {"Stroke", "Int", 4},
                  {"Visible", "Boolean", true}
                ]
              })
          })
        ]
      })

    size = {42, 32, 108, 128}

    expected_output =
      [
        ~S(11 CH.ifa.draw.standard.StandardDrawing 1 ),
        ~S(CH.ifa.draw.figures.RoundRectangleFigure "attributes" "attributes" 3 ),
        ~S("Fill" "Color" 32 64 128 255 ),
        ~S("Stroke" "Int" 4 ),
        ~S("Visible" "Boolean" true ),
        ~S(4 8 15 16 23 42 42 32 108 128)
      ]
      |> Enum.join()

    actual_output =
      serializer
      |> Serializer.serialize_document(document, size)
      |> Serializer.get_output_string()

    assert expected_output == actual_output
  end

  test "serializer with refs" do
    grammar = Renewex.Grammar.new(11)

    refs = [
      Storable.new("CH.ifa.draw.figures.RoundRectangleFigure", %{
        x: 4,
        y: 8,
        w: 15,
        h: 16,
        arc_width: 23,
        arc_height: 42,
        attributes:
          Storable.new("CH.ifa.draw.figures.FigureAttributes", %{
            attributes: [
              {"Fill", "Color", {:rgba, 32, 64, 128, 255}},
              {"Stroke", "Int", 4},
              {"Visible", "Boolean", true}
            ]
          })
      }),
      Storable.new("CH.ifa.draw.standard.StandardDrawing", %{
        figures: [
          {:ref, 0}
        ]
      })
    ]

    document = {:ref, 1}
    serializer = Serializer.new(refs, grammar)

    size = {42, 32, 108, 128}

    expected_output =
      [
        ~S(11 CH.ifa.draw.standard.StandardDrawing 1 ),
        ~S(CH.ifa.draw.figures.RoundRectangleFigure "attributes" "attributes" 3 ),
        ~S("Fill" "Color" 32 64 128 255 ),
        ~S("Stroke" "Int" 4 ),
        ~S("Visible" "Boolean" true ),
        ~S(4 8 15 16 23 42 42 32 108 128)
      ]
      |> Enum.join()

    actual_output =
      serializer
      |> Serializer.serialize_document(document, size)
      |> Serializer.get_output_string()

    assert expected_output == actual_output
  end

  test "serialize_storable on example files" do
    dir = "#{@example_dir}/"
    {:ok, files} = File.ls(dir)

    assert Enum.count(files) > 0, "test files exist"

    for file <- files do
      assert {:ok, example} = File.read(Path.join(dir, file))

      assert {:ok, %Storable{} = original_root, original_refs} = Renewex.parse_string(example),
             "can parse #{file}"

      assert is_list(original_refs), "ref list of #{file} is a list"

      assert %Parser{grammar: grammar} =
               example
               |> Tokenizer.scan()
               |> Tokenizer.skip_whitespace()
               |> Parser.detect_document_version()

      serializer = Serializer.new(original_refs, grammar)

      actual_output =
        serializer
        |> Serializer.serialize_document(original_root)
        |> Serializer.get_output_string()

      if not Enum.member?(
           # TODO figure out whats not working with these files
           [
             "ams_brewcoffee.rnw",
             "closedoor.rnw",
             "example.aip",
             "example2.aip",
             "NetWithOrSplit.rnw"
           ],
           file
         ) do
        assert {:ok, %Storable{} = ^original_root, ^original_refs} =
                 Renewex.parse_string(actual_output),
               "can parse resilized #{file}"
      end
    end
  end
end
