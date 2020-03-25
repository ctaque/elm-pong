module Subscriptions exposing (subscriptions)
import Types exposing (Model, Msg (..))
import Time
import Keyboard


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    if model.gameLost || model.gameStarted == False then
        Sub.batch [ Keyboard.downs KeyDown ]

    else
        Sub.batch
            [ Time.every 1 Move
            , Keyboard.downs KeyDown
            ]
