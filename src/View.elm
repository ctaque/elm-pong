module View exposing (app)
import Types exposing (Model, Msg (..))
import Constants exposing (barYOffset, barHeight, circleRadius)
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)

app : Model -> Html Msg
app model =
    div
        [ style "position" "relative"
        , style "width" "100vw"
        , style "height" "100vh"
        , style "background-color" "rgb(40, 40, 40)"
        ]
        [ if model.gameStarted == False then
            div
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "position" "absolute"
                , style "transform" "translate(-50%, -50%)"
                , style "top" "50%"
                , style "left" "50%"
                ]
                [ h1 [] [ text "Le jeu du Pong" ]
                , button
                    [ onClick Start ]
                    [ text "Jouer" ]
                ]

          else if model.gameLost == True then
            div
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "position" "absolute"
                , style "transform" "translate(-50%, -50%)"
                , style "top" "50%"
                , style "left" "50%"
                ]
                [ h1 [] [ text "Perdu !" ]
                , button
                    [ onClick Restart ]
                    [ text "Rejouer" ]
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
