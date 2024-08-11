defmodule Renewex.Grammar do
  alias Renewex.Storable
  alias Renewex.Parser
  defstruct [:version, :hierarchy]

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
          interfaces: ["CH.ifa.draw.framework.Figure"]
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
          skipSuper: true,
          interfaces: []
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
          interfaces: ["CH.ifa.draw.figures.PolyLineable"]
        },
        "de.renew.hierarchicalworkflownets.gui.HNTransitionFigure" => %{
          super: "de.renew.gui.TransitionFigure",
          interfaces: []
        },
        "de.renew.hierarchicalworkflownets.gui.layout.Vec2d" => %{
          super: nil,
          interfaces: [],
          fields: [x: :int, y: :int]
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
          fields: [highlight_figure: {:storable, "CH.ifa.draw.framework.Figure"}]
        },
        "de.renew.gui.PlaceFigure" => %{
          super: "CH.ifa.draw.figures.EllipseFigure",
          interfaces: [
            "CH.ifa.draw.framework.Figure",
            "de.renew.gui.InscribableFigure",
            "CH.ifa.draw.framework.ParentFigure"
          ],
          fields:
            if(version >= 3, do: [highlight_figure: {:storable, "CH.ifa.draw.framework.Figure"}])
        },
        "de.renew.gui.VirtualPlaceFigure" => %{
          super: "de.renew.gui.PlaceFigure",
          interfaces: [],
          fields: [highlight_figure: {:storable, "e.renew.gui.PlaceFigure"}]
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
          fields: if(version < 0, do: [int: :type])
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
          interfaces: ["CH.ifa.draw.figures.PolyLineable"]
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
              else: nil
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
          interfaces: []
        },
        "de.renew.netcomponents.NetComponentFigure" => %{
          super: "CH.ifa.draw.figures.CompositeAttributeFigure",
          interfaces: []
        },
        "de.renew.gui.CPNDrawing" => %{
          super: "CH.ifa.draw.standard.StandardDrawing",
          interfaces: ["CH.ifa.draw.framework.Figure"],
          fields: if(version >= 2, do: [icon: {:storable, "CH.ifa.draw.framework.Figure"}])
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

  def parse(parser, "CH.ifa.draw.standard.CompositeFigure", into) do
    {:ok, figures, next_parser} =
      Parser.parse_list(parser, fn
        p -> Parser.parse_storable(p, "CH.ifa.draw.framework.Figure")
      end)

    {:ok,
     %Storable{
       into
       | fields: into.fields |> put_in([:figures], figures)
     }, next_parser}
  end

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

  def parse(parser, "de.renew.hierarchicalworkflownets.gui.HNViewDrawing", into) do
    # TODO
    {:ok, into, parser}
  end

  def parse(parser, "CH.ifa.draw.contrib.PolygonFigure", into) do
    {:ok, points, next_parser} =
      Parser.parse_list(parser, fn
        p -> parse_xy(p)
      end)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:points], points)
     }, next_parser}
  end

  def parse(parser, "CH.ifa.draw.figures.PolyLineFigure", into) do
    {:ok, points, next_parser} =
      Parser.parse_list(parser, fn
        p -> parse_xy(p)
      end)

    {:ok, start_decoration, next_parser} =
      Parser.parse_storable(next_parser, "CH.ifa.draw.figures.LineDecoration")

    {:ok, end_decoration, next_parser} =
      Parser.parse_storable(next_parser, "CH.ifa.draw.figures.LineDecoration")

    into = %Storable{
      into
      | fields:
          into.fields
          |> put_in([:points], points)
          |> put_in([:start_decoration], start_decoration)
          |> put_in([:end_decoration], end_decoration)
    }

    cond do
      parser.grammar.version >= 8 ->
        {:ok, arrow_name, next_parser} = Parser.parse_primitive(next_parser, :string)

        {:ok,
         %Storable{
           into
           | fields:
               into.fields
               |> put_in([:arrow_name], arrow_name)
         }, next_parser}

      parser.grammar.version == -1 ->
        {:ok, frame_color, next_parser} = parse_color_rgb(next_parser)

        {:ok,
         %Storable{
           into
           | fields:
               into.fields
               |> put_in([:frame_color], frame_color)
         }, next_parser}

      true ->
        {:ok, into, next_parser}
    end
  end

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

  def parse(parser, "CH.ifa.draw.figures.CompositeAttributeFigure", into) do
    {:ok, figures, next_parser} =
      Parser.parse_list(parser, fn
        p -> Parser.parse_storable(p, "CH.ifa.draw.framework.Figure")
      end)

    {:ok,
     %Storable{
       into
       | fields: into.fields |> put_in([:figures], figures)
     }, next_parser}
  end

  def parse(parser, rule, into) do
    if Map.has_key?(parser.grammar.hierarchy[rule], :fields) do
      parse_fields(parser, parser.grammar.hierarchy[rule].fields, into)
    else
      {:ok, into, parser}
    end
  end

  defp parse_fields(parser, fields, into) do
    Enum.reduce(fields, {:ok, into, parser}, fn
      {:skip, [_ | _] = types}, {:ok, into, parser} ->
        with {:ok, nil, next_parser} <- Parser.skip_any(parser, types) do
          {:ok, into, next_parser}
        end

      {field_name, {:storable, of_type}}, {:ok, into, parser} ->
        with {:ok, value, next_parser} <- Parser.parse_storable(parser, of_type) do
          {:ok,
           %Storable{
             into
             | fields:
                 into.fields
                 |> put_in([field_name], value)
           }, next_parser}
        end

      {field_name, field_type}, {:ok, into, parser} ->
        with {:ok, value, next_parser} <- Parser.parse_primitive(parser, field_type) do
          {:ok,
           %Storable{
             into
             | fields:
                 into.fields
                 |> put_in([field_name], value)
           }, next_parser}
        end

      _, err ->
        err
    end)
  end

  def serialize(parser, "de.renew.diagram.AssocArrowTip") do
  end

  def serialize(parser, "CH.ifa.draw.standard.CompositeFigure") do
  end

  def serialize(parser, "CH.ifa.draw.figures.FigureAttributes") do
  end

  def serialize(parser, "CH.ifa.draw.figures.AttributeFigure") do
  end

  def serialize(parser, "CH.ifa.draw.figures.RectangleFigure") do
  end

  def serialize(parser, "de.renew.hierarchicalworkflownets.gui.HNViewDrawing") do
  end

  def serialize(parser, "CH.ifa.draw.contrib.PolygonFigure") do
  end

  def serialize(parser, "de.renew.hierarchicalworkflownets.gui.layout.Vec2d") do
  end

  def serialize(parser, "CH.ifa.draw.figures.EllipseFigure") do
  end

  def serialize(parser, "CH.ifa.draw.figures.RoundRectangleFigure") do
  end

  def serialize(parser, "de.renew.gui.TransitionFigure") do
  end

  def serialize(parser, "de.renew.gui.PlaceFigure") do
  end

  def serialize(parser, "de.renew.gui.VirtualPlaceFigure") do
  end

  def serialize(parser, "de.renew.gui.fs.IsaConnection") do
  end

  def serialize(parser, "fs.ConceptFigure") do
  end

  def serialize(parser, "fs.PartitionFigure") do
  end

  def serialize(parser, "de.renew.bpmn.roundtrip.RoundtripNetComponentFigure") do
  end

  def serialize(parser, "CH.ifa.draw.standard.OffsetLocator") do
  end

  def serialize(parser, "CH.ifa.draw.standard.RelativeLocator") do
  end

  def serialize(parser, "CH.ifa.draw.figures.PolyLineFigure") do
  end

  def serialize(parser, "CH.ifa.draw.figures.LineConnection") do
  end

  def serialize(parser, "CH.ifa.draw.figures.ArrowTip") do
  end

  def serialize(parser, "CH.ifa.draw.standard.AbstractConnector") do
  end

  def serialize(parser, "de.renew.gui.fs.FSFigure") do
  end

  def serialize(parser, "CH.ifa.draw.figures.TextFigure") do
  end

  def serialize(parser, "de.renew.gui.CPNTextFigure") do
  end

  def serialize(parser, "CH.ifa.draw.figures.ImageFigure") do
  end

  def serialize(parser, "fs.TypeFigure") do
  end

  def serialize(parser, "CH.ifa.draw.contrib.TriangleFigure") do
  end

  def serialize(parser, "CH.ifa.draw.figures.CompositeAttributeFigure") do
  end

  def serialize(parser, "de.renew.gui.CPNDrawing") do
  end

  def serialize(parser, "de.renew.diagram.DiagramFigure") do
  end

  def serialize(parser, "de.renew.diagram.LifeLineLogicFigure") do
  end

  def serialize(parser, "de.renew.diagram.HSplitFigure") do
  end

  def serialize(parser, "de.renew.diagram.SplitDecoration") do
  end

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
          :unknown
      end

    {:ok, {key, type, value}, next_parser}
  end

  def parse_color_rgba(parser) do
    {:ok, r, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, g, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, b, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, a, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok, {:rgba, r, g, b, a}, next_parser}
  end

  def parse_color_rgb(parser) do
    {:ok, r, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, g, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, b, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok, {:rgba, r, g, b}, next_parser}
  end

  def parse_xy(parser) do
    {:ok, x, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, y, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok, {x, y}, next_parser}
  end
end
