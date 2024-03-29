module Main exposing (..)

import Browser
import Html
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
                ( { state = DoesNothing
                  , device = mother32
                  }
                , Cmd.none
                )
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


mother32 : Device
mother32 =
    { knobs =
        [ { value = 0
          , position = ( 81, 58 )
          , boundTo = Frequency
          , geo = Nothing
          }
        ]
    }



-- Model


type alias Model =
    { state : AppState
    , device : Device
    }


type AppState
    = Moving Parameter
    | DoesNothing


type alias Position =
    ( Float, Float )


type alias Knob =
    { value : Float
    , position : Position
    , boundTo : Parameter
    , geo : Maybe BoundingClientRect
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
    { knobs : List Knob }


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



-- Update


type Msg
    = UserMoveKnob Parameter
    | UserStopMoving
    | UserChangePosition Position
    | GotRect BoundingClientRect


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserMoveKnob knob ->
            ( { model | state = Moving knob }, Cmd.none )

        UserChangePosition pos ->
            case model.state of
                Moving param ->
                    let
                        knobs =
                            updateKnob
                                model.device.knobs
                                param
                                (\knob ->
                                    case posToValue knob pos of
                                        Just value ->
                                            { knob | value = value }

                                        _ ->
                                            knob
                                )

                        device =
                            model.device
                    in
                    ( { model | device = { device | knobs = knobs } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserStopMoving ->
            ( { model | state = DoesNothing }, Cmd.none )

        GotRect rect ->
            case model.state of
                Moving param ->
                    let
                        knobs =
                            updateKnob
                                model.device.knobs
                                param
                                (\knob -> { knob | geo = Just rect })

                        device =
                            model.device
                    in
                    ( { model | device = { device | knobs = knobs } }
                    , Cmd.none
                    )

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
            List.map (knobView model) model.device.knobs
    in
    Html.div []
        [ Html.h1 [] [ Html.text "Mother 32 Patch Memory" ]
        , Svg.svg
            [ SvgA.viewBox "0 0 900 380"
            , SvgE.on "mousedown" getBoundingClientRect
            ]
            (devicePicture :: knobsSvg)
        , Html.p [] [ debugMouseView model ]
        ]


debugMouseView : Model -> Html.Html Msg
debugMouseView model =
    case model.state of
        Moving param ->
            let
                knobValueHtml =
                    case getKnob model param of
                        Just knob ->
                            Html.text <| String.fromFloat knob.value

                        _ ->
                            Html.text "no value"
            in
            Html.div [] [ Html.text <| Debug.toString param ++ ": ", knobValueHtml ]

        DoesNothing ->
            Html.text "Knob not mooving"


knobView : Model -> Knob -> Svg.Svg Msg
knobView model knob =
    let
        ( cx, cy ) =
            knob.position

        isMoving =
            case model.state of
                Moving value ->
                    value == knob.boundTo

                _ ->
                    False

        base =
            [ Svg.defs []
                [ Svg.filter [ SvgA.id "blur" ]
                    [ Svg.feGaussianBlur
                        [ SvgA.stdDeviation "3" ]
                        []
                    ]
                ]
            , Svg.line
                [ SvgA.x1 <| String.fromFloat cx
                , SvgA.y1 <| String.fromFloat <| cy - 16.0
                , SvgA.x2 <| String.fromFloat <| cx
                , SvgA.y2 <| String.fromFloat <| cy - 36.0
                , SvgA.stroke "red"
                , SvgA.strokeWidth "3"
                ]
                []
            , Svg.circle
                [ SvgA.cx <| String.fromFloat cx
                , SvgA.cy <| String.fromFloat cy
                , SvgA.r "35"
                , SvgA.opacity "0.0"
                , SvgE.onMouseDown <| UserMoveKnob knob.boundTo
                ]
                []
            ]

        children =
            if isMoving then
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
                            , SvgE.onMouseUp UserStopMoving
                            , SvgE.onMouseOut UserStopMoving
                            , onMove UserChangePosition
                            ]
                            []
                       ]

            else
                base
    in
    Svg.g [] children



-- SVG Event


onMove : msg -> Svg.Attribute Msg
onMove message =
    SvgE.on "mousemove" positionDecoder



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


positionDecoder : Json.Decode.Decoder Msg
positionDecoder =
    Json.Decode.map2 Tuple.pair
        (Json.Decode.field "screenX" Json.Decode.float)
        (Json.Decode.field "screenY" Json.Decode.float)
        |> Json.Decode.map UserChangePosition



-- Utils


getKnob : Model -> Parameter -> Maybe Knob
getKnob model param =
    List.filter
        (\knob -> knob.boundTo == param)
        model.device.knobs
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


frameRotation : Float -> Float -> Float
frameRotation rota angle =
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
        abs angle

    else
        2 * pi - angle


angleToValue : Float -> Float
angleToValue angle =
    let
        x =
            1.18 * angle / (2 * pi)
    in
    if x > 1.0 then
        if x < 1.09 then
            1.0

        else
            0.0

    else
        x


posToValue : Knob -> Position -> Maybe Float
posToValue knob pos =
    let
        geoOpt =
            Maybe.map
                (\schemaGeo ->
                    ( schemaGeo.x + schemaGeo.width / 2.0
                    , schemaGeo.y + schemaGeo.height / 2.0
                    )
                )
                knob.geo

        posFromCenter =
            case ( geoOpt, pos ) of
                ( Just ( knobCenterX, knobCenterY ), ( mouseX, mouseY ) ) ->
                    Just ( mouseX - knobCenterX, -(mouseY - knobCenterY) )

                _ ->
                    Nothing

        angle =
            Maybe.map
                (\( x, y ) -> atan2 y x)
                posFromCenter
    in
    Maybe.map (frameRotation -2.03 >> toClockWise >> angleToValue) angle
