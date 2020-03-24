module Main exposing (main)

import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (style)
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


type alias WindowSize =
    { width : Int
    , height : Int
    }

type alias SetYPositionReturnType =
    { y : Int
    , direction : Int
    , gameLost : Bool
    }

type alias Model =
    { coordinates : (Int, Int)
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
    ( { coordinates = (Basics.floor (toFloat flags.windowWidth / 2), Basics.floor (toFloat flags.windowHeight / 2))
      , xDirection = 1
      , yDirection = 1
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


type Msg
    = Move Time.Posix
    | KeyDown RawKey


setXPosition : Int -> WindowSize -> Int -> ( Int, Int )
setXPosition x windowSize direction =
    if x <= 0 then
        ( pxByMove, 1 )

    else if x >= windowSize.width then
        ( windowSize.width - pxByMove, -1 )

    else if direction == 1 then
        ( x + pxByMove, 1 )

    else
        ( x - pxByMove, -1 )


setYPosition : Int -> WindowSize -> Int -> SetYPositionReturnType
setYPosition y windowSize direction =
    if y <= 0 then
        { y = pxByMove, direction = 1, gameLost = False}

    else if y >= windowSize.height then
        { y = windowSize.height - pxByMove, direction = -1, gameLost = True}

    else if direction == 1 then
        {  y = y + pxByMove, direction =  1, gameLost = False}

    else
        { y = y - pxByMove, direction = -1, gameLost = False }


barOffsetFromLeft : Int -> Int
barOffsetFromLeft currentPosition =
    Basics.max currentPosition 0


barOffsetFromRight : Int -> WindowSize -> Int -> Int
barOffsetFromRight nextPosition windowSize barWidth =
    Basics.min nextPosition (windowSize.width - barWidth)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        x =
            setXPosition (Tuple.first model.coordinates) model.windowSize model.xDirection

        yResult =
            setYPosition (Tuple.second model.coordinates) model.windowSize model.yDirection
    in
    case msg of
        Move _ ->
            ( { model
            | coordinates = (Tuple.first x, yResult.y)
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
subscriptions _ =
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
        ]
        [ div
            [ style "position" "absolute"
            , style "bottom" (String.fromInt barYOffset ++ "px")
            , style "transform" ("translateX(" ++ (String.fromInt model.barXOffset ++ "px)"))
            , style "background-color" "black"
            , style "height" (String.fromInt barHeight ++ "px")
            , style "width" (String.fromInt model.barWidth ++ "px")
            ]
            []
        , div
            [ style "position" "absolute"
            , style "top" (String.fromInt (Tuple.second model.coordinates) ++ "px")
            , style "left" (String.fromInt (Tuple.first model.coordinates) ++ "px")
            , style "background-color" "blue"
            , style "border-radius" "100%"
            , style "width" "50px"
            , style "height" "50px"
            ]
            []
        ]
