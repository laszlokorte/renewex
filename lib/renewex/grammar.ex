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
          interfaces: []
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
          interfaces: []
        },
        "CH.ifa.draw.figures.EllipseFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: []
        },
        "CH.ifa.draw.figures.RoundRectangleFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: []
        },
        "de.renew.gui.TransitionFigure" => %{
          super: "CH.ifa.draw.figures.RectangleFigure",
          interfaces: [
            "CH.ifa.draw.framework.Figure",
            "de.renew.gui.InscribableFigure",
            "CH.ifa.draw.framework.ParentFigure"
          ]
        },
        "de.renew.gui.PlaceFigure" => %{
          super: "CH.ifa.draw.figures.EllipseFigure",
          interfaces: [
            "CH.ifa.draw.framework.Figure",
            "de.renew.gui.InscribableFigure",
            "CH.ifa.draw.framework.ParentFigure"
          ]
        },
        "de.renew.gui.VirtualPlaceFigure" => %{
          super: "de.renew.gui.PlaceFigure",
          interfaces: []
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
          interfaces: []
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
          interfaces: ["CH.ifa.draw.framework.Locator"]
        },
        "fs.PartitionFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: ["CH.ifa.draw.framework.Locator"]
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
          interfaces: []
        },
        "CH.ifa.draw.standard.OffsetLocator" => %{
          super: "CH.ifa.draw.figures.AbstractLocator",
          interfaces: ["CH.ifa.draw.framework.Locator"]
        },
        "CH.ifa.draw.standard.RelativeLocator" => %{
          super: "CH.ifa.draw.figures.AbstractLocator",
          interfaces: ["CH.ifa.draw.framework.Locator"]
        },
        "CH.ifa.draw.figures.PolyLineFigure" => %{
          super: if(version >= 1, do: "CH.ifa.draw.figures.AttributeFigure"),
          interfaces: ["CH.ifa.draw.figures.PolyLineable"]
        },
        "CH.ifa.draw.figures.LineConnection" => %{
          super: "CH.ifa.draw.figures.PolyLineFigure",
          interfaces: []
        },
        "CH.ifa.draw.figures.ArrowTip" => %{
          super: nil,
          interfaces: ["CH.ifa.draw.figures.LineDecoration"]
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
          interfaces: ["CH.ifa.draw.framework.Connector"]
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
          interfaces: []
        },
        "de.renew.gui.CPNTextFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: []
        },
        "CH.ifa.draw.figures.ImageFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: []
        },
        "fs.TypeFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: []
        },
        "CH.ifa.draw.figures.LineFigure" => %{
          super: "CH.ifa.draw.figures.PolyLineFigure",
          interfaces: []
        },
        "CH.ifa.draw.contrib.TriangleFigure" => %{
          super: "CH.ifa.draw.figures.RectangleFigure",
          interfaces: []
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
          interfaces: ["CH.ifa.draw.framework.Figure"]
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
          interfaces: ["de.renew.diagram.RepresentableDiagramFigure"]
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
          ]
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
          interfaces: []
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
          interfaces: ["de.renew.diagram.FigureDecoration"]
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
    {:ok, "attributes", next_parser} = Parser.parse_primitive(parser, :string)

    {:ok, attributes, next_parser} =
      Parser.parse_grammar_rule(next_parser, "CH.ifa.draw.figures.FigureAttributes")

    {:ok,
     %Storable{
       into
       | fields: into.fields |> put_in([:attributes], attributes)
     }, next_parser}
  end

  def parse(parser, "CH.ifa.draw.figures.RectangleFigure", into) do
    {:ok, x, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, y, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, w, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, h, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:x], x)
           |> put_in([:y], y)
           |> put_in([:w], w)
           |> put_in([:h], h)
     }, next_parser}
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

  def parse(parser, "de.renew.hierarchicalworkflownets.gui.layout.Vec2d", into) do
    {:ok, {x, y}, next_parser} = parse_xy(parser)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:x], x)
           |> put_in([:y], y)
     }, next_parser}
  end

  def parse(parser, "CH.ifa.draw.figures.EllipseFigure", into) do
    {:ok, x, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, y, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, w, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, h, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:x], x)
           |> put_in([:y], y)
           |> put_in([:w], w)
           |> put_in([:h], h)
     }, next_parser}
  end

  def parse(parser, "CH.ifa.draw.figures.RoundRectangleFigure", into) do
    {:ok, x, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, y, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, w, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, h, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:x], x)
           |> put_in([:y], y)
           |> put_in([:w], w)
           |> put_in([:h], h)
     }, next_parser}
  end

  def parse(parser, "de.renew.gui.TransitionFigure", into) do
    {:ok, highlight_figure, next_parser} =
      Parser.parse_storable(parser, "CH.ifa.draw.framework.Figure")

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:highlight_figure], highlight_figure)
     }, next_parser}
  end

  def parse(parser, "de.renew.gui.PlaceFigure", into) do
    if parser.grammar.version >= 3 do
      {:ok, highlight_figure, next_parser} =
        Parser.parse_storable(parser, "CH.ifa.draw.framework.Figure")

      {:ok,
       %Storable{
         into
         | fields:
             into.fields
             |> put_in([:highlight_figure], highlight_figure)
       }, next_parser}
    else
      {:ok, into, parser}
    end
  end

  def parse(parser, "de.renew.gui.VirtualPlaceFigure", into) do
    {:ok, place_figure, next_parser} =
      Parser.parse_storable(parser, "de.renew.gui.PlaceFigure")

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:place_figure], place_figure)
     }, next_parser}
  end

  def parse(parser, "de.renew.gui.fs.IsaConnection", into) do
    {:ok, is_disjunctive, next_parser} =
      Parser.parse_primitive(parser, :boolean)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:is_disjunctive], is_disjunctive)
     }, next_parser}
  end

  def parse(parser, "fs.ConceptFigure", into) do
    if parser.grammar.version < 0 do
      {:ok, type, next_parser} =
        Parser.parse_primitive(parser, :int)

      {:ok,
       %Storable{
         into
         | fields:
             into.fields
             |> put_in([:type], type)
       }, next_parser}
    else
      {:ok, into, parser}
    end
  end

  def parse(parser, "fs.PartitionFigure", into) do
    {:ok, x, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, y, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, w, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, h, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:x], x)
           |> put_in([:y], y)
           |> put_in([:w], w)
           |> put_in([:h], h)
     }, next_parser}
  end

  def parse(parser, "de.renew.bpmn.roundtrip.RoundtripNetComponentFigure", into) do
    {:ok, into, Parser.skip_any(parser, [:ref, :string])}
  end

  def parse(parser, "CH.ifa.draw.standard.OffsetLocator", into) do
    {:ok, fOffsetX, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, fOffsetY, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok, fBase, next_parser} =
      Parser.parse_storable(next_parser, "CH.ifa.draw.framework.Locator")

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:fOffsetX], fOffsetX)
           |> put_in([:fOffsetY], fOffsetY)
           |> put_in([:fBase], fBase)
     }, next_parser}
  end

  def parse(parser, "CH.ifa.draw.standard.RelativeLocator", into) do
    {:ok, fOffsetX, next_parser} = Parser.parse_primitive(parser, :float)
    {:ok, fOffsetY, next_parser} = Parser.parse_primitive(next_parser, :float)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:fOffsetX], fOffsetX)
           |> put_in([:fOffsetY], fOffsetY)
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

  def parse(parser, "CH.ifa.draw.figures.LineConnection", into) do
    {:ok, start, next_parser} =
      Parser.parse_storable(parser, "CH.ifa.draw.framework.Connector")

    {:ok, ende, next_parser} =
      Parser.parse_storable(next_parser, "CH.ifa.draw.framework.Connector")

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:start], start)
           |> put_in([:end], ende)
     }, next_parser}
  end

  def parse(parser, "CH.ifa.draw.figures.ArrowTip", into) do
    if parser.grammar.version >= 5 do
      {:ok, angle, next_parser} = Parser.parse_primitive(parser, :float)
      {:ok, outer_radius, next_parser} = Parser.parse_primitive(next_parser, :float)
      {:ok, inner_radius, next_parser} = Parser.parse_primitive(next_parser, :float)
      {:ok, filled, next_parser} = Parser.parse_primitive(next_parser, :boolean)

      {:ok,
       %Storable{
         into
         | fields:
             into.fields
             |> put_in([:angle], angle)
             |> put_in([:outer_radius], outer_radius)
             |> put_in([:inner_radius], inner_radius)
             |> put_in([:filled], filled)
       }, next_parser}
    else
      {:ok, into, parser}
    end
  end

  def parse(parser, "CH.ifa.draw.standard.AbstractConnector", into) do
    {:ok, owner, next_parser} =
      Parser.parse_storable(parser, "CH.ifa.draw.framework.Figure")

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:owner], owner)
     }, next_parser}
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

  def parse(parser, "CH.ifa.draw.figures.TextFigure", into) do
    {:ok, fOriginX, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, fOriginY, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, text, next_parser} = Parser.parse_primitive(next_parser, :string)
    {:ok, fCurrentFontName, next_parser} = Parser.parse_primitive(next_parser, :string)
    {:ok, fCurrentFontStyle, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, fCurrentFontSize, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, fIsReadOnly, next_parser} = Parser.parse_primitive(next_parser, :boolean)

    {:ok, fParent, next_parser} =
      Parser.parse_storable(next_parser, "CH.ifa.draw.framework.ParentFigure")

    {:ok, fLocator, next_parser} =
      Parser.parse_storable(next_parser, "CH.ifa.draw.standard.OffsetLocator")

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:fOriginX], fOriginX)
           |> put_in([:fOriginY], fOriginY)
           |> put_in([:text], text)
           |> put_in([:fCurrentFontName], fCurrentFontName)
           |> put_in([:fCurrentFontStyle], fCurrentFontStyle)
           |> put_in([:fCurrentFontSize], fCurrentFontSize)
           |> put_in([:fIsReadOnly], fIsReadOnly)
           |> put_in([:fParent], fParent)
           |> put_in([:fLocator], fLocator)
     }, next_parser}
  end

  def parse(parser, "de.renew.gui.CPNTextFigure", into) do
    {:ok, fType, next_parser} = Parser.parse_primitive(parser, :int)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:fType], fType)
     }, next_parser}
  end

  def parse(parser, "CH.ifa.draw.figures.ImageFigure", into) do
    {:ok, x, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, y, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, w, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, h, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, name, next_parser} = Parser.parse_primitive(next_parser, :string)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:x], x)
           |> put_in([:y], y)
           |> put_in([:w], w)
           |> put_in([:h], h)
           |> put_in([:name], name)
     }, next_parser}
  end

  def parse(parser, "fs.TypeFigure", into) do
    {:ok, type, next_parser} = Parser.parse_primitive(parser, :string)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:type], type)
     }, next_parser}
  end

  def parse(parser, "CH.ifa.draw.contrib.TriangleFigure", into) do
    {:ok, rotation, next_parser} = Parser.parse_primitive(parser, :int)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:rotation], rotation)
     }, next_parser}
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

  def parse(parser, "de.renew.gui.CPNDrawing", into) do
    if parser.grammar.version >= 2 do
      {:ok, icon, next_parser} =
        Parser.parse_storable(parser, "CH.ifa.draw.framework.Figure")

      {:ok,
       %Storable{
         into
         | fields: into.fields |> put_in([:icon], icon)
       }, next_parser}
    else
      {:ok, into, parser}
    end
  end

  def parse(parser, "de.renew.diagram.DiagramFigure", into) do
    {:ok, x, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, y, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, w, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, h, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok,
     %Storable{
       into
       | fields:
           into.fields
           |> put_in([:x], x)
           |> put_in([:y], y)
           |> put_in([:w], w)
           |> put_in([:h], h)
     }, next_parser}
  end

  def parse(parser, "de.renew.diagram.LifeLineLogicFigure", into) do
    {:ok, decoration, next_parser} =
      Parser.parse_storable(parser, "de.renew.diagram.FigureDecoration")

    {:ok, _, next_parser} =
      Parser.parse_primitive(next_parser, :string)

    {:ok,
     %Storable{
       into
       | fields: into.fields |> put_in([:decoration], decoration)
     }, next_parser}
  end

  def parse(parser, "de.renew.diagram.HSplitFigure", into) do
    {:ok, decoration, next_parser} =
      Parser.parse_storable(parser, "de.renew.diagram.FigureDecoration")

    {:ok,
     %Storable{
       into
       | fields: into.fields |> put_in([:decoration], decoration)
     }, next_parser}
  end

  def parse(parser, "de.renew.diagram.SplitDecoration", into) do
    {:ok, size, next_parser} =
      Parser.parse_primitive(parser, :string)

    {:ok, half_size, next_parser} =
      Parser.parse_primitive(next_parser, :string)

    {:ok,
     %Storable{
       into
       | fields: into.fields |> put_in([:size], size) |> put_in([:half_size], half_size)
     }, next_parser}
  end

  def parse(parser, _, into) do
    {:ok, into, parser}
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
          Parser.parse_primitive(next_parser, :boolean)

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
