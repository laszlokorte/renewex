defmodule RenewexTest do
  use ExUnit.Case
  doctest Renewex

  alias Renewex.Document
  alias Renewex.Hierarchy
  alias Renewex.Storable
  alias Renewex.Tokenizer
  alias Renewex.Parser

  @example_dir Path.join([__DIR__, "fixtures", "selected_examples"])
  @full_examples_dir Path.join([__DIR__, "fixtures", "valid_files"])
  @invalid_examples_dir Path.join([__DIR__, "fixtures", "invalid_files"])
  @invalid_encodings_dir Path.join([__DIR__, "fixtures", "not_unicode"])

  describe "tokenizer" do
    test "tokenize example file" do
      {:ok, example} = "#{@example_dir}/example.rnw" |> File.read()

      assert(
        3350 == Enum.count(Tokenizer.scan(example)),
        "expected example.rnw to consist of 3350 tokens"
      )
    end
  end

  describe "aliases" do
    test "undefined alias resolves to itself" do
      assert(Renewex.Aliases.resolve_alias("foobar") == "foobar")
    end

    test "defined alias resolves correctly" do
      assert(
        Renewex.Aliases.resolve_alias("CH.ifa.draw.cpn.TransitionFigure") ==
          "de.renew.gui.TransitionFigure"
      )
    end
  end

  describe "hierarchy" do
    test "implementors_of of PolyLineable" do
      grammar = Renewex.Grammar.new(11)

      assert(
        Enum.sort(Renewex.Hierarchy.implementors_of(grammar, "CH.ifa.draw.figures.PolyLineable")) ==
          Enum.sort([
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
            "de.renew.gui.fs.FeatureConnection",
            "de.renew.bpmn.figures.AbstractBPMNConnection",
            "de.renew.bpmn.figures.SequenceFlowConnection",
            "de.renew.bpmn.figures.MessageFlowConnection",
            "de.renew.fa.figures.FAArcConnection"
          ])
      )
    end

    test "subtypes_of Connections" do
      grammar = Renewex.Grammar.new(11)

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

    test "undefined rules" do
      grammar = Renewex.Grammar.new(11)

      assert :undefined ==
               Hierarchy.is_implementation_of(
                 grammar,
                 "some.not.defined.Rule",
                 "some.Interface"
               ),
             "expect undefined rules to be reported as not beeing implementation of some interface"

      assert :undefined ==
               Hierarchy.get_super(
                 grammar,
                 "some.not.defined.Rule"
               ),
             "expect undefined Rule to have no super type"
    end
  end

  describe "parser" do
    test "parsee example file" do
      {:ok, example} = "#{@example_dir}/example.rnw" |> File.read()

      parser =
        example
        |> Tokenizer.scan()
        |> Tokenizer.skip_whitespace()
        |> Parser.detect_document_version()

      assert parser.grammar.version == 11,
             "expected to detect example.rnw to be of file format version 11"
    end

    test "parse list" do
      assert {:ok, list_of_5_bools, _} =
               "5 true false 1 0 true"
               |> Tokenizer.scan()
               |> Tokenizer.skip_whitespace()
               |> Parser.new(Renewex.Grammar.new(11))
               |> Parser.parse_list(fn p ->
                 Parser.parse_primitive(p, :boolean)
               end)

      assert(
        list_of_5_bools == [true, false, true, false, true],
        "expected list of 5 booleans to be parsed"
      )
    end

    test "refs are assigned correctly" do
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
             |> Enum.all?(fn [{:ref, a}, {:ref, b}] -> a < b end),
             "expected refs to be sorted correctly"
    end

    test "parse_storable on selected example files" do
      {:ok, files} = File.ls(@example_dir)

      assert Enum.count(files) > 0, "test files exist"

      for file <- skip_excluded_files(files) do
        assert {:ok, example} = File.read(Path.join(@example_dir, file))

        assert {:ok, %Storable{}, parser} =
                 example
                 |> Tokenizer.scan()
                 |> Tokenizer.skip_whitespace()
                 |> Parser.detect_document_version()
                 |> Parser.parse_storable(nil, false)
                 |> Parser.try_skip([:int, :int, :int, :int])

        assert Parser.is_eof(parser),
               "expected token stream of '#{file}' to be fully consumed"
      end
    end

    test "parse_document on example files" do
      {:ok, files} = File.ls(@example_dir)
      grammar = Renewex.Grammar.new(11)

      assert Enum.count(files) > 0, "test files exist"

      for file <- skip_excluded_files(files) do
        assert {:ok, example} = File.read(Path.join(@example_dir, file)), "can read #{file}"

        assert {:ok, %Renewex.Document{root: root, refs: refs}} = Renewex.parse_document(example),
               "can parse #{file}"

        assert is_list(refs), "ref list of #{file} is a list"

        assert root == Enum.at(refs, 0)
        assert not Enum.any?(refs, &(&1 == :incomplete_parsed))

        assert Hierarchy.is_subtype_of(
                 grammar,
                 root.class_name,
                 "CH.ifa.draw.standard.AbstractFigure"
               ),
               "expected root node of #{file} to be a subtype of AbstractFigure"
      end
    end

    @tag :slow
    test "parse_document on all files" do
      {:ok, files} = File.ls(@full_examples_dir)

      assert Enum.count(files) > 0, "test files exist"

      for file <- skip_excluded_files(files) do
        assert {:ok, example} = File.read(Path.join(@full_examples_dir, file)), "can read #{file}"

        assert %Parser{grammar: grammar} =
                 example
                 |> Tokenizer.scan()
                 |> Tokenizer.skip_whitespace()
                 |> Parser.detect_document_version()

        assert {:ok, %Renewex.Document{root: root, refs: refs}} = Renewex.parse_document(example),
               "can parse #{file}"

        assert is_list(refs), "ref list of #{file} is a list"

        assert root == Enum.at(refs, 0)
        assert not Enum.any?(refs, &(&1 == :incomplete_parsed))

        assert Hierarchy.is_subtype_of(
                 grammar,
                 root.class_name,
                 "CH.ifa.draw.standard.AbstractFigure"
               ),
               "expected root node of #{file} to be a subtype of AbstractFigure"
      end
    end

    test "parse_document on invalid files" do
      {:ok, files} = File.ls(@invalid_examples_dir)
      assert Enum.count(files) > 0, "test files exist"

      for file <- skip_excluded_files(files) do
        assert {:ok, example} = File.read(Path.join(@invalid_examples_dir, file)),
               "can read #{file}"

        assert {:error, _, _} = Renewex.parse_document(example),
               "expect #{file} to be invalid and return parsing error"
      end
    end

    test "parse_document on invalid encodings" do
      {:ok, files} = File.ls(@invalid_encodings_dir)
      assert Enum.count(files) > 0, "test files exist"

      for file <- skip_excluded_files(files) do
        assert {:ok, example} = File.read(Path.join(@invalid_encodings_dir, file)),
               "can read #{file}"

        assert_raise ArgumentError, fn ->
          Renewex.parse_document(example)
        end
      end
    end
  end

  describe "serializer" do
    test "simple serializer" do
      root =
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

      document = Document.new(11, root, [], {42, 32, 108, 128})

      expected_output =
        [
          ~S(11 CH.ifa.draw.standard.StandardDrawing 1 ),
          ~S(CH.ifa.draw.figures.RoundRectangleFigure "attributes" "attributes" 3 ),
          ~S("Fill" "Color" 32 64 128 255 ),
          ~S("Stroke" "Int" 4 ),
          ~S("Visible" "Boolean" "true" ),
          ~S(4 8 15 16 23 42 42 32 108 128)
        ]
        |> Enum.join()

      assert {:ok, actual_output} = Renewex.serialize_document(document)

      assert expected_output == actual_output, "expected document to be serialized correctly"
    end

    test "serializer with refs" do
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

      document = Document.new(11, {:ref, 1}, refs, {42, 32, 108, 128})

      expected_output =
        [
          ~S(11 CH.ifa.draw.standard.StandardDrawing 1 ),
          ~S(CH.ifa.draw.figures.RoundRectangleFigure "attributes" "attributes" 3 ),
          ~S("Fill" "Color" 32 64 128 255 ),
          ~S("Stroke" "Int" 4 ),
          ~S("Visible" "Boolean" "true" ),
          ~S(4 8 15 16 23 42 42 32 108 128)
        ]
        |> Enum.join()

      assert {:ok, actual_output} = Renewex.serialize_document(document)

      assert expected_output == actual_output, "expected document to be serialized correctly"
    end

    test "serialize_storable on example files" do
      {:ok, files} = File.ls(@example_dir)

      assert Enum.count(files) > 0, "test files exist"

      for file <- skip_excluded_files(files) do
        assert {:ok, example} = File.read(Path.join(@example_dir, file))

        assert {:ok, %Renewex.Document{root: original_root, refs: original_refs} = document} =
                 Renewex.parse_document(example),
               "can parse #{file}"

        assert is_list(original_refs), "ref list of #{file} is a list"

        assert {:ok, actual_output} = Renewex.serialize_document(document)

        assert {:ok, %Renewex.Document{root: ^original_root, refs: ^original_refs}} =
                 Renewex.parse_document(actual_output),
               "expected result of parsing #{file} to be the same as reparsing the result of serializing it"
      end
    end

    @tag :slow
    test "serialize_storable on all files" do
      {:ok, files} = File.ls(@full_examples_dir)

      assert Enum.count(files) > 0, "test files exist"

      for file <- skip_excluded_files(files) do
        assert {:ok, example} = File.read(Path.join(@full_examples_dir, file))

        assert {:ok, %Renewex.Document{root: original_root, refs: original_refs} = document} =
                 Renewex.parse_document(example),
               "can parse #{file}"

        assert is_list(original_refs), "ref list of #{file} is a list"

        assert {:ok, actual_output} = Renewex.serialize_document(document)

        assert {:ok, %Renewex.Document{root: ^original_root, refs: ^original_refs}} =
                 Renewex.parse_document(actual_output),
               "expected result of parsing #{file} to be the same as reparsing the result of serializing it"
      end
    end
  end

  defp skip_excluded_files(files) do
    Enum.filter(files, fn name -> not String.starts_with?(name, "SKIP") end)
  end
end
