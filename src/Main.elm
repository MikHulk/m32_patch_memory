port module Main exposing (..)

import AssocList as Al
import Browser
import Html
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode as JsonD
import Json.Encode as JsonE
import Svg
import Svg.Attributes as SvgA
import Svg.Events as SvgE


main : Program JsonE.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : JsonE.Value -> ( Model, Cmd Msg )
init flags =
    let
        setups =
            getSetups flags
    in
    ( { device = mother32
      , selectedColor = "red"
      , patchesCurve = 1.7
      , notes =
            { newNote = ""
            , notes = []
            }
      , setups = { newSetup = "", setups = setups }
      , dialog = None
      }
    , Cmd.none
    )


colors : List String
colors =
    [ "red", "green", "blue", "gold", "black", "grey" ]


mother32 : Device
mother32 =
    { knobs =
        [ { value = 0.505
          , position = ( 80.7, 57.4 )
          , boundTo = Frequency
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
          , position = ( 247.6, 57.4 )
          , boundTo = PulseWidth
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.01
          , position = ( 331, 57.4 )
          , boundTo = Mix
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.99
          , position = ( 431.5, 57.4 )
          , boundTo = Cutoff
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.307
          , position = ( 532.5, 57.4 )
          , boundTo = Resonance
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
          , position = ( 665, 57.4 )
          , boundTo = Volume
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.01
          , position = ( 80.8, 140.2 )
          , boundTo = Glide
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.01
          , position = ( 247.6, 140.2 )
          , boundTo = VcoModAmount
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
          , position = ( 581, 140.2 )
          , boundTo = VcfModAmount
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
          , position = ( 135.8, 223.55 )
          , boundTo = TempoGate
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
          , position = ( 247.8, 223.55 )
          , boundTo = LfoRate
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.01
          , position = ( 414.5, 223.55 )
          , boundTo = Attack
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
          , position = ( 581, 223.55 )
          , boundTo = Decay
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.01
          , position = ( 665, 223.55 )
          , boundTo = VcMix
          , geo = Nothing
          , isMoving = False
          }
        ]
    , switches =
        [ { direction = Up
          , position = ( 164.75, 57.76 )
          , boundTo = VcoWave
          }
        , { direction = Down
          , position = ( 601.7, 57.76 )
          , boundTo = VcaMode
          }
        , { direction = Up
          , position = ( 164.75, 140.2 )
          , boundTo = VcoModSource
          }
        , { direction = Up
          , position = ( 331.5, 140.2 )
          , boundTo = VcoModDest
          }
        , { direction = Down
          , position = ( 414.5, 140.2 )
          , boundTo = VcfMode
          }
        , { direction = Up
          , position = ( 498.5, 140.2 )
          , boundTo = VcfModSource
          }
        , { direction = Up
          , position = ( 665, 140.2 )
          , boundTo = VcfModPolarity
          }
        , { direction = Down
          , position = ( 331.5, 223.55 )
          , boundTo = LfoWave
          }
        , { direction = Down
          , position = ( 498.5, 223.55 )
          , boundTo = Sustain
          }
        ]
    , inputs =
        [ { position = ( 729.5, 41 )
          , boundTo = ExtAudio
          , isSelected = False
          }
        , { position = ( 769, 41 )
          , boundTo = MixCv
          , isSelected = False
          }
        , { position = ( 808.4, 41 )
          , boundTo = VcaCv
          , isSelected = False
          }
        , { position = ( 769, 80 )
          , boundTo = VcfCutoff
          , isSelected = False
          }
        , { position = ( 808.4, 80 )
          , boundTo = VcfRes
          , isSelected = False
          }
        , { position = ( 729.5, 119 )
          , boundTo = Vco1vOct
          , isSelected = False
          }
        , { position = ( 769, 119 )
          , boundTo = VcoLinFm
          , isSelected = False
          }
        , { position = ( 729.5, 157 )
          , boundTo = VcoMod
          , isSelected = False
          }
        , { position = ( 769, 157 )
          , boundTo = LfoRateIn
          , isSelected = False
          }
        , { position = ( 729.5, 196 )
          , boundTo = Mix1
          , isSelected = False
          }
        , { position = ( 769, 196 )
          , boundTo = Mix2
          , isSelected = False
          }
        , { position = ( 808.4, 196 )
          , boundTo = VcMixCtrl
          , isSelected = False
          }
        , { position = ( 729.5, 235 )
          , boundTo = Mult
          , isSelected = False
          }
        , { position = ( 729.5, 273.7 )
          , boundTo = GateIn
          , isSelected = False
          }
        , { position = ( 729.5, 313 )
          , boundTo = Tempo
          , isSelected = False
          }
        , { position = ( 769, 313 )
          , boundTo = RunStop
          , isSelected = False
          }
        , { position = ( 808.4, 313 )
          , boundTo = Reset
          , isSelected = False
          }
        , { position = ( 847, 313 )
          , boundTo = Hold
          , isSelected = False
          }
        ]
    , outputs =
        [ { position = ( 847, 41 )
          , boundTo = Vca
          , isSelected = False
          }
        , { position = ( 729.5, 80 )
          , boundTo = Noise
          , isSelected = False
          }
        , { position = ( 847, 80 )
          , boundTo = Vcf
          , isSelected = False
          }
        , { position = ( 807.7, 119 )
          , boundTo = VcoSaw
          , isSelected = False
          }
        , { position = ( 847, 119 )
          , boundTo = VcoPulse
          , isSelected = False
          }
        , { position = ( 807.7, 157 )
          , boundTo = LfoTri
          , isSelected = False
          }
        , { position = ( 847, 157 )
          , boundTo = LfoSq
          , isSelected = False
          }
        , { position = ( 847, 196 )
          , boundTo = VcMixOut
          , isSelected = False
          }
        , { position = ( 769, 235 )
          , boundTo = Mult1
          , isSelected = False
          }
        , { position = ( 808, 235 )
          , boundTo = Mult2
          , isSelected = False
          }
        , { position = ( 847, 235 )
          , boundTo = Assign
          , isSelected = False
          }
        , { position = ( 769, 273.7 )
          , boundTo = Eg
          , isSelected = False
          }
        , { position = ( 808, 273.7 )
          , boundTo = Kb
          , isSelected = False
          }
        , { position = ( 847, 273.7 )
          , boundTo = GateOut
          , isSelected = False
          }
        ]
    , patches = Al.empty
    }



