module Update exposing (update)

import Functions exposing (barOffsetFromLeft, barOffsetFromRight, getXPosition, getYPosition, getBarMoveIncrement)
import Keyboard exposing (rawValue)
import Types exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        xPosition =
            getXPosition (Tuple.first model.coordinates) model.windowSize model.xDirection model.level

        yPosition =
            getYPosition model.coordinates model.barXOffset model.barWidth model.windowSize model.yDirection model.level
    in
    case msg of
        Restart ->
            ( { model
                | gameLost = False
                , level = 1
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
            ( { model
                | coordinates = ( Tuple.first xPosition, yPosition.y )
                , xDirection = Tuple.second xPosition
                , yDirection = yPosition.direction
                , gameLost = yPosition.gameLost
              }
            , Cmd.none
            )

        LevelUp _ ->
            ({ model
                | level = model.level + 1
            }, Cmd.none)

        KeyDown key ->
            let
                keyParsed =
                    rawValue key
            in
            case keyParsed of
                "ArrowRight" ->
                    ( { model
                        | barXOffset = barOffsetFromLeft (barOffsetFromRight (model.barXOffset + getBarMoveIncrement model.level) model.windowSize model.barWidth)
                      }
                    , Cmd.none
                    )

                "ArrowLeft" ->
                    ( { model
                        | barXOffset = barOffsetFromLeft (barOffsetFromRight (model.barXOffset - getBarMoveIncrement model.level) model.windowSize model.barWidth)
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )
