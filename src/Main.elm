module Main exposing (main)

import Browser
import Browser.Events as E
import Constants exposing (barHeight, barYOffset, circleRadius)
import Functions exposing (barOffsetFromLeft, barOffsetFromRight, getBarMoveIncrement, getBarMoveIncrementMobile, getBarWidth, getInitialBarXOffset, getXPosition, getYPosition, init)
import Html exposing (Html, a, button, div, h1, span, text)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick, onMouseUp)
import Keyboard exposing (rawValue)
import Time
import Types exposing (Direction(..), Model, Msg(..))


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotWindowDimensions width height ->
            let
                windowSize =
                    { height = height
                    , width = width
                    }
            in
            ( { model | windowSize = windowSize }, Cmd.none )

        Restart ->
            ( { model
                | gameLost = False
                , level = 1
                , direction = None
                , barXOffset = getInitialBarXOffset model.windowSize
                , yDirection = -1
                , coordinates = ( Basics.floor (Basics.toFloat model.windowSize.width / 2), Basics.floor (Basics.toFloat model.windowSize.height / 2) )
              }
            , Cmd.none
            )

        Start ->
            ( { model
                | gameStarted = True
              }
            , Cmd.none
            )

        Move _ ->
            let
                xPosition =
                    getXPosition (Tuple.first model.coordinates) model.windowSize model.xDirection model.level

                yPosition =
                    getYPosition model.coordinates model.barXOffset model.barWidth model.windowSize model.yDirection model.level

                nextDirection =
                    case yPosition.gameLost of
                        True ->
                            None

                        False ->
                            model.direction

                _ =
                    Debug.log "nextDirection" nextDirection
            in
            ( { model
                | coordinates = ( Tuple.first xPosition, yPosition.y )
                , xDirection = Tuple.second xPosition
                , yDirection = yPosition.direction
                , gameLost = yPosition.gameLost
                , direction = nextDirection
              }
            , Cmd.none
            )

        LevelUp _ ->
            ( { model
                | level = model.level + 1
              }
            , Cmd.none
            )

        MoveBar _ ->
            case model.direction of
                Right ->
                    ( { model
                        | barXOffset = barOffsetFromLeft (barOffsetFromRight (model.barXOffset + getBarMoveIncrement model.level) model.windowSize model.barWidth)
                      }
                    , Cmd.none
                    )

                Left ->
                    ( { model
                        | barXOffset = barOffsetFromLeft (barOffsetFromRight (model.barXOffset - getBarMoveIncrement model.level) model.windowSize model.barWidth)
                      }
                    , Cmd.none
                    )

                None ->
                    ( model, Cmd.none )

        KeyDown key ->
            let
                keyParsed =
                    rawValue key
            in
            case keyParsed of
                "ArrowRight" ->
                    case model.direction of
                        Left ->
                            ( { model | direction = None }, Cmd.none )

                        _ ->
                            ( { model | direction = Right }, Cmd.none )

                "ArrowLeft" ->
                    case model.direction of
                        Right ->
                            ( { model | direction = None }, Cmd.none )

                        _ ->
                            ( { model | direction = Left }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        KeyUp key ->
            let
                keyParsed =
                    rawValue key
            in
            case keyParsed of
                "ArrowRight" ->
                    ( { model | direction = None }, Cmd.none )

                "ArrowLeft" ->
                    ( { model | direction = None }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GoLeft ->
            ( { model
                | barXOffset = barOffsetFromLeft (barOffsetFromRight (model.barXOffset - getBarMoveIncrementMobile model.level) model.windowSize model.barWidth)
              }
            , Cmd.none
            )

        GoRight ->
            ( { model
                | barXOffset = barOffsetFromLeft (barOffsetFromRight (model.barXOffset + getBarMoveIncrementMobile model.level) model.windowSize model.barWidth)
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div
        [ class "game-board" ]
        [ if model.gameStarted == False then
            div
                [ class "centered-wrapper" ]
                [ h1 [] [ text "The Pong game" ]
                , div [ class "controls-wrapper" ]
                    [ div [ class "control" ] [ span [ class "arrow" ] [ text "←" ], text "Left arrow" ]
                    , div [ class "control" ] [ text " | " ]
                    , div [ class "control" ] [ text "Right arrow", span [ class "arrow" ] [ text "→" ] ]
                    ]
                , button
                    [ class "play-btn", onClick Start ]
                    [ text "Play" ]
                ]

          else if model.gameLost == True then
            div
                [ class "centered-wrapper" ]
                [ div [ class "play-again-wrapper" ]
                    [ h1 [] [ text "Game over" ]
                    , div [ class "footer" ]
                        [ span [ class "level" ]
                            [ text ("Your level : " ++ String.fromInt model.level) ]
                        , button
                            [ onClick Restart ]
                            [ text "Play again" ]
                        ]
                    , span [ class "credit" ] [ a [ href "https://github.com/ctaque/elm-pong", target "_blank" ] [ text "A game by Cyprien Taque" ] ]
                    ]
                ]

          else
            div
                [ class "game-board--inner-wrapper" ]
                [ span
                    [ class "level" ]
                    [ text ("Level " ++ String.fromInt model.level) ]
                , div
                    [ class "bar"
                    , style "bottom" (String.fromInt barYOffset ++ "px")
                    , style "transform" ("translateX(" ++ (String.fromInt model.barXOffset ++ "px)"))
                    , style "height" (String.fromInt barHeight ++ "px")
                    , style "width" (String.fromInt model.barWidth ++ "px")
                    ]
                    []
                , div
                    [ class "ball"
                    , style "transform" ("translateY(" ++ String.fromInt (Tuple.second model.coordinates - circleRadius) ++ "px) translateX(" ++ String.fromInt (Tuple.first model.coordinates - circleRadius) ++ "px)")
                    , style "width" (String.fromInt (circleRadius * 2) ++ "px")
                    , style "height" (String.fromInt (circleRadius * 2) ++ "px")
                    ]
                    []
                ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.gameLost || model.gameStarted == False then
        Sub.batch [ Keyboard.downs KeyDown ]

    else
        Sub.batch
            [ Time.every 1 Move
            , Time.every 1 MoveBar
            , Time.every 10000 LevelUp
            , Keyboard.downs KeyDown
            , Keyboard.ups KeyUp
            , E.onResize (\w h -> GotWindowDimensions w h)
            ]