-- Model


type alias Model =
    { device : Device
    , selectedColor : String
    , patchesCurve : Float
    , notes : NotesModel
    , setups : SetupModel
    , dialog : Dialog
    }


type alias SetupModel =
    { newSetup : String
    , setups : List String
    }


type alias NotesModel =
    { newNote : String
    , notes : List String
    }


type alias Knob =
    { value : Float
    , position : ( Float, Float )
    , boundTo : Parameter
    , geo : Maybe BoundingClientRect
    , isMoving : Bool
    }


type alias Switch =
    { direction : Direction
    , position : ( Float, Float )
    , boundTo : Parameter
    }


type alias Jack =
    { boundTo : Parameter
    , position : ( Float, Float )
    , isSelected : Bool
    }


type alias Device =
    { knobs : List Knob
    , switches : List Switch
    , inputs : List Jack
    , outputs : List Jack
    , patches : Al.Dict ( Parameter, Parameter ) String
    }


type alias KnobSetup =
    { parameter : String, value : Float }


type alias SwitchSetup =
    { parameter : String, direction : String }


type alias PatchSetup =
    { in_ : String, out : String, color : String }


type alias DeviceSetup =
    { knobs : List KnobSetup
    , switches : List SwitchSetup
    , patches : List PatchSetup
    }


type alias Setup =
    { device : DeviceSetup
    , notes : List String
    }


type alias BoundingClientRect =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , top : Float
    , right : Float
    , bottom : Float
    , left : Float
    }


type Direction
    = Up
    | Down


type Dialog
    = LoadBox
    | ManageBox
    | None


type Parameter
    = Frequency
    | PulseWidth
    | Mix
    | Cutoff
    | Resonance
    | Volume
    | Glide
    | VcoModAmount
    | VcfModAmount
    | TempoGate
    | LfoRate
    | Attack
    | Decay
    | VcMix
    | VcoWave
    | VcaMode
    | VcoModSource
    | VcoModDest
    | VcfMode
    | VcfModSource
    | VcfModPolarity
    | LfoWave
    | Sustain
    | Vca
    | Noise
    | Vcf
    | VcoSaw
    | VcoPulse
    | LfoTri
    | LfoSq
    | VcMixOut
    | Mult1
    | Mult2
    | Assign
    | Eg
    | Kb
    | GateOut
    | ExtAudio
    | MixCv
    | VcaCv
    | VcfCutoff
    | VcfRes
    | Vco1vOct
    | VcoLinFm
    | VcoMod
    | LfoRateIn
    | Mix1
    | Mix2
    | VcMixCtrl
    | Mult
    | GateIn
    | Tempo
    | RunStop
    | Reset
    | Hold



-- Update


type KnobMsg
    = Move
    | StopMoving
    | ChangePosition ( Float, Float )


type NoteMsg
    = UserSubmitNewNote
    | UserUpdateNewNote String
    | UserRemoveNote Int


