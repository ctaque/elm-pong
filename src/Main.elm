module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Keyboard exposing (RawKey)
import Time



-- MAIN


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- MODEL


pxByMove : Int
pxByMove =
    3


barMoveIncrement : Int
barMoveIncrement =
    40


barYOffset : Int
barYOffset =
    10


barHeight : Int
barHeight =
    20


circleRadius : Int
circleRadius =
    50


type alias WindowSize =
    { width : Int
    , height : Int
    }


type alias SetYPositionReturnType =
    { y : Int
    , direction : Int
    , gameLost : Bool
    }


type alias Coordinates =
    ( Int, Int )


type alias Model =
    { coordinates : Coordinates
    , xDirection : Int
    , yDirection : Int
    , windowSize : WindowSize
    , barWidth : Int
    , barXOffset : Int
    , gameLost : Bool
    }


type alias Flags =
    { windowHeight : Int
    , windowWidth : Int
    }


getBarWidth : Flags -> Int
getBarWidth flags =
    Basics.floor (Basics.min (Basics.toFloat flags.windowWidth / 2) 300)


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { coordinates = ( Basics.floor (toFloat flags.windowWidth / 2), Basics.floor (toFloat flags.windowHeight / 2) )
      , xDirection = 1
      , yDirection = -1
      , barXOffset = Basics.floor ((toFloat flags.windowWidth / 2) - (Basics.toFloat (getBarWidth flags) / 2))
      , gameLost = False
      , barWidth = getBarWidth flags
      , windowSize =
            { width = flags.windowWidth
            , height = flags.windowHeight
            }
      }
    , Cmd.none
    )



-- UPDATE


setXPosition : Int -> WindowSize -> Int -> ( Int, Int )
setXPosition x windowSize direction =
    if x < circleRadius then
        ( x + pxByMove, 1 )

    else if x >= windowSize.width - circleRadius then
        ( x - pxByMove, -1 )

    else if direction == 1 then
        ( x + pxByMove, 1 )

    else
        ( x - pxByMove, -1 )


setYPosition : Coordinates -> Int -> Int -> WindowSize -> Int -> SetYPositionReturnType
setYPosition coordinates barXOffset barWidth windowSize direction =
    if Tuple.second coordinates <= circleRadius then
        { y = Tuple.second coordinates + pxByMove, direction = 1, gameLost = False }

    else if Tuple.second coordinates >= windowSize.height - circleRadius then
        { y = Tuple.second coordinates - pxByMove, direction = -1, gameLost = True }

    else if direction == 1 && Tuple.second coordinates >= (windowSize.height - barHeight - barYOffset - circleRadius) then
        if Tuple.first coordinates >= barXOffset && Tuple.first coordinates <= barXOffset + barWidth then
            { y = Tuple.second coordinates - pxByMove, direction = -1, gameLost = False }

        else
            { y = Tuple.second coordinates + pxByMove, direction = 1, gameLost = False }

    else if direction == 1 then
        { y = Tuple.second coordinates + pxByMove, direction = 1, gameLost = False }

    else
        { y = Tuple.second coordinates - pxByMove, direction = -1, gameLost = False }


barOffsetFromLeft : Int -> Int
barOffsetFromLeft currentPosition =
    Basics.max currentPosition 0


barOffsetFromRight : Int -> WindowSize -> Int -> Int
barOffsetFromRight nextPosition windowSize barWidth =
    Basics.min nextPosition (windowSize.width - barWidth)

type Msg
    = Move Time.Posix
    | KeyDown RawKey
    | Restart

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        x =
            setXPosition (Tuple.first model.coordinates) model.windowSize model.xDirection

        yResult =
            setYPosition model.coordinates model.barXOffset model.barWidth model.windowSize model.yDirection
    in
    case msg of
        Restart ->
            ({model 
                | gameLost = False
                , yDirection = -1
                , coordinates = (Basics.floor (Basics.toFloat model.windowSize.width / 2) , Basics.floor (Basics.toFloat model.windowSize.height / 2))
                }
                , Cmd.none)
        Move _ ->
            ( { model
                | coordinates = ( Tuple.first x, yResult.y )
                , xDirection = Tuple.second x
                , yDirection = yResult.direction
                , gameLost = yResult.gameLost
              }
            , Cmd.none
            )

        KeyDown key ->
            let
                keyParsed =
                    Keyboard.rawValue key
            in
            case keyParsed of
                "ArrowRight" ->
                    ( { model
                        | barXOffset = barOffsetFromLeft (barOffsetFromRight (model.barXOffset + barMoveIncrement) model.windowSize model.barWidth)
                      }
                    , Cmd.none
                    )

                "ArrowLeft" ->
                    ( { model
                        | barXOffset = barOffsetFromLeft (barOffsetFromRight (model.barXOffset - barMoveIncrement) model.windowSize model.barWidth)
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.gameLost then
        Sub.batch [ Keyboard.downs KeyDown ]

    else
        Sub.batch
            [ Time.every 1 Move
            , Keyboard.downs KeyDown
            ]



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style "position" "relative"
        , style "width" "100vw"
        , style "height" "100vh"
        , style "background-color" "rgb(40, 40, 40)"
        ]
        [ if model.gameLost == True then
            div
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "position" "absolute"
                , style "transform" "translate(-50%, -50%)"
                , style "top" "50%"
                , style "left" "50%"
                ]
                [ h1 [][ text "Perdu !" ]
                , button
                    [onClick Restart][ text "Rejouer" ]
                ]

          else
            div
                []
                [ div
                    [ style "position" "absolute"
                    , style "bottom" (String.fromInt barYOffset ++ "px")
                    , style "transform" ("translateX(" ++ (String.fromInt model.barXOffset ++ "px)"))
                    , style "background-color" "rgb(250, 240, 198)"
                    , style "height" (String.fromInt barHeight ++ "px")
                    , style "width" (String.fromInt model.barWidth ++ "px")
                    ]
                    []
                , div
                    [ style "position" "absolute"
                    , style "transform" ("translateY(" ++ String.fromInt (Tuple.second model.coordinates - circleRadius) ++ "px) translateX(" ++ String.fromInt (Tuple.first model.coordinates - circleRadius) ++ "px)")
                    , style "transform-origin" "center"
                    , style "background-color" "rgb(251, 73, 52)"
                    , style "border-radius" "100%"
                    , style "width" (String.fromInt (circleRadius * 2) ++ "px")
                    , style "height" (String.fromInt (circleRadius * 2) ++ "px")
                    ]
                    []
                ]
        ]
