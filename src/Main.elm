module Main exposing (..)

import Browser
import Html
import Html.Attributes as HtmlA
import Html.Events as HtmlE
import Json.Decode exposing (Decoder)
import Svg
import Svg.Attributes as SvgA
import Svg.Events as SvgE


main : Program () Model Msg
main =
    Browser.element
        { init =
            \_ ->
                ( mother32, Cmd.none )
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


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
        , { value = 0.505
          , position = ( 331, 57.4 )
          , boundTo = Mix
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
          , position = ( 431.5, 57.4 )
          , boundTo = Cutoff
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
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
        , { value = 0.505
          , position = ( 80.8, 140.2 )
          , boundTo = Glide
          , geo = Nothing
          , isMoving = False
          }
        , { value = 0.505
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
        , { value = 0.505
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
        , { value = 0.505
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
    }



-- Model


type alias Model =
    Device


type alias Position =
    ( Float, Float )


type alias Knob =
    { value : Float
    , position : Position
    , boundTo : Parameter
    , geo : Maybe BoundingClientRect
    , isMoving : Bool
    }


type alias Switch =
    { direction : Direction
    , position : Position
    , boundTo : Parameter
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


type alias Device =
    { knobs : List Knob
    , switches: List Switch
    }


type Direction
    = Up
    | Down


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


-- Update


type Msg
    = UserMoveKnob Parameter
    | UserSetSwitch Parameter
    | UserStopMovingKnob Parameter
    | UserChangePosition Parameter Position
    | GotRect BoundingClientRect


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserMoveKnob param ->
            let
                knobs =
                    updateKnob
                        model.knobs
                        param
                        (\knob -> { knob | isMoving = True })
            in
            ( { model | knobs = knobs }, Cmd.none )
                
        UserSetSwitch param ->
            let
                switches =
                    updateSwitch
                        model.switches
                        param
                        (\switch ->
                             case switch.direction of
                                 Up ->
                                     { switch | direction = Down }
                                 Down ->
                                     { switch | direction = Up }
                        )
            in
            ( { model | switches = switches }, Cmd.none )

        UserChangePosition param pos ->
            case getKnob param model.knobs of
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
                            updateKnob model.knobs knob.boundTo f
                    in
                    ( { model | knobs = knobs }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserStopMovingKnob param ->
            let
                knobs =
                    updateKnob
                        model.knobs
                        param
                        (\knob -> { knob | isMoving = False })
            in
            ( { model | knobs = knobs }, Cmd.none )

        GotRect rect ->
            case findKnob (\knob -> knob.isMoving) model.knobs of
                Just knob ->
                    let
                        knobs =
                            updateKnob
                                model.knobs
                                knob.boundTo
                                (\knob_ -> { knob_ | geo = Just rect })
                    in
                    ( { model | knobs = knobs }, Cmd.none )

                _ ->
                    ( model, Cmd.none )



-- View


view : Model -> Html.Html Msg
view model =
    let
        devicePicture =
            Svg.image
                [ SvgA.xlinkHref "Mother-32.png"
                , SvgA.width "900"
                ]
                []

        knobsSvg =
            List.map knobView model.knobs

        switchesSvg =
            List.map switchView model.switches
    in
    Html.div []
        [ Html.h1 [ HtmlA.id "header"] [ Html.text "Mother 32 Patch Memory" ]
        , Svg.svg
            [ SvgA.viewBox "0 0 900 380"
            , SvgE.on "mousedown" getBoundingClientRect
            ]
            ( devicePicture
            :: ( Svg.rect
                     [ SvgA.width "900"
                     , SvgA.height "380"
                     , SvgA.fill "#86A"
                     , SvgA.opacity "0.1"
                     , SvgA.x "0"
                     , SvgA.y "0"
                     ] []
               :: (knobsSvg ++ switchesSvg)
               )
            )
        , Html.p [] [ debugView model ]
        ]


debugView : Model -> Html.Html Msg
debugView model =
    Html.div
        [ HtmlA.style "background-color" "#FFEEEE"
        , HtmlA.style "padding" "0.5em"
        ]
    <|
        case findKnob (\knob -> knob.isMoving) model.knobs of
            Just knob ->
                let
                    ( cx, cy ) =
                        knob.position

                    knobAngle =
                        (valueToAngle >> fromClockWise >> rotate 2.03) knob.value

                    ( x1, y1 ) =
                        fromPolar ( 36.0, knobAngle )

                    ( x2, y2 ) =
                        fromPolar ( 16.0, knobAngle )
                in
                [ Html.p []
                    [ Html.text <|
                        Debug.toString knob.boundTo
                            ++ ": "
                            ++ String.fromFloat knob.value
                    ]
                , Html.p []
                    [ Html.text <|
                        Debug.toString
                            ( (toFloat <| round (x1 * 10000.0)) / 10000.0
                            , (toFloat <| round (y1 * 10000.0)) / 10000.0
                            )
                            ++ ": "
                            ++ Debug.toString
                                ( (toFloat <| round (x2 * 10000.0)) / 10000.0
                                , (toFloat <| round (y2 * 10000.0)) / 10000.0
                                )
                    ]
                ]

            _ ->
                [ Html.text "Knob not mooving" ]



switchView : Switch -> Svg.Svg Msg
switchView switch =
    let (cx, cy) = switch.position
        offset =
            case switch.direction of
                Up -> -5
                Down -> 5
                     
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
                , SvgE.onMouseDown <| UserMoveKnob knob.boundTo
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
                            , SvgE.onMouseUp (UserStopMovingKnob knob.boundTo)
                            , SvgE.onMouseOut (UserStopMovingKnob knob.boundTo)
                            , onMove (UserChangePosition knob.boundTo)
                            ]
                            []
                       ]

            else
                base
    in
    Svg.g [] children



-- SVG Event


onMove : (Position -> Msg) -> Svg.Attribute Msg
onMove msg =
    SvgE.on "mousemove" (positionDecoder msg)



-- Decoder


getBoundingClientRect : Decoder Msg
getBoundingClientRect =
    Json.Decode.at [ "target", "boundingClientRect" ] boundingClientRectDecoder
        |> Json.Decode.map GotRect


boundingClientRectDecoder : Decoder BoundingClientRect
boundingClientRectDecoder =
    Json.Decode.map8 BoundingClientRect
        (Json.Decode.field "x" Json.Decode.float)
        (Json.Decode.field "y" Json.Decode.float)
        (Json.Decode.field "width" Json.Decode.float)
        (Json.Decode.field "height" Json.Decode.float)
        (Json.Decode.field "top" Json.Decode.float)
        (Json.Decode.field "right" Json.Decode.float)
        (Json.Decode.field "bottom" Json.Decode.float)
        (Json.Decode.field "left" Json.Decode.float)


positionDecoder : (Position -> Msg) -> Json.Decode.Decoder Msg
positionDecoder msg =
    Json.Decode.map2 Tuple.pair
        (Json.Decode.field "screenX" Json.Decode.float)
        (Json.Decode.field "screenY" Json.Decode.float)
        |> Json.Decode.map msg



-- Utils


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


posToValue : Knob -> Position -> Maybe Float
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
