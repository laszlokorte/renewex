defmodule Renewex.Grammar do
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

  def parse(%Renewex.Grammar{}, "de.renew.diagram.AssocArrowTip", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.standard.CompositeFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.FigureAttributes", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.AttributeFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.RectangleFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.hierarchicalworkflownets.gui.HNViewDrawing", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.contrib.PolygonFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.hierarchicalworkflownets.gui.layout.Vec2d", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.EllipseFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.RoundRectangleFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.gui.TransitionFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.gui.PlaceFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.gui.VirtualPlaceFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.gui.fs.IsaConnection", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "fs.ConceptFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "fs.PartitionFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.bpmn.roundtrip.RoundtripNetComponentFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.standard.OffsetLocator", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.standard.RelativeLocator", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.PolyLineFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.LineConnection", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.ArrowTip", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.standard.AbstractConnector", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.gui.fs.FSFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.TextFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.gui.CPNTextFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.ImageFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "fs.TypeFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.contrib.TriangleFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "CH.ifa.draw.figures.CompositeAttributeFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.gui.CPNDrawing", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.diagram.DiagramFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.diagram.LifeLineLogicFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.diagram.HSplitFigure", _tokens) do
  end

  def parse(%Renewex.Grammar{}, "de.renew.diagram.SplitDecoration", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.diagram.AssocArrowTip", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.standard.CompositeFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.FigureAttributes", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.AttributeFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.RectangleFigure", _tokens) do
  end

  def serialize(
        %Renewex.Grammar{},
        "de.renew.hierarchicalworkflownets.gui.HNViewDrawing",
        _tokens
      ) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.contrib.PolygonFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.hierarchicalworkflownets.gui.layout.Vec2d", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.EllipseFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.RoundRectangleFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.gui.TransitionFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.gui.PlaceFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.gui.VirtualPlaceFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.gui.fs.IsaConnection", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "fs.ConceptFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "fs.PartitionFigure", _tokens) do
  end

  def serialize(
        %Renewex.Grammar{},
        "de.renew.bpmn.roundtrip.RoundtripNetComponentFigure",
        _tokens
      ) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.standard.OffsetLocator", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.standard.RelativeLocator", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.PolyLineFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.LineConnection", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.ArrowTip", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.standard.AbstractConnector", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.gui.fs.FSFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.TextFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.gui.CPNTextFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.ImageFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "fs.TypeFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.contrib.TriangleFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "CH.ifa.draw.figures.CompositeAttributeFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.gui.CPNDrawing", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.diagram.DiagramFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.diagram.LifeLineLogicFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.diagram.HSplitFigure", _tokens) do
  end

  def serialize(%Renewex.Grammar{}, "de.renew.diagram.SplitDecoration", _tokens) do
  end
end
