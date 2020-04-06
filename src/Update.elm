module Update exposing (update)

import Functions exposing (barOffsetFromLeft, barOffsetFromRight, getBarMoveIncrement, getXPosition, getYPosition)
import Keyboard exposing (rawValue)
import Types exposing (Direction(..), Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        xPosition =
            getXPosition (Tuple.first model.coordinates) model.windowSize model.xDirection model.level

        yPosition =
            getYPosition model.coordinates model.barXOffset model.barWidth model.windowSize model.yDirection model.level
    in
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
                    ( { model | direction = Right }, Cmd.none )

                "ArrowLeft" ->
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
