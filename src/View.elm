module View exposing (app)

import Constants exposing (barHeight, barYOffset, circleRadius)
import Html exposing (Html, a, button, div, h1, span, text)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Types exposing (Model, Msg(..))


app : Model -> Html Msg
app model =
    div
        [ class "game-board" ]
        [ if model.gameStarted == False then
            div
                [ class "centered-wrapper" ]
                [ h1 [] [ text "The Pong game" ]
                , button
                    [ onClick Start ]
                    [ text "Play" ]
                , div [ class "controls-wrapper" ]
                    [ div [ class "control" ] [ span [ class "arrow" ] [ text "←" ], text "Left arrow" ]
                    , div [ class "control" ] [ text " | " ]
                    , div [ class "control" ] [ text "Right arrow", span [ class "arrow" ] [ text "→" ] ]
                    ]
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