type Msg
    = UserSetKnob Parameter KnobMsg
    | UserSetSwitch Parameter
    | UserClickJackOut Parameter
    | UserClickJackIn Parameter
    | UserSelectColor String
    | UserChangeCurve (Maybe Float)
    | UserNote NoteMsg
    | UserCloseModal
    | UserOpenLoadBox
    | UserOpenManageBox
    | UserSelectSetup String
    | UserUpdateNewSetup String
    | UserCommitNewSetup
    | UserUpdateSetup String
    | UserDeleteSetup String
    | GotKnobRect Parameter BoundingClientRect
    | ReceiveSetupList JsonE.Value
    | ReceiveSetup JsonE.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserSetKnob param knobMsg ->
            knobUpdate param knobMsg model

        UserSetSwitch param ->
            let
                switches =
                    updateSwitch
                        model.device.switches
                        param
                        (\switch ->
                            case switch.direction of
                                Up ->
                                    { switch | direction = Down }

                                Down ->
                                    { switch | direction = Up }
                        )

                device =
                    model.device
            in
            ( { model | device = { device | switches = switches } }
            , Cmd.none
            )

        UserClickJackOut output ->
            case findJack (\jack -> jack.isSelected) model.device.inputs of
                Just jack ->
                    let
                        device =
                            model.device

                        transform jack_ =
                            if jack_.boundTo == output then
                                jack_

                            else
                                { jack_ | isSelected = False }

                        outputs =
                            List.map transform device.outputs

                        inputs =
                            List.map
                                (\jack_ -> { jack_ | isSelected = False })
                                device.inputs

                        input =
                            jack.boundTo

                        patches =
                            if Al.member ( input, output ) device.patches then
                                Al.remove ( input, output ) device.patches

                            else
                                Al.insert ( input, output ) model.selectedColor device.patches
                    in
                    ( { model
                        | device =
                            { device
                                | inputs = inputs
                                , outputs = outputs
                                , patches = patches
                            }
                      }
                    , Cmd.none
                    )

                Nothing ->
                    let
                        transform jack_ =
                            if jack_.boundTo == output then
                                { jack_ | isSelected = True }

                            else
                                { jack_ | isSelected = False }

                        device =
                            model.device

                        outputs =
                            List.map transform device.outputs
                    in
                    ( { model | device = { device | outputs = outputs } }
                    , Cmd.none
                    )

        UserClickJackIn input ->
            case findJack (\jack -> jack.isSelected) model.device.outputs of
                Just jack ->
                    let
                        device =
                            model.device

                        transform jack_ =
                            if jack_.boundTo == input then
                                jack_

                            else
                                { jack_ | isSelected = False }

                        inputs =
                            List.map transform device.inputs

                        outputs =
                            List.map
                                (\jack_ -> { jack_ | isSelected = False })
                                device.outputs

                        output =
                            jack.boundTo

                        patches =
                            if Al.member ( input, output ) device.patches then
                                Al.remove ( input, output ) device.patches

                            else
                                Al.insert ( input, output ) model.selectedColor device.patches
                    in
                    ( { model
                        | device =
                            { device
                                | outputs = outputs
                                , inputs = inputs
                                , patches = patches
                            }
                      }
                    , Cmd.none
                    )

                Nothing ->
                    let
                        transform jack_ =
                            if jack_.boundTo == input then
                                { jack_ | isSelected = True }

                            else
                                { jack_ | isSelected = False }

                        device =
                            model.device

                        inputs =
                            List.map transform device.inputs
                    in
                    ( { model | device = { device | inputs = inputs } }, Cmd.none )

        UserSelectColor color ->
            ( { model | selectedColor = color }, Cmd.none )

        UserChangeCurve curveOpt ->
            case curveOpt of
                Just curve ->
                    ( { model | patchesCurve = curve }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        UserNote noteMsg ->
            let
                ( notesModel, cmd ) =
                    noteUpdate noteMsg model.notes
            in
            ( { model | notes = notesModel }, cmd )

        UserCloseModal ->
            ( { model | dialog = None }, Cmd.none )

        UserSelectSetup name ->
            ( { model | dialog = None }, Cmd.batch [ loadSetup name ] )

        UserDeleteSetup name ->
            ( model, Cmd.batch [ removeSetup name ] )

        UserUpdateNewSetup name ->
            ( { model
                | setups =
                    { setups = model.setups.setups
                    , newSetup = name
                    }
              }
            , Cmd.none
            )

        UserUpdateSetup name ->
            ( { model | dialog = None }
            , Cmd.batch [ saveSetup ( name, encodeSetup model ) ]
            )

        UserCommitNewSetup ->
            ( { model
                | setups =
                    { setups = model.setups.setups
                    , newSetup = ""
                    }
                , dialog = None
              }
            , Cmd.batch [ saveSetup ( model.setups.newSetup, encodeSetup model ) ]
            )

        UserOpenLoadBox ->
            ( { model | dialog = LoadBox }, Cmd.none )

        UserOpenManageBox ->
            ( { model | dialog = ManageBox }, Cmd.none )

        GotKnobRect param rect ->
            let
                knobs =
                    updateKnob
                        model.device.knobs
                        param
                        (\knob_ -> { knob_ | geo = Just rect })

                device =
                    model.device
            in
            ( { model | device = { device | knobs = knobs } }, Cmd.none )

        ReceiveSetupList value ->
            ( { model
                | setups =
                    { setups = getSetups value
                    , newSetup = model.setups.newSetup
                    }
              }
            , Cmd.none
            )

        ReceiveSetup value ->
            ( loadModel model value, Cmd.none )


noteUpdate : NoteMsg -> NotesModel -> ( NotesModel, Cmd Msg )
noteUpdate msg model =
    case msg of
        UserRemoveNote id ->
            let
                notes =
                    List.take id model.notes ++ List.drop (id + 1) model.notes
            in
            ( { model | notes = notes }, Cmd.none )

        UserUpdateNewNote note ->
            ( { model | newNote = note }, Cmd.none )

        UserSubmitNewNote ->
            let
                notes =
                    model.newNote :: model.notes
            in
            ( { model | newNote = "", notes = notes }, Cmd.none )


knobUpdate : Parameter -> KnobMsg -> Model -> ( Model, Cmd Msg )
knobUpdate param msg model =
    case msg of
        Move ->
            let
                knobs =
                    updateKnob
                        model.device.knobs
                        param
                        (\knob -> { knob | isMoving = True })

                device =
                    model.device
            in
            ( { model | device = { device | knobs = knobs } }
            , Cmd.none
            )

        ChangePosition pos ->
            case getKnob param model.device.knobs of
                Just knob ->
                    let
                        f : Knob -> Knob
                        f knob_ =
                            case posToValue knob_ pos of
                                Just value ->
                                    { knob_ | value = value }

                                _ ->
                                    knob_

                        knobs =
                            updateKnob model.device.knobs knob.boundTo f

                        device =
                            model.device
                    in
                    ( { model | device = { device | knobs = knobs } }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        StopMoving ->
            let
                knobs =
                    updateKnob
                        model.device.knobs
                        param
                        (\knob -> { knob | isMoving = False })

                device =
                    model.device
            in
            ( { model | device = { device | knobs = knobs } }
            , Cmd.none
            )



-- Ports


port saveSetup : ( String, JsonE.Value ) -> Cmd msg


port removeSetup : String -> Cmd msg


port loadSetup : String -> Cmd msg


port setupListReceiver : (JsonE.Value -> msg) -> Sub msg


port setupReceiver : (JsonE.Value -> msg) -> Sub msg



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ setupListReceiver ReceiveSetupList
        , setupReceiver ReceiveSetup
        ]



-- View


view : Model -> Html.Html Msg
view model =
    let
        device =
            model.device

        devicePicture =
            [ Svg.image
                [ SvgA.xlinkHref "Mother-32.png"
                , SvgA.width "900"
                ]
                []
            , Svg.rect
                [ SvgA.width "900"
                , SvgA.height "380"
                , SvgA.fill "#AAF"
                , SvgA.opacity "0.17"
                , SvgA.x "0"
                , SvgA.y "0"
                ]
                []
            , colorSelectorView model.selectedColor
            ]

        knobsSvg =
            List.map knobView device.knobs

        switchesSvg =
            List.map switchView device.switches

        jackInSvg =
            List.map (jackView UserClickJackIn) device.inputs

        jackOutSvg =
            List.map (jackView UserClickJackOut) device.outputs

        patchSvg =
            let
                f =
                    Maybe.map (patchView model.patchesCurve)
                        << patchToJack device.inputs device.outputs
            in
            List.filterMap f <|
                Al.toList device.patches

        common =
            [ Html.h1 [ HtmlA.id "header" ] [ Html.text "Mother 32 Patch Memory" ]
            , Html.div
                [ HtmlA.id "device" ]
                [ Svg.svg
                    [ SvgA.viewBox "0 0 900 380"
                    ]
                  <|
                    devicePicture
                        ++ knobsSvg
                        ++ switchesSvg
                        ++ patchSvg
                        ++ jackInSvg
                        ++ jackOutSvg
                ]
            , controlView model
            , noteListView model.notes
            ]

        mainAttrs =
            [ HtmlA.id "app" ]
    in
    Html.main_ mainAttrs <|
        case model.dialog of
            LoadBox ->
                loadBox model.setups :: common

            ManageBox ->
                manageBox model.setups :: common

            _ ->
                common


modal : String -> List (Html.Html Msg) -> Html.Html Msg
modal title content =
    Html.div
        [ HtmlA.class "modal-bg"
        ]
        [ Html.node "dialog"
            [ HtmlA.attribute "open" "1"
            , HtmlA.class "modal"
            , HtmlA.style "padding" "0"
            ]
            [ Html.div
                [ HtmlA.style "display" "flex"
                , HtmlA.class "modal-title"
                ]
                [ Html.h1
                    [ HtmlA.style "margin" "0"
                    , HtmlA.style "width" "100%"
                    ]
                    [ Html.text title ]
                , removeButton
                    [ HtmlE.onClick <| UserCloseModal
                    , HtmlA.style "margin-top" "0px"
                    ]
                ]
            , Html.div
                [ HtmlA.class "modal-content"
                , HtmlA.style "overflow-y" "clip"
                ]
                content
            ]
        ]


loadBoxSetupElem : String -> Html.Html Msg
loadBoxSetupElem setupName =
    Html.div
        [ HtmlA.style "cursor" "pointer"
        , HtmlA.class "setup-elem"
        , HtmlE.onClick <| UserSelectSetup setupName
        ]
        [ Html.text setupName ]


manageBoxSetupElem : String -> Html.Html Msg
manageBoxSetupElem setupName =
    Html.div
        [ HtmlA.style "cursor" "pointer"
        , HtmlA.class "setup-elem"
        , HtmlA.class "manage-box-setup-elem"
        ]
        [ Html.div
            [ HtmlE.onClick <| UserUpdateSetup setupName ]
            [ Html.text setupName ]
        , removeButton
            [ HtmlE.onClick <| UserDeleteSetup setupName
            , HtmlA.style "margin-top" "-1px"
            ]
        ]


setupList :
    List (Html.Attribute Msg)
    -> List (Html.Html Msg)
    -> Html.Html Msg
setupList attrs content =
    Html.div
        (HtmlA.class "setup-list" :: attrs)
    <|
        if List.isEmpty content then
            [ Html.text "found no setup." ]

        else
            content


loadBox : SetupModel -> Html.Html Msg
loadBox model =
    modal "Select a setup" <|
        [ setupList
            [ HtmlA.id "load-box-list" ]
          <|
            List.map loadBoxSetupElem model.setups
        ]


manageBox : SetupModel -> Html.Html Msg
manageBox model =
    modal "Manage your setup" <|
        [ setupList
            [ HtmlA.id "manage-box-list" ]
          <|
            List.map manageBoxSetupElem model.setups
        , Html.div
            [ HtmlA.id "manage-box-input"
            ]
            [ Html.input
                [ HtmlE.onInput UserUpdateNewSetup
                , HtmlA.placeholder "Enter a name for your setup here"
                , HtmlA.value model.newSetup
                ]
                []
            , addButton [ HtmlE.onClick UserCommitNewSetup ]
            ]
        ]


noteView : Int -> String -> Html.Html Msg
noteView id note =
    Html.div
        [ HtmlA.class "note-row"
        ]
        [ Html.div [ HtmlA.class "note" ] [ Html.text note ]
        , removeButton [ HtmlE.onClick <| UserNote <| UserRemoveNote id ]
        ]


noteListView : NotesModel -> Html.Html Msg
noteListView model =
    let
        notes =
            List.indexedMap noteView model.notes
    in
    Html.div
        [ HtmlA.id "notes"
        ]
    <|
        [ Html.div
            [ HtmlA.class "note-row"
            ]
          <|
            [ Html.input
                [ HtmlE.onInput <| UserNote << UserUpdateNewNote
                , HtmlA.placeholder "Enter a new note here"
                , HtmlA.value model.newNote
                ]
                []
            , addButton [ HtmlE.onClick <| UserNote <| UserSubmitNewNote ]
            ]
        ]
            ++ notes


controlView : Model -> Html.Html Msg
controlView model =
    let
        curve =
            model.patchesCurve
                * 1000
                |> round
                |> toFloat
                |> flip (/) 1000.0
                |> String.fromFloat
    in
    Html.div
        [ HtmlA.id "controls"
        ]
        [ Html.h1 [] [ Html.text "Controls" ]
        , Html.label
            []
            [ Html.text <| "curvature(" ++ curve ++ ")" ]
        , Html.input
            [ HtmlA.type_ "range"
            , HtmlA.step "any"
            , HtmlA.value <| String.fromFloat model.patchesCurve
            , HtmlA.min "-5"
            , HtmlA.max "5"
            , HtmlE.onInput (String.toFloat >> UserChangeCurve)
            ]
            []
        , Html.button
            [ HtmlE.onClick UserOpenLoadBox ]
            [ Html.text "Load" ]
        , Html.button
            [ HtmlE.onClick UserOpenManageBox ]
            [ Html.text "Manage" ]
        , Html.button
            []
            [ Html.text "To text" ]
        , Html.button
            []
            [ Html.text "To svg" ]
        ]


patchView : Float -> ( Jack, Jack, String ) -> Svg.Svg Msg
patchView curve ( jackIn, jackOut, color ) =
    let
        ( inX, inY ) =
            jackIn.position

        ( outX, outY ) =
            jackOut.position

        r =
            2.0
    in
    Svg.g []
        [ quadraCurve curve
            [ SvgA.strokeWidth "4"
            , SvgA.stroke color
            , SvgA.fill "none"
            ]
            ( inX, inY )
            ( outX, outY )
        , Svg.circle
            [ SvgA.cx <| String.fromFloat (inX + 12.5)
            , SvgA.cy <| String.fromFloat (inY + 12.7)
            , SvgA.r <| String.fromFloat r
            , SvgA.opacity "1.0"
            , SvgA.fill color
            ]
            []
        , Svg.circle
            [ SvgA.cx <| String.fromFloat (outX + 12.5)
            , SvgA.cy <| String.fromFloat (outY + 12.7)
            , SvgA.r <| String.fromFloat r
            , SvgA.opacity "1.0"
            , SvgA.fill color
            ]
            []
        ]


quadraCurve :
    Float
    -> List (Svg.Attribute Msg)
    -> ( Float, Float )
    -> ( Float, Float )
    -> Svg.Svg Msg
quadraCurve curve attrs ( origX, origY ) ( destX, destY ) =
    let
        ( dist, ang ) =
            toPolar
                ( destX - origX
                , destY - origY
                )

        ( ctrlX, ctrlY ) =
            fromPolar
                ( dist / (2 * cos (pi / (16.0 / curve)))
                , ang - (pi / (16.0 / curve))
                )
    in
    Svg.path
        ([ SvgA.d <|
            "M "
                ++ String.fromFloat (origX + 12.5)
                ++ " "
                ++ String.fromFloat (origY + 12.5)
                ++ " Q "
                ++ String.fromFloat (origX + ctrlX + 12.5)
                ++ " "
                ++ String.fromFloat (origY + ctrlY + 12.5)
                ++ " "
                ++ String.fromFloat (destX + 12.5)
                ++ " "
                ++ String.fromFloat (destY + 12.5)
         ]
            ++ attrs
        )
        []


colorSelectorView : String -> Svg.Svg Msg
colorSelectorView selected =
    let
        square id color =
            let
                base =
                    Svg.rect
                        [ SvgA.width "7"
                        , SvgA.height "7"
                        , SvgA.stroke "black"
                        , SvgA.fill color
                        , SvgA.strokeWidth "1"
                        , SvgA.x <| String.fromFloat (750.0 + toFloat id * 10.0)
                        , SvgA.y "350.0"
                        , SvgE.onClick <| UserSelectColor color
                        ]
                        []

                selectedBox =
                    Svg.rect
                        [ SvgA.width "10"
                        , SvgA.height "10"
                        , SvgA.stroke "red"
                        , SvgA.fill color
                        , SvgA.strokeWidth "1"
                        , SvgA.x <| String.fromFloat (750.0 + toFloat id * 10.0 - 1.5)
                        , SvgA.y "348.5"
                        , SvgE.onMouseDown <| UserSelectColor color
                        ]
                        []
            in
            Svg.g
                [ SvgE.onClick <| UserSelectColor color ]
            <|
                if selected == color then
                    [ selectedBox, base ]

                else
                    [ base ]
    in
    Svg.g [] <| List.indexedMap square colors


jackView : (Parameter -> Msg) -> Jack -> Svg.Svg Msg
jackView msg jack =
    let
        ( cx, cy ) =
            jack.position

        base =
            [ Svg.rect
                [ SvgA.width "25"
                , SvgA.height "25"
                , SvgA.stroke "red"
                , SvgA.fill "black"
                , SvgA.opacity "0.0"
                , SvgA.strokeWidth "1"
                , SvgA.x <| String.fromFloat cx
                , SvgA.y <| String.fromFloat cy
                ]
                []
            ]

        whenSelected =
            [ Svg.rect
                [ SvgA.width "25"
                , SvgA.height "25"
                , SvgA.stroke "red"
                , SvgA.fill "none"
                , SvgA.strokeWidth "1"
                , SvgA.x <| String.fromFloat cx
                , SvgA.y <| String.fromFloat cy
                ]
                []
            ]
    in
    Svg.g
        [ SvgE.onClick (msg jack.boundTo)
        ]
    <|
        if jack.isSelected then
            base ++ whenSelected

        else
            base


switchView : Switch -> Svg.Svg Msg
switchView switch =
    let
        ( cx, cy ) =
            switch.position

        offset =
            case switch.direction of
                Up ->
                    -5

                Down ->
                    5
    in
    Svg.g
        [ SvgE.onMouseDown <| UserSetSwitch switch.boundTo
        ]
        [ Svg.circle
            [ SvgA.cx <| String.fromFloat cx
            , SvgA.cy <| String.fromFloat cy
            , SvgA.r "2"
            , SvgA.opacity "1.0"
            , SvgA.fill "#C56"
            ]
            []
        , Svg.circle
            [ SvgA.cx <| String.fromFloat cx
            , SvgA.cy <| String.fromFloat (cy + offset)
            , SvgA.r "4"
            , SvgA.opacity "1.0"
            , SvgA.stroke "black"
            , SvgA.strokeWidth "0.5"
            , SvgA.fill "#C56"
            ]
            []
        ]


knobView : Knob -> Svg.Svg Msg
knobView knob =
    let
        ( cx, cy ) =
            knob.position

        knobAngle =
            (valueToAngle >> fromClockWise >> rotate 2.03) knob.value

        ( x1, y1 ) =
            fromPolar ( 36.0, knobAngle )

        ( x2, y2 ) =
            fromPolar ( 16.0, knobAngle )

        base =
            [ Svg.defs []
                [ Svg.filter [ SvgA.id "blur" ]
                    [ Svg.feGaussianBlur
                        [ SvgA.stdDeviation "3" ]
                        []
                    ]
                ]
            , Svg.line
                [ SvgA.x1 <| String.fromFloat (cx + x1)
                , SvgA.y1 <| String.fromFloat (cy - y1)
                , SvgA.x2 <| String.fromFloat (cx + x2)
                , SvgA.y2 <| String.fromFloat (cy - y2)
                , SvgA.stroke "#C56"
                , SvgA.strokeWidth "3"
                ]
                []
            , Svg.circle
                [ SvgA.cx <| String.fromFloat cx
                , SvgA.cy <| String.fromFloat cy
                , SvgA.r "34"
                , SvgA.opacity "0.0"
                , SvgE.onMouseDown <| UserSetKnob knob.boundTo Move
                ]
                []
            ]

        children =
            if knob.isMoving then
                base
                    ++ [ Svg.circle
                            [ SvgA.cx <| String.fromFloat cx
                            , SvgA.cy <| String.fromFloat cy
                            , SvgA.r "35"
                            , SvgA.opacity "1.0"
                            , SvgA.fill "none"
                            , SvgA.stroke "blue"
                            , SvgA.strokeWidth "2"
                            , SvgA.filter "url(#blur)"
                            ]
                            []
                       , Svg.circle
                            [ SvgA.cx <| String.fromFloat cx
                            , SvgA.cy <| String.fromFloat cy
                            , SvgA.r "35"
                            , SvgA.opacity "0.0"
                            , SvgE.onMouseUp (UserSetKnob knob.boundTo StopMoving)
                            , SvgE.onMouseOut (UserSetKnob knob.boundTo StopMoving)
                            , onMove (UserSetKnob knob.boundTo << ChangePosition)
                            ]
                            []
                       ]

            else
                base
    in
    Svg.g
        [ SvgE.on
            "mousedown"
            (getBoundingClientRect (GotKnobRect knob.boundTo))
        ]
        children



-- Svg Widgets


addButton : List (Html.Attribute Msg) -> Html.Html Msg
addButton attrs =
    let
        m =
            2.5

        r =
            9.0

        r_ =
            5.0

        c =
            r + m
    in
    Svg.svg
        ([ SvgA.height <| String.fromFloat <| r * 2.0 + m * 2.0
         , SvgA.width <| String.fromFloat <| r * 2.0 + m * 2.0
         , SvgA.cursor "pointer"
         ]
            ++ attrs
        )
        [ Svg.circle
            [ SvgA.cx <| String.fromFloat <| c
            , SvgA.cy <| String.fromFloat <| c
            , SvgA.r <| String.fromFloat <| r
            , SvgA.opacity "1.0"
            , SvgA.stroke "black"
            , SvgA.strokeWidth "0.5"
            , SvgA.fill "dodgerblue"
            ]
            []
        , Svg.line
            [ SvgA.x1 <| String.fromFloat <| c - r_
            , SvgA.y1 <| String.fromFloat <| c
            , SvgA.x2 <| String.fromFloat <| c + r_
            , SvgA.y2 <| String.fromFloat <| c
            , SvgA.opacity "1.0"
            , SvgA.stroke "white"
            , SvgA.strokeWidth "3"
            ]
            []
        , Svg.line
            [ SvgA.x1 <| String.fromFloat <| c
            , SvgA.y1 <| String.fromFloat <| c - r_
            , SvgA.x2 <| String.fromFloat <| c
            , SvgA.y2 <| String.fromFloat <| c + r_
            , SvgA.opacity "1.0"
            , SvgA.stroke "white"
            , SvgA.strokeWidth "3"
            ]
            []
        ]


removeButton : List (Html.Attribute Msg) -> Html.Html Msg
removeButton attrs =
    let
        m =
            2.5

        r =
            9.0

        r_ =
            5.0

        c =
            r + m
    in
    Svg.svg
        ([ SvgA.height <| String.fromFloat <| r * 2.0 + m * 2.0
         , SvgA.width <| String.fromFloat <| r * 2.0 + m * 2.0
         , SvgA.cursor "pointer"
         ]
            ++ attrs
        )
        [ Svg.circle
            [ SvgA.cx <| String.fromFloat <| c
            , SvgA.cy <| String.fromFloat <| c
            , SvgA.r <| String.fromFloat <| r
            , SvgA.opacity "1.0"
            , SvgA.stroke "black"
            , SvgA.strokeWidth "0.5"
            , SvgA.fill "palevioletred"
            ]
            []
        , Svg.line
            [ SvgA.x1 <| String.fromFloat <| c + r_ * cos (pi / 4.0)
            , SvgA.y1 <| String.fromFloat <| c + r_ * -(sin (pi / 4.0))
            , SvgA.x2 <| String.fromFloat <| c + r_ * -(cos (pi / 4.0))
            , SvgA.y2 <| String.fromFloat <| c + r_ * sin (pi / 4.0)
            , SvgA.opacity "1.0"
            , SvgA.stroke "black"
            , SvgA.strokeWidth "3"
            ]
            []
        , Svg.line
            [ SvgA.x1 <| String.fromFloat <| c + r_ * -(cos (pi / 4.0))
            , SvgA.y1 <| String.fromFloat <| c + r_ * -(sin (pi / 4.0))
            , SvgA.x2 <| String.fromFloat <| c + r_ * cos (pi / 4.0)
            , SvgA.y2 <| String.fromFloat <| c + r_ * sin (pi / 4.0)
            , SvgA.opacity "1.0"
            , SvgA.stroke "black"
            , SvgA.strokeWidth "3"
            ]
            []
        ]



-- SVG Event


onMove : (( Float, Float ) -> Msg) -> Svg.Attribute Msg
onMove msg =
    SvgE.on "mousemove" (positionDecoder msg)



-- Encoder


encodeKnob : Knob -> JsonE.Value
encodeKnob knob =
    JsonE.object
        [ ( "parameter", JsonE.string <| paramToString knob.boundTo )
        , ( "value", JsonE.float knob.value )
        ]


encodeSwitch : Switch -> JsonE.Value
encodeSwitch switch =
    JsonE.object
        [ ( "parameter", JsonE.string <| paramToString switch.boundTo )
        , ( "direction", JsonE.string <| directionToString switch.direction )
        ]


encodePatch : ( ( Parameter, Parameter ), String ) -> JsonE.Value
encodePatch ( ( in_, out ), color ) =
    JsonE.object
        [ ( "in", JsonE.string <| paramToString in_ )
        , ( "out", JsonE.string <| paramToString out )
        , ( "color", JsonE.string color )
        ]


encodeDevice : Device -> JsonE.Value
encodeDevice device =
    JsonE.object
        [ ( "knobs", JsonE.list encodeKnob device.knobs )
        , ( "switches", JsonE.list encodeSwitch device.switches )
        , ( "patches", JsonE.list encodePatch <| Al.toList device.patches )
        ]


encodeSetup : Model -> JsonE.Value
encodeSetup model =
    JsonE.object
        [ ( "device", encodeDevice model.device )
        , ( "notes", JsonE.list JsonE.string model.notes.notes )
        ]



-- Decoder


getBoundingClientRect : (BoundingClientRect -> Msg) -> JsonD.Decoder Msg
getBoundingClientRect msg =
    JsonD.at [ "target", "boundingClientRect" ] boundingClientRectDecoder
        |> JsonD.map msg


boundingClientRectDecoder : JsonD.Decoder BoundingClientRect
boundingClientRectDecoder =
    JsonD.map8 BoundingClientRect
        (JsonD.field "x" JsonD.float)
        (JsonD.field "y" JsonD.float)
        (JsonD.field "width" JsonD.float)
        (JsonD.field "height" JsonD.float)
        (JsonD.field "top" JsonD.float)
        (JsonD.field "right" JsonD.float)
        (JsonD.field "bottom" JsonD.float)
        (JsonD.field "left" JsonD.float)


positionDecoder : (( Float, Float ) -> Msg) -> JsonD.Decoder Msg
positionDecoder msg =
    JsonD.map2 Tuple.pair
        (JsonD.field "screenX" JsonD.float)
        (JsonD.field "screenY" JsonD.float)
        |> JsonD.map msg


setupsDecoder : JsonD.Decoder (List String)
setupsDecoder =
    JsonD.list JsonD.string


knobDecoder : JsonD.Decoder KnobSetup
knobDecoder =
    JsonD.map2 KnobSetup
        (JsonD.field "parameter" JsonD.string)
        (JsonD.field "value" JsonD.float)


switchDecoder : JsonD.Decoder SwitchSetup
switchDecoder =
    JsonD.map2 SwitchSetup
        (JsonD.field "parameter" JsonD.string)
        (JsonD.field "direction" JsonD.string)


patchDecoder : JsonD.Decoder PatchSetup
patchDecoder =
    JsonD.map3 PatchSetup
        (JsonD.field "in" JsonD.string)
        (JsonD.field "out" JsonD.string)
        (JsonD.field "color" JsonD.string)


deviceDecoder : JsonD.Decoder DeviceSetup
deviceDecoder =
    JsonD.map3 DeviceSetup
        (JsonD.field "knobs" <| JsonD.list knobDecoder)
        (JsonD.field "switches" <| JsonD.list switchDecoder)
        (JsonD.field "patches" <| JsonD.list patchDecoder)


setupDecoder : JsonD.Decoder Setup
setupDecoder =
    JsonD.map2 Setup
        (JsonD.field "device" deviceDecoder)
        (JsonD.field "notes" <| JsonD.list JsonD.string)



-- Utils


getSetups : JsonE.Value -> List String
getSetups value =
    case JsonD.decodeValue setupsDecoder value of
        Ok setups_ ->
            List.sort setups_

        Err _ ->
            []


mergeKnobs :
    List Knob
    -> List KnobSetup
    -> List Knob
mergeKnobs knobs setups =
    List.map2
        (\knob setup -> { knob | value = setup.value })
        knobs
        setups


mergeSwitches :
    List Switch
    -> List SwitchSetup
    -> List Switch
mergeSwitches switches setups =
    List.map2
        (\switch setup ->
            { switch
                | direction =
                    if setup.direction == "Up" then
                        Up

                    else
                        Down
            }
        )
        switches
        setups


processPatches :
    List PatchSetup
    -> Al.Dict ( Parameter, Parameter ) String
processPatches setups =
    let
        fromString s =
            case s of
                "ExtAudio" ->
                    Just ExtAudio

                "MixCv" ->
                    Just MixCv

                "VcaCv" ->
                    Just VcaCv

                "VcfCutoff" ->
                    Just VcfCutoff

                "VcfRes" ->
                    Just VcfRes

                "Vco1vOct" ->
                    Just Vco1vOct

                "VcoLinFm" ->
                    Just VcoLinFm

                "VcoMod" ->
                    Just VcoMod

                "LfoRateIn" ->
                    Just LfoRateIn

                "Mix1" ->
                    Just Mix1

                "Mix2" ->
                    Just Mix2

                "VcMixCtrl" ->
                    Just VcMixCtrl

                "Mult" ->
                    Just Mult

                "GateIn" ->
                    Just GateIn

                "Tempo" ->
                    Just Tempo

                "RunStop" ->
                    Just RunStop

                "Reset" ->
                    Just Reset

                "Hold" ->
                    Just Hold

                "Vca" ->
                    Just Vca

                "Noise" ->
                    Just Noise

                "Vcf" ->
                    Just Vcf

                "VcoSaw" ->
                    Just VcoSaw

                "VcoPulse" ->
                    Just VcoPulse

                "LfoTri" ->
                    Just LfoTri

                "LfoSq" ->
                    Just LfoSq

                "VcMixOut" ->
                    Just VcMixOut

                "Mult1" ->
                    Just Mult1

                "Mult2" ->
                    Just Mult2

                "Assign" ->
                    Just Assign

                "Eg" ->
                    Just Eg

                "Kb" ->
                    Just Kb

                "GateOut" ->
                    Just GateOut

                _ ->
                    Nothing
    in
    Al.fromList <|
        List.filterMap
            (\setup ->
                case ( fromString setup.in_, fromString setup.out ) of
                    ( Just in_, Just out ) ->
                        Just ( ( in_, out ), setup.color )

                    _ ->
                        Nothing
            )
            setups


loadModel : Model -> JsonE.Value -> Model
loadModel model value =
    case JsonD.decodeValue setupDecoder value of
        Ok setup ->
            let
                notes =
                    setup.notes

                knobs =
                    mergeKnobs model.device.knobs setup.device.knobs

                switches =
                    mergeSwitches model.device.switches setup.device.switches

                patches =
                    processPatches setup.device.patches

                dev =
                    model.device

                device =
                    { dev
                        | knobs = knobs
                        , switches = switches
                        , patches = patches
                    }

                notes_ =
                    model.notes
            in
            { model | notes = { notes_ | notes = notes }, device = device }

        Err e ->
            model


flip : (a -> b -> c) -> b -> a -> c
flip f x y =
    f y x


getKnob : Parameter -> List Knob -> Maybe Knob
getKnob param knobs =
    List.filter
        (\knob -> knob.boundTo == param)
        knobs
        |> List.head


findKnob : (Knob -> Bool) -> List Knob -> Maybe Knob
findKnob f knobs =
    List.filter f knobs
        |> List.head


updateKnob : List Knob -> Parameter -> (Knob -> Knob) -> List Knob
updateKnob knobs param f =
    List.map
        (\knob ->
            if knob.boundTo == param then
                f knob

            else
                knob
        )
        knobs


findJack : (Jack -> Bool) -> List Jack -> Maybe Jack
findJack f jacks =
    List.filter f jacks
        |> List.head


patchToJack :
    List Jack
    -> List Jack
    -> ( ( Parameter, Parameter ), String )
    -> Maybe ( Jack, Jack, String )
patchToJack inputs outputs ( ( input, output ), color ) =
    let
        jackIn =
            findJack (\jack -> jack.boundTo == input) inputs

        jackOut =
            findJack (\jack -> jack.boundTo == output) outputs
    in
    Maybe.map2 (\left right -> ( left, right, color )) jackIn jackOut


updateSwitch : List Switch -> Parameter -> (Switch -> Switch) -> List Switch
updateSwitch knobs param f =
    List.map
        (\knob ->
            if knob.boundTo == param then
                f knob

            else
                knob
        )
        knobs


rotate : Float -> Float -> Float
rotate rota angle =
    let
        angle_ =
            angle - rota
    in
    if angle_ < -pi || angle_ > pi then
        angle_ - (2 * pi)

    else
        angle_


toClockWise : Float -> Float
toClockWise angle =
    if angle < 0 then
        -angle

    else
        2 * pi - angle


angleToValue : Float -> Float
angleToValue angle =
    let
        x =
            (1 / 0.85) * angle / (2 * pi)
    in
    if x > 1.0 then
        if x < 1.09 then
            1.0

        else
            0.0

    else
        x


valueToAngle : Float -> Float
valueToAngle value =
    value * 0.85 * (2 * pi)


fromClockWise : Float -> Float
fromClockWise angle =
    if angle < pi then
        -angle

    else
        2 * pi - angle


posToValue : Knob -> ( Float, Float ) -> Maybe Float
posToValue knob ( mouseX, mouseY ) =
    let
        geoOpt =
            Maybe.map
                (\geo ->
                    ( geo.x + geo.width / 2.0
                    , geo.y + geo.height / 2.0
                    )
                )
                knob.geo

        posFromCenter =
            case geoOpt of
                Just ( knobCenterX, knobCenterY ) ->
                    Just ( mouseX - knobCenterX, -(mouseY - knobCenterY) )

                _ ->
                    Nothing

        angle =
            Maybe.map
                (\( x, y ) -> atan2 y x)
                posFromCenter
    in
    Maybe.map (rotate -2.03 >> toClockWise >> angleToValue) angle


paramToString : Parameter -> String
paramToString param =
    case param of
        Frequency ->
            "Frequency"

        PulseWidth ->
            "PulseWidth"

        Mix ->
            "Mix"

        Cutoff ->
            "Cutoff"

        Resonance ->
            "Resonance"

        Volume ->
            "Volume"

        Glide ->
            "Glide"

        VcoModAmount ->
            "VcoModAmount"

        VcfModAmount ->
            "VcfModAmount"

        TempoGate ->
            "TempoGate"

        LfoRate ->
            "LfoRate"

        Attack ->
            "Attack"

        Decay ->
            "Decay"

        VcMix ->
            "VcMix"

        VcoWave ->
            "VcoWave"

        VcaMode ->
            "VcaMode"

        VcoModSource ->
            "VcoModSource"

        VcoModDest ->
            "VcoModDest"

        VcfMode ->
            "VcfMode"

        VcfModSource ->
            "VcfModSource"

        VcfModPolarity ->
            "VcfModPolarity"

        LfoWave ->
            "LfoWave"

        Sustain ->
            "Sustain"

        Vca ->
            "Vca"

        Noise ->
            "Noise"

        Vcf ->
            "Vcf"

        VcoSaw ->
            "VcoSaw"

        VcoPulse ->
            "VcoPulse"

        LfoTri ->
            "LfoTri"

        LfoSq ->
            "LfoSq"

        VcMixOut ->
            "VcMixOut"

        Mult1 ->
            "Mult1"

        Mult2 ->
            "Mult2"

        Assign ->
            "Assign"

        Eg ->
            "Eg"

        Kb ->
            "Kb"

        GateOut ->
            "GateOut"

        ExtAudio ->
            "ExtAudio"

        MixCv ->
            "MixCv"

        VcaCv ->
            "VcaCv"

        VcfCutoff ->
            "VcfCutoff"

        VcfRes ->
            "VcfRes"

        Vco1vOct ->
            "Vco1vOct"

        VcoLinFm ->
            "VcoLinFm"

        VcoMod ->
            "VcoMod"

        LfoRateIn ->
            "LfoRateIn"

        Mix1 ->
            "Mix1"

        Mix2 ->
            "Mix2"

        VcMixCtrl ->
            "VcMixCtrl"

        Mult ->
            "Mult"

        GateIn ->
            "GateIn"

        Tempo ->
            "Tempo"

        RunStop ->
            "RunStop"

        Reset ->
            "Reset"

        Hold ->
            "Hold"


directionToString : Direction -> String
directionToString dir =
    case dir of
        Up ->
            "Up"

        Down ->
            "Down"
