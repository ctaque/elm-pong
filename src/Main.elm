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
barMoveIncrement: Int
barMoveIncrement = 40

playerBarHeight : Int
playerBarHeight =
    150


type alias WindowSize =
    { width : Int
    , height : Int
    }


type alias Model =
    { x : Int
    , y : Int
    , xDirection : Int
    , yDirection : Int
    , windowSize : WindowSize
    , playerLeftBarY : Int
    , playerRightBarY : Int
    }


type alias Flags =
    { windowHeight : Int
    , windowWidth : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { x = Basics.floor (toFloat flags.windowWidth / 2)
      , y = Basics.floor (toFloat flags.windowHeight / 2)
      , xDirection = 1
      , yDirection = 1
      , playerLeftBarY = Basics.floor ((toFloat flags.windowHeight / 2) - (toFloat playerBarHeight / 2))
      , playerRightBarY = Basics.floor ((toFloat flags.windowHeight / 2) - (toFloat playerBarHeight / 2))
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


setYPosition : Int -> WindowSize -> Int -> ( Int, Int )
setYPosition y windowSize direction =
    if y <= 0 then
        ( pxByMove, 1 )

    else if y >= windowSize.height then
        ( windowSize.height - pxByMove, -1 )

    else if direction == 1 then
        ( y + pxByMove, 1 )

    else
        ( y - pxByMove, -1 )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        x =
            setXPosition model.x model.windowSize model.xDirection

        y =
            setYPosition model.y model.windowSize model.yDirection
    in
    case msg of
        Move _ ->
            ( { model
                | x = Tuple.first x
                , y = Tuple.first y
                , xDirection = Tuple.second x
                , yDirection = Tuple.second y
              }
            , Cmd.none
            )

        KeyDown key ->
            let
                keyParsed =
                    Keyboard.rawValue key
            in
            case keyParsed of
                "s" ->
                    ({ model
                        | playerLeftBarY = model.playerLeftBarY + barMoveIncrement
                    }
                    , Cmd.none)

                "z" ->
                    ({ model
                        | playerLeftBarY = model.playerLeftBarY - barMoveIncrement
                    }
                    , Cmd.none)
                "ArrowDown" ->
                    ({ model
                        | playerRightBarY = model.playerRightBarY + barMoveIncrement
                    }
                    , Cmd.none)

                "ArrowUp" ->
                    ({ model
                        | playerRightBarY = model.playerRightBarY - barMoveIncrement
                    }
                    , Cmd.none)
                _ ->
                    (model, Cmd.none)



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
        ]
        [ div
            [ style "position" "absolute"
            , style "top" (String.fromInt model.playerLeftBarY ++ "px")
            , style "left" "10px"
            , style "background-color" "black"
            , style "width" "20px"
            , style "height" (String.fromInt playerBarHeight ++ "px")
            ]
            []
        , div
            [ style "position" "absolute"
            , style "top" (String.fromInt (.y model) ++ "px")
            , style "left" (String.fromInt (.x model) ++ "px")
            , style "background-color" "blue"
            , style "border-radius" "100%"
            , style "width" "50px"
            , style "height" "50px"
            ]
            []
        , div
            [ style "position" "absolute"
            , style "top" (String.fromInt model.playerRightBarY ++ "px")
            , style "right" "10px"
            , style "background-color" "black"
            , style "width" "20px"
            , style "height" (String.fromInt playerBarHeight ++ "px")
            ]
            []
        ]
