port module Elm.Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Events as E
import Elm.Constants exposing (barHeight, barYOffset, circleRadius, colors)
import Elm.Functions exposing (barOffsetFromLeft, barOffsetFromRight, getBarMoveIncrement, getBarMoveIncrementMobile, getBarWidth, getColorIndex, getInitialBarXOffset, getTopScores, getXPosition, getYPosition, init, sendScore)
import Elm.Types exposing (Direction(..), Model, Msg(..), Score)
import Html exposing (Html, a, button, div, h1, h2, input, span, text)
import Html.Attributes exposing (attribute, class, href, style, target)
import Html.Events exposing (onClick, onInput, onMouseUp)
import Json.Decode exposing (Decoder, float, int, nullable, string)
import Keyboard exposing (rawValue)
import RemoteData
import Table exposing (defaultCustomizations)
import Time


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotJwt jwt ->
            ( { model | jwtToken = jwt }, Cmd.none )

        FilterUsername username ->
            ( { model | filterScoreUsername = username }
            , getTopScores model.jwtToken model.apiUrl username
            )

        SetTableState newState ->
            ( { model | tableState = newState }
            , Cmd.none
            )

        GotTopScores scores ->
            ( { model | topScores = scores }, Cmd.none )

        GotScore scoreList ->
            case scoreList of
                RemoteData.Success list ->
                    let
                        array =
                            Array.fromList list

                        mbScore =
                            Array.get 0 array
                    in
                    ( { model | savedScore = mbScore }, getTopScores model.jwtToken model.apiUrl "*" )

                _ ->
                    ( model, Cmd.none )

        SetScore _ ->
            ( { model | score = model.score + 1 }, Cmd.none )

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
                , score = 100
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
            in
            ( { model
                | coordinates = ( Tuple.first xPosition, yPosition.y )
                , xDirection = Tuple.second xPosition
                , yDirection = yPosition.direction
                , gameLost = yPosition.gameLost
                , direction = nextDirection
              }
            , case yPosition.gameLost of
                True ->
                    sendScore model.jwtToken model.apiUrl model.pseudo model.level model.score

                False ->
                    Cmd.none
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

        HandlePseudoChange pseudo ->
            let
                pseudoErrors =
                    if String.length pseudo <= 1 then
                        Maybe.Just "Min 2 chars"

                    else if String.length pseudo >= 50 then
                        Maybe.Just "Max 50 chars"

                    else
                        Maybe.Nothing
            in
            ( { model | pseudo = pseudo, pseudoErrors = pseudoErrors }, Cmd.none )


config : Model -> Table.Config Score Msg
config model =
    Table.customConfig
        { toId = String.fromInt << .id
        , toMsg = SetTableState
        , columns =
            [ Table.stringColumn "Username" .pseudo
            , Table.intColumn "Level" .level
            , Table.intColumn "Score" .score
            ]
        , customizations =
            { defaultCustomizations | tableAttrs = toTableAttrs, rowAttrs = toRowAttrs model }
        }


toTableAttrs : List (Html.Attribute Msg)
toTableAttrs =
    [ attribute "class" "scores-list"
    ]


toRowAttrs : Model -> Score -> List (Html.Attribute Msg)
toRowAttrs model currentScore =
    [ case model.savedScore of
        Just myScore ->
            if myScore.id == currentScore.id then
                attribute "class" "highlight"

            else
                attribute "class" ""

        Nothing ->
            attribute "class" ""
    ]


view : Model -> Html Msg
view model =
    let
        color =
            Array.get (getColorIndex model.level) colors
    in
    div
        [ class "game-board"
        , case model.gameLost of
            False ->
                case color of
                    Just value ->
                        style "background-color" ("rgb(" ++ value ++ ")")

                    Nothing ->
                        style "background-color" "transparent"

            True ->
                style "background-color" "rgb(40, 40, 40)"
        ]
        [ if model.gameStarted == False then
            div
                [ class "centered-wrapper" ]
                [ h1 [] [ text "The Pong game" ]
                , div [ class "form" ]
                    [ div [ class "form-item" ]
                        [ input [ onInput HandlePseudoChange, attribute "placeholder" "Pick a username" ] [ text model.pseudo ]
                        , case model.pseudoErrors of
                            Nothing ->
                                span [] []

                            Just error ->
                                span [ class "error-tip" ] [ text error ]
                        ]
                    ]
                , div [ class "controls-wrapper" ]
                    [ div [ class "control" ] [ span [ class "arrow" ] [ text "←" ], text "Left arrow" ]
                    , div [ class "control" ] [ text " | " ]
                    , div [ class "control" ] [ text "Right arrow", span [ class "arrow" ] [ text "→" ] ]
                    ]
                , button
                    [ class "play-btn"
                    , onClick Start
                    , case model.pseudoErrors of
                        Just error ->
                            attribute "disabled" "true"

                        Nothing ->
                            attribute "enabled" "true"
                    ]
                    [ text "Play" ]
                ]

          else if model.gameLost == True then
            div
                [ class "centered-wrapper" ]
                [ div [ class "play-again-wrapper" ]
                    [ h1 [] [ text "Game over" ]
                    , div [ class "footer" ]
                        [ div [ class "level-score" ]
                            [ span [ class "level" ]
                                [ text ("Your level : " ++ String.fromInt model.level) ]
                            , span [ class "score" ] [ text ("Your score : " ++ String.fromInt model.score) ]
                            ]
                        , button
                            [ onClick Restart ]
                            [ text "Play again" ]
                        ]
                    , div [ class "scores" ]
                        [ h2 [] [ text "Scores :" ]
                        , input
                            [ onInput FilterUsername
                            , attribute "placeholder" "Filter username"
                            ]
                            []
                        , case model.topScores of
                            RemoteData.Loading ->
                                span [] [ text "Loading" ]

                            RemoteData.NotAsked ->
                                div [] []

                            RemoteData.Success scores ->
                                Table.view (config model) model.tableState scores

                            RemoteData.Failure err ->
                                div [] [ text "Http Err" ]
                        ]
                    , span [ class "credit" ] [ a [ href "https://github.com/ctaque/elm-pong", target "_blank" ] [ text "A game by Cyprien Taque" ] ]
                    ]
                ]

          else
            div
                [ class "game-board--inner-wrapper"
                ]
                [ span
                    [ class "level" ]
                    [ text ("Level " ++ String.fromInt model.level), text " | ", text ("Score " ++ String.fromInt model.score) ]
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


port getJwt : (String -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.gameLost || model.gameStarted == False then
        Sub.batch
            [ Keyboard.downs KeyDown
            , getJwt GotJwt
            ]

    else
        Sub.batch
            [ Time.every 1 Move
            , Time.every 1 MoveBar
            , Time.every 10000 LevelUp
            , Keyboard.downs KeyDown
            , Keyboard.ups KeyUp
            , E.onResize (\w h -> GotWindowDimensions w h)
            , getJwt GotJwt
            , case model.gameStarted of
                True ->
                    Time.every 100 SetScore

                False ->
                    Sub.none
            ]
