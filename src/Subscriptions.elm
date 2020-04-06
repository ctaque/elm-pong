module Subscriptions exposing (subscriptions)

import Browser.Events as E
import Keyboard
import Time
import Types exposing (Model, Msg(..))



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
