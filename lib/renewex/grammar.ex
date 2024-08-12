defmodule Renewex.Grammar do
  @moduledoc """

  """

  alias Renewex.Storable
  alias Renewex.Parser
  defstruct [:version, :hierarchy]

  @doc """

  """
  def new(version) do
    %Renewex.Grammar{
      version: version,
      hierarchy: %{
        "CH.ifa.draw.standard.AbstractFigure" => %{
          super: nil,
          interfaces: ["CH.ifa.draw.framework.Figure", "CH.ifa.draw.framework.ParentFigure"]
        },
        "CH.ifa.draw.standard.CompositeFigure" => %{
          super: "CH.ifa.draw.standard.AbstractFigure",
          interfaces: ["CH.ifa.draw.framework.Figure"],
          fields: [figures: {:list, {:storable, "CH.ifa.draw.framework.Figure"}}]
        },
        "CH.ifa.draw.figures.GroupFigure" => %{
          super: "CH.ifa.draw.standard.CompositeFigure",
          interfaces: []
        },
        "CH.ifa.draw.standard.StandardDrawing" => %{
          super: "CH.ifa.draw.standard.CompositeFigure",
          interfaces: ["CH.ifa.draw.framework.Figure"]
        },
        "CH.ifa.draw.figures.FigureAttributes" => %{
          interfaces: []
        },
        "CH.ifa.draw.figures.AttributeFigure" => %{
          super: "CH.ifa.draw.standard.AbstractFigure",
          interfaces: []
        },
        "CH.ifa.draw.figures.RectangleFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          fields: [x: :int, y: :int, w: :int, h: :int]
        },
        "CH.ifa.draw.contrib.DiamondFigure" => %{
          super: "CH.ifa.draw.figures.RectangleFigure",
          interfaces: []
        },
        "de.renew.hierarchicalworkflownets.gui.HNViewDrawing" => %{
          super: "de.renew.gui.CPNDrawing",
          skip_super: true,
          interfaces: [],
          fields: [
            hn_model: {:rule, "de.renew.hierarchicalworkflownets.gui.HNModel"},
            figures: {:list, {:storable, "CH.ifa.draw.framework.Figure"}}
          ]
        },
        "de.renew.hierarchicalworkflownets.gui.HNModel" => %{
          super: nil,
          interfaces: [],
          fields: [
            node: {:rule, "de.renew.hierarchicalworkflownets.tree.TreeNode"},
            drawings: {:list, {:storable, "de.renew.gui.ArcConnection"}}
          ]
        },
        "de.renew.hierarchicalworkflownets.tree.TreeNode" => %{
          super: nil,
          interfaces: [],
          fields: [
            nodes:
              {:list,
               [
                 name: :string,
                 node: {:storable, "CH.ifa.draw.framework.Figure"},
                 child: {:rule, "de.renew.hierarchicalworkflownets.tree.TreeNode"}
               ]}
          ]
        },
        "de.renew.hierarchicalworkflownets.gui.HNPlaceFigure" => %{
          super: "de.renew.gui.PlaceFigure",
          interfaces: []
        },
        "de.renew.workflow.TaskFigure" => %{
          super: "de.renew.gui.TransitionFigure",
          interfaces: []
        },
        "de.renew.wfnet.TaskFigure" => %{
          super: "de.renew.gui.TransitionFigure",
          interfaces: []
        },
        "CH.ifa.draw.contrib.PolygonFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: ["CH.ifa.draw.figures.PolyLineable"],
          fields: [points: {:list, [x: :int, y: :int]}]
        },
        "de.renew.hierarchicalworkflownets.gui.HNTransitionFigure" => %{
          super: "de.renew.gui.TransitionFigure",
          interfaces: []
        },
        "de.renew.hierarchicalworkflownets.gui.layout.Vec2d" => %{
          super: nil,
          interfaces: [],
          fields: [x: :float, y: :float]
        },
        "CH.ifa.draw.figures.EllipseFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          fields: [x: :int, y: :int, w: :int, h: :int]
        },
        "CH.ifa.draw.figures.RoundRectangleFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          fields: [x: :int, y: :int, w: :int, h: :int, arc_width: :int, arc_height: :int]
        },
        "de.renew.gui.TransitionFigure" => %{
          super: "CH.ifa.draw.figures.RectangleFigure",
          interfaces: [
            "CH.ifa.draw.framework.Figure",
            "de.renew.gui.InscribableFigure",
            "CH.ifa.draw.framework.ParentFigure"
          ],
          fields:
            if(version >= 4,
              do: [highlight_figure: {:storable, "CH.ifa.draw.framework.Figure"}],
              else: []
            )
        },
        "de.renew.gui.PlaceFigure" => %{
          super: "CH.ifa.draw.figures.EllipseFigure",
          interfaces: [
            "CH.ifa.draw.framework.Figure",
            "de.renew.gui.InscribableFigure",
            "CH.ifa.draw.framework.ParentFigure"
          ],
          fields:
            if(version >= 3,
              do: [highlight_figure: {:storable, "CH.ifa.draw.framework.Figure"}],
              else: []
            )
        },
        "de.renew.gui.VirtualPlaceFigure" => %{
          super: "de.renew.gui.PlaceFigure",
          interfaces: [],
          fields: [highlight_figure: {:storable, "de.renew.gui.PlaceFigure"}]
        },
        "de.renew.gui.ArcConnection" => %{
          super: "CH.ifa.draw.figures.LineConnection",
          interfaces: [
            "CH.ifa.draw.framework.Figure",
            "de.renew.gui.InscribableFigure",
            "CH.ifa.draw.framework.ParentFigure"
          ]
        },
        "de.renew.gui.DoubleArcConnection" => %{
          super: "de.renew.gui.ArcConnection",
          interfaces: []
        },
        "de.renew.gui.HollowDoubleArcConnection" => %{
          super: "de.renew.gui.ArcConnection",
          interfaces: []
        },
        "de.renew.gui.InhibitorConnection" => %{
          super: "de.renew.gui.ArcConnection",
          interfaces: []
        },
        "de.renew.gui.fs.ConceptConnection" => %{
          super: "CH.ifa.draw.figures.LineConnection",
          interfaces: ["CH.ifa.draw.framework.Figure"]
        },
        "de.renew.gui.fs.IsaConnection" => %{
          super: "de.renew.gui.fs.ConceptConnection",
          interfaces: [],
          fields: [is_disjunctive: :boolean]
        },
        "fs.IsaConnection" => %{
          super: "de.renew.gui.fs.ConceptConnection",
          interfaces: []
        },
        "de.renew.gui.IsaArrowTip" => %{
          super: "CH.ifa.draw.figures.ArrowTip",
          interfaces: []
        },
        "de.renew.gui.fs.IsaArrowTip" => %{
          super: "CH.ifa.draw.figures.ArrowTip",
          interfaces: []
        },
        "fs.IsaArrowTip" => %{
          super: "CH.ifa.draw.figures.ArrowTip",
          interfaces: []
        },
        "de.renew.gui.DoubleArrowTip" => %{
          super: "CH.ifa.draw.figures.ArrowTip",
          interfaces: []
        },
        "CH.ifa.draw.figures.AbstractLocator" => %{
          super: nil,
          interfaces: ["CH.ifa.draw.framework.Locator"]
        },
        "de.renew.gui.fs.ConceptFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: ["CH.ifa.draw.framework.Locator"]
        },
        "fs.ConceptFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: ["CH.ifa.draw.framework.Locator"],
          fields: if(version < 0, do: [type: :int], else: [])
        },
        "fs.PartitionFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: ["CH.ifa.draw.framework.Locator"],
          fields: [x: :int, y: :int, w: :int, h: :int]
        },
        "de.renew.gui.fs.FSNodeFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: ["CH.ifa.draw.framework.Locator"]
        },
        "CH.ifa.draw.contrib.ChopPolygonConnector" => %{
          super: "CH.ifa.draw.standard.ChopBoxConnector",
          interfaces: []
        },
        "CH.ifa.draw.figures.ShortestDistanceConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "CH.ifa.draw.figures.ElbowConnection" => %{
          super: "CH.ifa.draw.figures.LineConnection",
          interfaces: []
        },
        "de.renew.gui.fs.FeatureConnection" => %{
          super: "CH.ifa.draw.figures.LineConnection",
          interfaces: []
        },
        "CH.ifa.draw.figures.ChopRoundRectangleConnector" => %{
          super: "CH.ifa.draw.standard.ChopBoxConnector",
          interfaces: []
        },
        "de.renew.gui.fs.UMLNoteFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: []
        },
        "de.renew.gui.fs.AssocConnection" => %{
          super: "de.renew.gui.fs.ConceptConnection",
          interfaces: []
        },
        "de.renew.gui.AssocArrowTip" => %{
          super: "CH.ifa.draw.figures.ArrowTip",
          interfaces: []
        },
        "de.renew.gui.fs.AssocArrowTip" => %{
          super: "CH.ifa.draw.figures.ArrowTip",
          interfaces: []
        },
        "de.renew.bpmn.roundtrip.RoundtripNetComponentFigure" => %{
          super: "de.renew.netcomponents.NetComponentFigure",
          interfaces: [],
          fields: [skip: [:ref, :string]]
        },
        "CH.ifa.draw.standard.OffsetLocator" => %{
          super: "CH.ifa.draw.figures.AbstractLocator",
          interfaces: ["CH.ifa.draw.framework.Locator"],
          fields: [
            fOffsetX: :int,
            fOffsetY: :int,
            fBase: {:storable, "CH.ifa.draw.framework.Locator"}
          ]
        },
        "CH.ifa.draw.standard.RelativeLocator" => %{
          super: "CH.ifa.draw.figures.AbstractLocator",
          interfaces: ["CH.ifa.draw.framework.Locator"],
          fields: [fOffsetX: :float, fOffsetY: :float]
        },
        "CH.ifa.draw.figures.PolyLineFigure" => %{
          super: if(version >= 1, do: "CH.ifa.draw.figures.AttributeFigure"),
          interfaces: ["CH.ifa.draw.figures.PolyLineable"],
          fields:
            Enum.concat([
              [
                points: {:list, [x: :int, y: :int]},
                start_decoration: {:storable, "CH.ifa.draw.figures.LineDecoration"},
                end_decoration: {:storable, "CH.ifa.draw.figures.LineDecoration"}
              ],
              if(version >= 8, do: [arrow_name: :string], else: []),
              if(version == Renewex.Parser.min_version(), do: [frame_color: :color_rgb], else: [])
            ])
        },
        "CH.ifa.draw.figures.LineConnection" => %{
          super: "CH.ifa.draw.figures.PolyLineFigure",
          interfaces: [],
          fields: [
            start: {:storable, "CH.ifa.draw.framework.Connector"},
            end: {:storable, "CH.ifa.draw.framework.Connector"}
          ]
        },
        "CH.ifa.draw.figures.ArrowTip" => %{
          super: nil,
          interfaces: ["CH.ifa.draw.figures.LineDecoration"],
          fields:
            if(version >= 5,
              do: [
                angle: :float,
                outer_radius: :float,
                inner_radius: :float,
                filled: :boolean
              ],
              else: []
            )
        },
        "de.renew.gui.CircleDecoration" => %{
          super: nil,
          interfaces: ["CH.ifa.draw.figures.LineDecoration"]
        },
        "CH.ifa.draw.standard.ChopBoxConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: ["CH.ifa.draw.framework.Connector"]
        },
        "CH.ifa.draw.figures.ChopEllipseConnector" => %{
          super: "CH.ifa.draw.standard.ChopBoxConnector",
          interfaces: ["CH.ifa.draw.framework.Connector"]
        },
        "CH.ifa.draw.standard.AbstractConnector" => %{
          super: nil,
          interfaces: ["CH.ifa.draw.framework.Connector"],
          fields: [owner: {:storable, "CH.ifa.draw.framework.Figure"}]
        },
        "de.renew.gui.DeclarationFigure" => %{
          super: "de.renew.gui.CPNTextFigure",
          interfaces: []
        },
        "fs.FSFigure" => %{
          super: "de.renew.gui.fs.FSFigure",
          interfaces: []
        },
        "de.renew.gui.fs.FSFigure" => %{
          super:
            if(version <= 5,
              do: "CH.ifa.draw.figures.TextFigure",
              else: "de.renew.gui.CPNTextFigure"
            ),
          interfaces: []
        },
        "CH.ifa.draw.figures.TextFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          fields: [
            fOriginX: :int,
            fOriginY: :int,
            text: :string,
            fCurrentFontName: :string,
            fCurrentFontStyle: :int,
            fCurrentFontSize: :int,
            fIsReadOnly: :boolean,
            fParent: {:storable, "CH.ifa.draw.framework.ParentFigure"},
            fLocator: {:storable, "CH.ifa.draw.standard.OffsetLocator"}
          ]
        },
        "de.renew.gui.CPNTextFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: [],
          fields: [fType: :int]
        },
        "CH.ifa.draw.figures.ImageFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          fields: [x: :int, y: :int, w: :int, h: :int, name: :string]
        },
        "fs.TypeFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: [],
          fields: [type: :string]
        },
        "CH.ifa.draw.figures.LineFigure" => %{
          super: "CH.ifa.draw.figures.PolyLineFigure",
          interfaces: []
        },
        "CH.ifa.draw.contrib.TriangleFigure" => %{
          super: "CH.ifa.draw.figures.RectangleFigure",
          interfaces: [],
          fields: [rotation: :int]
        },
        "CH.ifa.draw.figures.CompositeAttributeFigure" => %{
          super: if(version > 9, do: "CH.ifa.draw.figures.AttributeFigure"),
          interfaces: [],
          fields: [figures: {:list, {:storable, "CH.ifa.draw.framework.Figure"}}]
        },
        "de.renew.netcomponents.NetComponentFigure" => %{
          super: "CH.ifa.draw.figures.CompositeAttributeFigure",
          interfaces: []
        },
        "de.renew.gui.CPNDrawing" => %{
          super: "CH.ifa.draw.standard.StandardDrawing",
          interfaces: ["CH.ifa.draw.framework.Figure"],
          fields:
            if(version >= 2, do: [icon: {:storable, "CH.ifa.draw.framework.Figure"}], else: [])
        },
        "de.renew.sdnet.gui.SDNDrawing" => %{
          super: "de.renew.gui.CPNDrawing",
          interfaces: ["CH.ifa.draw.framework.Figure"]
        },
        "de.renew.sdnet.gui.figure.SDNPlaceTextFigure" => %{
          super: "de.renew.gui.CPNTextFigure",
          interfaces: ["CH.ifa.draw.framework.Figure"]
        },
        "de.renew.diagram.drawing.DiagramDrawing" => %{
          super: "CH.ifa.draw.standard.StandardDrawing",
          interfaces: []
        },
        "de.renew.diagram.RoleDescriptorFigure" => %{
          super: "de.renew.diagram.TailFigure",
          interfaces: ["RepresentableRoleFigure"]
        },
        "de.renew.diagram.DiagramFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: ["de.renew.diagram.RepresentableDiagramFigure"],
          fields: [x: :int, y: :int, w: :int, h: :int]
        },
        "de.renew.diagram.TailFigure" => %{
          super: "de.renew.diagram.DiagramFigure",
          interfaces: ["de.renew.diagram.RepresentableTailFigure"]
        },
        "de.renew.diagram.LifeLineLogicFigure" => %{
          super: "de.renew.diagram.TailFigure",
          interfaces: [
            "de.renew.diagram.RepresentableLifeLineLogicFigure",
            "de.renew.diagram.ISplitFigure"
          ],
          fields: [decoration: {:storable, "de.renew.diagram.FigureDecoration"}, skip: [:string]]
        },
        "de.renew.diagram.VSplitFigure" => %{
          super: "de.renew.diagram.LifeLineLogicFigure",
          interfaces: []
        },
        "de.renew.diagram.VJoinFigure" => %{
          super: "de.renew.diagram.LifeLineLogicFigure",
          interfaces: []
        },
        "de.renew.diagram.HSplitFigure" => %{
          super: "de.renew.diagram.DiagramFigure",
          interfaces: [],
          fields: [decoration: {:storable, "de.renew.diagram.FigureDecoration"}, skip: [:string]]
        },
        "de.renew.diagram.VSplitCenterConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.HSplitCenterConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.SplitDecoration" => %{
          super: nil,
          interfaces: ["de.renew.diagram.FigureDecoration"],
          fields: [size: :int, half_size: :int]
        },
        "de.renew.diagram.XORDecoration" => %{
          super: "de.renew.diagram.SplitDecoration",
          interfaces: []
        },
        "de.renew.diagram.ANDDecoration" => %{
          super: "de.renew.diagram.SplitDecoration",
          interfaces: []
        },
        "de.renew.diagram.LifeLineConnection" => %{
          super: "CH.ifa.draw.figures.LineConnection",
          interfaces: []
        },
        "de.renew.diagram.VerticalConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.HorizontalConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.TopConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.RightConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.HTopConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.HBottomConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.DiagramTextFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: []
        },
        "de.renew.diagram.DCServiceTextFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: []
        },
        "de.renew.diagram.ActionTextFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: []
        },
        "de.renew.diagram.BottomConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.LeftConnector" => %{
          super: "CH.ifa.draw.standard.AbstractConnector",
          interfaces: []
        },
        "de.renew.diagram.TaskFigure" => %{
          super: "de.renew.diagram.TailFigure",
          interfaces: []
        },
        "de.renew.diagram.DestructionFigure" => %{
          super: "de.renew.diagram.TailFigure",
          interfaces: []
        },
        "de.renew.diagram.AbstractMessageConnection" => %{
          super: "CH.ifa.draw.figures.LineConnection",
          interfaces: []
        },
        "de.renew.diagram.MessageConnection" => %{
          super: "de.renew.diagram.AbstractMessageConnection",
          interfaces: []
        },
        "de.renew.diagram.SynchronousMessageConnection" => %{
          super: "de.renew.diagram.AbstractMessageConnection",
          interfaces: []
        },
        "de.renew.diagram.SynchronousMessageArrowTip" => %{
          super: "CH.ifa.draw.figures.ArrowTip",
          interfaces: []
        },
        "de.renew.diagram.SynchronousReplyConnection" => %{
          super: "de.renew.diagram.AbstractMessageConnection",
          interfaces: []
        },
        "de.renew.diagram.DiagramFrameFigure" => %{
          super: "CH.ifa.draw.figures.RoundRectangleFigure",
          interfaces: []
        },
        "de.renew.diagram.AssocArrowTip" => %{
          super: "de.renew.gui.AssocArrowTip",
          interfaces: []
        }
      }
    }
  end

  @doc """

  """
  def parse(parser, "CH.ifa.draw.figures.FigureAttributes", into) do
    {:ok, "attributes", next_parser} = Parser.parse_primitive(parser, :string)

    {:ok, attrs, next_parser} =
      Parser.parse_list(next_parser, fn
        p -> parse_attribute(p)
      end)

    {:ok,
     %Storable{
       into
       | fields: into.fields |> put_in([:attributes], attrs)
     }, next_parser}
  end

  @doc """

  """
  def parse(parser, "CH.ifa.draw.figures.AttributeFigure", into) do
    case Parser.parse_primitive(parser, :string) do
      {:ok, "attributes", next_parser} ->
        {:ok, attributes, next_parser} =
          Parser.parse_grammar_rule(next_parser, "CH.ifa.draw.figures.FigureAttributes")

        {:ok,
         %Storable{
           into
           | fields: into.fields |> put_in([:attributes], attributes)
         }, next_parser}

      {:ok, "no_attributes", next_parser} ->
        {:ok, into, next_parser}

      err ->
        err
    end
  end

  @doc """

  """
  def parse(parser, "de.renew.gui.fs.FSFigure", into) do
    if parser.grammar.version <= 5 do
      {:ok,
       %Storable{
         into
         | fields:
             into.fields
             |> put_in([:fType], 1)
       }, parser}
    else
      into = %Storable{
        into
        | fields:
            into.fields
            |> put_in([:frameColor], "black")
      }

      if parser.grammar.version > 6 do
        {:ok, paths, next_parser} =
          Parser.parse_list(parser, fn
            p -> Parser.parse_primitive(p, :string)
          end)

        {:ok,
         %Storable{
           into
           | fields:
               into.fields
               |> put_in([:paths], paths)
         }, next_parser}
      else
        {:ok, into, parser}
      end
    end
  end

  @doc """

  """
  def parse(parser, rule, into) do
    if Map.has_key?(parser.grammar.hierarchy[rule], :fields) do
      with {:ok, new_fields, next_parser} <-
             parse_fields(parser, parser.grammar.hierarchy[rule].fields, into.fields) do
        {:ok,
         %Storable{
           into
           | fields: new_fields
         }, next_parser}
      end
    else
      {:ok, into, parser}
    end
  end

  @doc """

  """
  defp parse_fields(parser, fields, into) do
    Enum.reduce(fields, {:ok, into, parser}, fn
      {:skip, [_ | _] = types}, {:ok, into, parser} ->
        with {:ok, nil, next_parser} <- Parser.skip_any(parser, types) do
          {:ok, into, next_parser}
        end

      {field_name, {:list, list_type}}, {:ok, into, parser} ->
        with {:ok, value, next_parser} <- parse_list_field(parser, list_type) do
          {:ok,
           into
           |> put_in([field_name], value), next_parser}
        end

      {field_name, :color_rgb}, {:ok, into, parser} ->
        with {:ok, color, next_parser} <- parse_color_rgb(parser) do
          {:ok,
           into
           |> put_in([field_name], color), next_parser}
        end

      {field_name, :color_rgba}, {:ok, into, parser} ->
        with {:ok, color, next_parser} <- parse_color_rgba(parser) do
          {:ok,
           into
           |> put_in([field_name], color), next_parser}
        end

      {field_name, {:storable, of_type}}, {:ok, into, parser} ->
        with {:ok, value, next_parser} <- Parser.parse_storable(parser, of_type) do
          {:ok,
           into
           |> put_in([field_name], value), next_parser}
        end

      {field_name, {:rule, of_type}}, {:ok, into, parser} ->
        with {:ok, value, next_parser} <- Parser.parse_grammar_rule(parser, of_type) do
          {:ok,
           into
           |> put_in([field_name], value), next_parser}
        end

      {field_name, field_type}, {:ok, into, parser} ->
        with {:ok, value, next_parser} <- Parser.parse_primitive(parser, field_type) do
          {:ok,
           into
           |> put_in([field_name], value), next_parser}
        end

      _, err ->
        err
    end)
  end

  @doc """

  """
  defp parse_list_field(parser, list_type) do
    Parser.parse_list(parser, fn
      p ->
        case list_type do
          {:storable, type} ->
            Parser.parse_storable(p, type)

          {:rule, type} ->
            Parser.parse_grammar_rule(p, type)

          primitive when is_atom(primitive) ->
            Parser.parse_primitive(p, primitive)

          multiples when is_list(multiples) ->
            parse_fields(p, multiples, [])
        end
    end)
  end

  @doc """

  """
  def serialize(_parser, "CH.ifa.draw.figures.FigureAttributes") do
  end

  def serialize(_parser, "CH.ifa.draw.figures.AttributeFigure") do
  end

  def serialize(_parser, "de.renew.gui.fs.FSFigure") do
  end

  @doc """

  """
  def parse_attribute(parser) do
    {:ok, key, next_parser} = Parser.parse_primitive(parser, :string)
    {:ok, type, next_parser} = Parser.parse_primitive(next_parser, :string)

    {:ok, value, next_parser} =
      case type do
        "Color" ->
          if(parser.grammar.version < 11,
            do: parse_color_rgb(next_parser),
            else: parse_color_rgba(next_parser)
          )

        "Boolean" ->
          {:ok, v, next_parser} = Parser.parse_primitive(next_parser, :string)

          {:ok, String.downcase(v) === "true", next_parser}

        "String" ->
          Parser.parse_primitive(next_parser, :string)

        "Int" ->
          Parser.parse_primitive(next_parser, :int)

        "Storable" ->
          Parser.parse_storable(next_parser)

        "UNKNOWN" ->
          {:ok, :unknown, next_parser}
      end

    {:ok, {key, type, value}, next_parser}
  end

  @doc """

  """
  def parse_color_rgba(parser) do
    {:ok, r, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, g, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, b, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, a, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok, {:rgba, r, g, b, a}, next_parser}
  end

  @doc """

  """
  def parse_color_rgb(parser) do
    {:ok, r, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, g, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, b, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok, {:rgba, r, g, b}, next_parser}
  end

  @doc """

  """
  def should_skip_super(grammar, rule) do
    Map.get(grammar.hierarchy[rule], :skip_super, false)
  end
end
