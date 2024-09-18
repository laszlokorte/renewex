defmodule Renewex.Grammar do
  @moduledoc """
  This module defines the grammar to parse [Renew](http://renew.de) `*.rnw` files.

  The Renew grammar is version dependent and depends on the Java class hierarchy defined in renew.

  This module defines a struct to describe the class hierarchy and some specialized function to parse specific classes.
  """

  alias Renewex.Serializer
  alias Renewex.Storable
  alias Renewex.Parser

  @doc """
    The earliest version of Renew to be used for files that do not specify their own version explicitly.
  """
  @min_version -1
  def min_version, do: @min_version

  @doc """
    The latest version of Renew to be used preferably.
  """
  @latest_version 11
  def latest_version, do: @latest_version

  @doc """
  This struct describes the class hierarchy for a specific version of [Renew](http://renew.de) that should be applied as grammar.
  The `version` field is an integer between -1 (the original renew version) and 11 (the newest Renew version at the time of writing this comment).

  The `hierarchy` field contains a `Map` from Java class names to class descriptions. It mirrors the Java class definitions defined in Renew.
  This is done because the grammar that is used for reading and writing Renew files is implicitly defined via the Java implementation.
  In order to match the grammar exactly this Java class hierarchy is reenacted.
  """
  defstruct [:version, :hierarchy]

  @doc """
  Constructs a new grammar struct for the given version.
  """
  def new(version \\ latest_version()) do
    %Renewex.Grammar{
      version: version,
      hierarchy: %{
        "CH.ifa.draw.standard.AbstractFigure" => %{
          # This class has no super class in Java
          super: nil,
          # This class implements two interfaces in Java
          interfaces: ["CH.ifa.draw.framework.Figure", "CH.ifa.draw.framework.ParentFigure"]
        },
        "CH.ifa.draw.standard.CompositeFigure" => %{
          # This java class is defined as sub class of another class (`CH.ifa.draw.standard.AbstractFigure`)
          # When reading a serialized object of this class 
          # the parser for the parent class is applied first.
          # This mirrors the `super.read()` Java code in the original Renew implementation.
          super: "CH.ifa.draw.standard.AbstractFigure",
          interfaces: ["CH.ifa.draw.framework.Figure"],
          # This class has one field (`figures`) that is serialized.
          # The field is a list of serialized objects (each of type `CH.ifa.draw.framework.Figure`)
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
          # This class containes 4 primitive fields of type integer
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
            # this field is of type `de.renew.hierarchicalworkflownets.gui.HNModel`
            # but will not prefixed with its class name.
            # So instead of `:storable` the `:rule` symbol causes the parsing rule to 
            # be explizitly applied 
            hn_model: {:rule, "de.renew.hierarchicalworkflownets.gui.HNModel"},
            # figures is a list of storables
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
          fields: [
            # The `points` field is a list of (int, int) tuples
            points: {:list, [x: :int, y: :int]}
          ]
        },
        "de.renew.hierarchicalworkflownets.gui.HNTransitionFigure" => %{
          super: "de.renew.gui.TransitionFigure",
          interfaces: []
        },
        "de.renew.hierarchicalworkflownets.gui.layout.Vec2d" => %{
          super: nil,
          interfaces: [],
          # a vec2d consists of two float typed fields (x and y)
          fields: [x: :float, y: :float]
        },
        "CH.ifa.draw.figures.EllipseFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          # an EllipseFigure consists of four integer fields (x, y, w[idth], [h]eight)
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
              # in version 4 and later the TransitionFigure as an additional field to reference its `highlight_figure`
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
              # in version 3 and later the PlaceFigure as an additional field to reference its `highlight_figure`
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
        "de.uni_hamburg.tgi.renew.marianets.QueryFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: [],
          # `QueryFigure` is a TextFigure with two additional fields of type `int`
          # But not sure what these fields are.
          # Maybe width and height?
          fields: [unknown: :int, unknown: :int]
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
          # when parsing an RoundtripNetComponentFigure
          # we expect to see either a ref or a string but we do not want to store
          # the parsed values but skip them.
          # The `nil` key signifies the field to be skipped.
          fields: [nil: [:ref, :string, default: {:string, "SKIPPED_WHILE_PARSING"}]]
        },
        "de.renew.bpmn.figures.PoolFigure" => %{
          super: "de.renew.netcomponents.NetComponentFigure",
          interfaces: [
            "de.renew.bpmn.figures.BPMNSwimlane",
            "de.renew.bpmn.figures.MessageFlowConnectable",
            "de.renew.bpmn.figures.PartialSelectableFigure"
          ],
          fields: [x: :int, y: :int, w: :int, h: :int]
        },
        "de.renew.bpmn.figures.GatewayFigure" => %{
          super: "CH.ifa.draw.contrib.DiamondFigure",
          interfaces: [
            "de.renew.bpmn.figures.BPMNFlowObject",
            "de.renew.bpmn.figures.SequenceFlowConnectable"
          ],
          fields: [type: :int]
        },
        "de.renew.bpmn.figures.AbstractBPMNConnection" => %{
          super: "CH.ifa.draw.figures.LineConnection",
          interfaces: [
            "CH.ifa.draw.framework.ConnectionFigure"
          ],
          fields: []
        },
        "de.renew.bpmn.figures.ActivityFigure" => %{
          super: "CH.ifa.draw.figures.RoundRectangleFigure",
          interfaces: [
            "de.renew.bpmn.figures.BPMNFlowObject",
            "de.renew.bpmn.figures.SequenceFlowConnectable",
            "de.renew.bpmn.figures.MessageFlowConnectable"
          ],
          fields: [type: :int]
        },
        "de.renew.bpmn.figures.MessageFlowConnection" => %{
          super: "de.renew.bpmn.figures.AbstractBPMNConnection",
          interfaces: [
            "de.renew.bpmn.figures.BPMNConnectingObject"
          ],
          fields: []
        },
        "de.renew.bpmn.figures.BPMNTextFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: [
            "de.renew.bpmn.figures.BPMNFigure"
          ],
          fields: [type: :int]
        },
        "de.renew.bpmn.figures.EventFigure" => %{
          super: "CH.ifa.draw.figures.EllipseFigure",
          interfaces: [
            "de.renew.bpmn.figures.BPMNFlowObject",
            "de.renew.bpmn.figures.SequenceFlowConnectable",
            "de.renew.bpmn.figures.MessageFlowConnectable"
          ],
          fields: [position: :int, type: :int, throwing: :boolean]
        },
        "de.renew.bpmn.figures.PoolNameFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: [],
          fields: []
        },
        "de.renew.bpmn.figures.DataFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          fields: [x: :int, y: :int, w: :int, h: :int, type: :int]
        },
        "de.renew.bpmn.figures.DataStoreFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          fields: [x: :int, y: :int, w: :int, h: :int]
        },
        "de.renew.bpmn.figures.SequenceFlowConnection" => %{
          super: "de.renew.bpmn.figures.AbstractBPMNConnection",
          interfaces: [
            "de.renew.bpmn.figures.BPMNConnectingObject"
          ],
          fields: []
        },
        "de.renew.fa.figures.FAStateFigure" => %{
          super: "CH.ifa.draw.figures.EllipseFigure",
          interfaces: [],
          fields:
            Enum.concat(
              if(version >= 3,
                do: [figure: {:storable, "CH.ifa.draw.framework.Figure"}],
                else: []
              ),
              decoration: {:storable, "de.renew.fa.figures.FigureDecoration"},
              nil: [:ref, :string, default: {:string, "SKIPPED_WHILE_PARSING"}]
            )
        },
        "de.renew.fa.figures.StartDecoration" => %{
          super: nil,
          interfaces: ["de.renew.fa.figures.FigureDecoration"],
          fields: []
        },
        "de.renew.fa.figures.EndDecoration" => %{
          super: nil,
          interfaces: ["de.renew.fa.figures.FigureDecoration"],
          fields: []
        },
        "de.renew.fa.figures.StartEndDecoration" => %{
          super: nil,
          interfaces: ["de.renew.fa.figures.FigureDecoration"],
          fields: []
        },
        "de.renew.fa.figures.NullDecoration" => %{
          super: nil,
          interfaces: ["de.renew.fa.figures.FigureDecoration"],
          fields: []
        },
        "de.renew.fa.figures.FATextFigure" => %{
          super: "de.renew.gui.CPNTextFigure",
          interfaces: [],
          fields: []
        },
        "de.renew.fa.figures.FAWordTextFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: [],
          fields: []
        },
        "de.renew.fa.figures.FAArcConnection" => %{
          super: "CH.ifa.draw.figures.LineConnection",
          interfaces: [],
          fields: []
        },
        "de.renew.interfacenets.datatypes.InterfaceLabelTextFigure" => %{
          super: "CH.ifa.draw.figures.TextFigure",
          interfaces: [],
          fields: []
        },
        "de.renew.interfacenets.datatypes.InterfaceBoxFigure" => %{
          super: "de.renew.interfacenets.datatypes.InterfaceAbstractFigure",
          interfaces: [],
          fields: []
        },
        "de.renew.interfacenets.datatypes.InterfaceFigure" => %{
          super: "de.renew.interfacenets.datatypes.InterfaceAbstractFigure",
          interfaces: [],
          fields: []
        },
        "de.renew.interfacenets.datatypes.InterfaceAbstractFigure" => %{
          super: "CH.ifa.draw.figures.CompositeAttributeFigure",
          interfaces: [],
          fields: [x: :int, y: :int, w: :int, h: :int]
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
          super: "CH.ifa.draw.figures.AttributeFigure",
          skip_super: version < 1,
          interfaces: ["CH.ifa.draw.figures.PolyLineable"],
          fields:
            Enum.concat([
              # The PolyLineFigure has different fields depending on the version of Renew
              [
                points: {:list, [x: :int, y: :int]},
                start_decoration: {:storable, "CH.ifa.draw.figures.LineDecoration"},
                end_decoration: {:storable, "CH.ifa.draw.figures.LineDecoration"}
              ],
              if(version >= 8, do: [arrow_name: :string], else: []),
              if(version == min_version(), do: [frame_color: :color_rgb], else: [])
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
        "CH.ifa.draw.figures.ChopPieConnector" => %{
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
            if(version > min_version() and version <= 5,
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
          fields: [type: :int]
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
        "CH.ifa.draw.figures.PieFigure" => %{
          super: "CH.ifa.draw.figures.AttributeFigure",
          interfaces: [],
          fields: [x: :int, y: :int, w: :int, h: :int, start_angle: :float, end_angle: :float]
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
          fields: [
            decoration: {:storable, "de.renew.diagram.FigureDecoration"},
            nil: [:string, default: {:string, "de.renew.diagram.FigureDecoration"}]
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
          interfaces: [],
          fields: [
            decoration: {:storable, "de.renew.diagram.FigureDecoration"},
            nil: [:string, default: {:string, "de.renew.diagram.FigureDecoration"}]
          ]
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
        "de.renew.gui.CompositionArrowTip" => %{
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
  Applies a specific rul to the current parser state.

  ## Parameters
  - parser: the current state of the parser
  - rule: the name of the parser rule to apply. The parse rule is a java class name that must be defined in the grammars hierarchy.
  - into: an `Storable` struct into which the parsed values shall be appended

  ## Returns
  - `{:ok, Renew.Storable{into | fields: parsed_fields}, next_parse_state}` if the rule was applied successfully.
    Where `parsed_fields` contain the values that have been parsed by the rule and next_parse_state is the 
    state of the parser after having consumed the tokens processed by the parse rule
  - `{:error, reason, next_parse_state}` if the rule could not be applied for some reason.
  """
  def parse(parser, rule, into)

  # The FigureAttributes class has some custom parser logic that is not simply derived from the class hierarchy
  # Instead it is defined in this function
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

  # The AttributeFigure class has some custom parser logic that is not simply derived from the class hierarchy
  # Instead it is defined in this function
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

  # The FSFigure class has some custom parser logic that is not simply derived from the class hierarchy
  # Instead it is defined in this function
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

  # If the custom parse functions defined above do not match, this generic function uses the 
  # class definitions defined in the grammar hierarchy to apply some generic parse rules. 
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

  # Applies parser rules according to the given fields definition.
  # The fields definitions is defined per java class name in the grammars hierarchy.
  defp parse_fields(parser, fields, into) do
    Enum.reduce(fields, {:ok, into, parser}, fn
      # Skip the field if the fields name/key is nil
      {nil, [_ | _] = types}, {:ok, into, parser} ->
        with {:ok, nil, next_parser} <- Parser.skip_any(parser, types) do
          {:ok, into, next_parser}
        end

      # If the type of the field is :list, continue reading the fields value as list
      {field_name, {:list, list_type}}, {:ok, into, parser} ->
        with {:ok, value, next_parser} <- parse_list_field(parser, list_type) do
          {:ok,
           into
           |> put_in([field_name], value), next_parser}
        end

      # If the type of the field is :color_rgb, continue to the the rgb values
      {field_name, :color_rgb}, {:ok, into, parser} ->
        with {:ok, color, next_parser} <- parse_color_rgb(parser) do
          {:ok,
           into
           |> put_in([field_name], color), next_parser}
        end

      # If the type of the field is :color_rgba, continue to the the rgba values
      {field_name, :color_rgba}, {:ok, into, parser} ->
        with {:ok, color, next_parser} <- parse_color_rgba(parser) do
          {:ok,
           into
           |> put_in([field_name], color), next_parser}
        end

      # If the type of the field is :storable, continue parsing the storable of a specified type.
      # If `of_type` is nil, accept whatever storable is indicated by the next token
      # If `of_type` is a name of some interface, check if the storable that is parsed implements
      # that interface according to the grammars java class hierarchy.
      {field_name, {:storable, of_type}}, {:ok, into, parser} when is_binary(of_type) ->
        with {:ok, value, next_parser} <- Parser.parse_storable(parser, of_type) do
          {:ok,
           into
           |> put_in([field_name], value), next_parser}
        end

      # If the field is of type :rule, containue parsing according the the specified rule.
      # The rule must be a class name definied in the grammars hierarchy.
      {field_name, {:rule, of_type}}, {:ok, into, parser} when is_binary(of_type) ->
        with {:ok, value, next_parser} <- Parser.parse_grammar_rule(parser, of_type) do
          {:ok,
           into
           |> put_in([field_name], value), next_parser}
        end

      # If the field is of some primitive type, try to parse one token of this type.
      {field_name, primitive_type}, {:ok, into, parser} when is_atom(primitive_type) ->
        with {:ok, value, next_parser} <- Parser.parse_primitive(parser, primitive_type) do
          {:ok,
           into
           |> put_in([field_name], value), next_parser}
        end

      _, err ->
        err
    end)
  end

  # This function parses a list of values according to a type spec describing the
  # a single item of the list.
  defp parse_list_field(parser, type_spec) do
    # Try to parse a list of items, with each item matching the type spec.
    Parser.parse_list(parser, fn
      p ->
        case type_spec do
          # If the type_spec is a storable, try to parse a storable as list item
          {:storable, type} ->
            Parser.parse_storable(p, type)

          # If the type_spec is a grammar rule, try to apply the given grammar rule to parse the list item
          {:rule, type} ->
            Parser.parse_grammar_rule(p, type)

          # If the type_spec is some primitive type, try to read a single token of that type. 
          primitive when is_atom(primitive) ->
            Parser.parse_primitive(p, primitive)

          # If the type_spec is a list, try to read multiple values according to the types described by the list
          multiples when is_list(multiples) ->
            parse_fields(p, multiples, [])
        end
    end)
  end

  # Parser for reading Figure attributes according to the Renew java implementation.
  # An attribute is expected to be an n-tuple [(v_1,v_2,..v_n)] with n >= 2.
  # With v_1 containing the name/key of the attribute, v_2 containing the type of the attribute
  # and the remaining v_3...v_n containg the attribute values depending on the type.
  # 
  # For example an attribute of type "Color" contains Red, Green, and Blue channel values as integers
  # as v_3,v_4 and v_5. And an additional alpha value as v_6 for renew version > 10.
  defp parse_attribute(parser) do
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

  # Helper function to parse 4 color channels: rgba
  defp parse_color_rgba(parser) do
    {:ok, r, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, g, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, b, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, a, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok, {:rgba, r, g, b, a}, next_parser}
  end

  # Helper function to parse 3 color channels: rgb
  defp parse_color_rgb(parser) do
    {:ok, r, next_parser} = Parser.parse_primitive(parser, :int)
    {:ok, g, next_parser} = Parser.parse_primitive(next_parser, :int)
    {:ok, b, next_parser} = Parser.parse_primitive(next_parser, :int)

    {:ok, {:rgb, r, g, b}, next_parser}
  end

  # Helper function to serialize 4 color channels: rgba
  defp serialize_color_rgba(ser, {:rgba, r, g, b, a}) do
    ser
    |> Serializer.append_token({:int, r})
    |> Serializer.append_token({:int, g})
    |> Serializer.append_token({:int, b})
    |> Serializer.append_token({:int, a})
    |> then(&{:ok, &1})
  end

  # Fallback emits error if the color format does not match
  defp serialize_color_rgba(_, color) do
    {:error, {:rgba, color}}
  end

  # Helper function to parse 3 color channels: rgb
  defp serialize_color_rgb(ser, {:rgb, r, g, b}) do
    ser
    |> Serializer.append_token({:int, r})
    |> Serializer.append_token({:int, g})
    |> Serializer.append_token({:int, b})
    |> then(&{:ok, &1})
  end

  # Fallback emits error if the color format does not match
  defp serialize_color_rgb(_, color) do
    {:error, {:rgb, color}}
  end

  @doc """
  Serialize the given `field_values` according to the given grammar `rule`.

  ## Parameters
  - `serializer`: The serializer into which output the result is appended.
  - `rule`: The name of the grammar rule to be used for serializtation. The actual grammar definition comes from the `serializer`.
  - `field_values`: The map of values to be serialized.

  ## Resturns
  Either `{:ok, new_serializer}` if the serializtation was successful.
  Otheriwse `{:error, reason}` if it failed for some `reason`.
  """
  def serialize(
        serializer,
        rule,
        field_values
      )

  # The FigureAttributes class has some custom serializer logic that is not simply derived from the class hierarchy
  # Instead it is defined in this function
  def serialize(
        %Serializer{grammar: grammar} = serializer,
        "CH.ifa.draw.figures.FigureAttributes",
        %{} = field_values
      ) do
    serializer
    |> Serializer.append_token({:string, "attributes"})
    |> Serializer.serialize_list(field_values.attributes, fn
      {name, type, value}, ser ->
        next_ser =
          ser
          |> Serializer.append_token({:string, name})
          |> Serializer.append_token({:string, type})

        case type do
          "Color" ->
            if(grammar.version < 11,
              do: serialize_color_rgb(next_ser, value),
              else: serialize_color_rgba(next_ser, value)
            )

          "Boolean" ->
            {:ok,
             Serializer.append_token(next_ser, {:string, if(value, do: "true", else: "false")})}

          "String" ->
            {:ok, Serializer.append_token(next_ser, {:string, value})}

          "Int" ->
            {:ok, Serializer.append_token(next_ser, {:int, value})}

          "Storable" ->
            Serializer.serialize_storable(next_ser, value)

          "UNKNOWN" ->
            ser
            |> Serializer.append_token({:string, name})
            |> Serializer.append_token({:string, "UNKNOWN"})
            |> then(&{:ok, &1})
        end
    end)
  end

  # The AttributeFigure class has some custom serializer logic that is not simply derived from the class hierarchy
  # Instead it is defined in this function
  def serialize(
        %Serializer{} = serializer,
        "CH.ifa.draw.figures.AttributeFigure",
        field_values
      ) do
    case Map.get(field_values, :attributes) do
      nil ->
        serializer
        |> Serializer.append_token({:string, "no_attributes"})
        |> then(&{:ok, &1})

      attrs ->
        serializer
        |> Serializer.append_token({:string, "attributes"})
        |> Serializer.serialize_grammar_rule("CH.ifa.draw.figures.FigureAttributes", attrs.fields)
    end
  end

  # The FSFigure class has some custom serializer logic that is not simply derived from the class hierarchy
  # Instead it is defined in this function
  def serialize(
        %Serializer{} = serializer,
        "de.renew.gui.fs.FSFigure",
        field_values
      ) do
    if serializer.grammar.version <= 5 do
      {:ok, serializer}
    else
      if serializer.grammar.version > 6 do
        Serializer.serialize_list(serializer, field_values.paths, fn item, ser ->
          {:ok, Serializer.append_token(ser, {:string, item})}
        end)
      else
        {:ok, serializer}
      end
    end
  end

  # The default implementation of serialize uses the rules defined in the `grammar` of the `serializer` to 
  # determine the serializtation format.
  def serialize(%Serializer{grammar: grammar} = serializer, rule, field_values) do
    fields = Map.get(grammar.hierarchy[rule], :fields, [])

    serialize_fields(serializer, fields, field_values)
  end

  # Opposite of `parse_fields`
  defp serialize_fields(serializer, fields, field_values) do
    fields
    |> Enum.reduce({:ok, serializer}, fn
      {nil, types}, {:ok, %Serializer{} = ser} ->
        with {type, value} <- Keyword.get(types, :default) do
          {:ok, Serializer.append_token(ser, {type, value})}
        else
          _ -> {:ok, ser}
        end

      {field_name, {:list, list_type}}, {:ok, %Serializer{} = ser} ->
        serialize_list_field(ser, field_values[field_name], list_type)

      {field_name, {:storable, rule}}, {:ok, %Serializer{} = ser} ->
        Serializer.serialize_storable(ser, field_values[field_name], rule)

      {field_name, {:rule, rule}}, {:ok, %Serializer{} = ser} ->
        Serializer.serialize_grammar_rule(ser, rule, field_values[field_name].fields)

      {field_name, :color_rgb}, {:ok, %Serializer{} = ser} ->
        serialize_color_rgb(ser, field_values[field_name])

      {field_name, :color_rgba}, {:ok, %Serializer{} = ser} ->
        serialize_color_rgba(ser, field_values[field_name])

      {field_name, field_type}, {:ok, %Serializer{} = ser} ->
        {:ok, Serializer.append_token(ser, {field_type, field_values[field_name]})}

      _, e ->
        e
    end)
  end

  # Opposite of `parse_list`
  defp serialize_list_field(serializer, list, type_spec) do
    Serializer.serialize_list(serializer, list, fn item, ser ->
      case type_spec do
        {:storable, rule} ->
          Serializer.serialize_storable(ser, item, rule)

        {:rule, rule} ->
          Serializer.serialize_grammar_rule(ser, rule, item)

        primitive when is_atom(primitive) ->
          {:ok, Serializer.append_token(ser, {primitive, item})}

        # If the type_spec is a list, try to read multiple values according to the types described by the list
        multiples when is_list(multiples) ->
          serialize_fields(ser, multiples, item)
      end
    end)
  end

  @doc """
  Checks if for the given grammar and given class name the skip skip_super flag is set.
  If the skip_super flag is set, the grammar rules of the parent class shall not be applied during parsing.
  This corresponds to NOT calling `super.read()` in the java implementation of the class.

  ## Parameters
  - grammar: the current state of the parser
  - rule: name of the grammar rule

  ## Returns
  - if the the :skip_user flag has been set for the given rule in the given grammar.
  """
  def should_skip_super(grammar, rule) do
    if Map.has_key?(grammar.hierarchy, rule) do
      Map.get(grammar.hierarchy[rule], :skip_super, false)
    else
      false
    end
  end
end
