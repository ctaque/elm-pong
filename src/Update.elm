
module Update exposing (update)
import Types exposing (Msg (..), Model)
import Functions exposing (setXPosition, setYPosition, barOffsetFromLeft, barOffsetFromRight)
import Constants exposing (barMoveIncrement)
import Keyboard exposing (rawValue)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        x =
            setXPosition (Tuple.first model.coordinates) model.windowSize model.xDirection

        yResult =
            setYPosition model.coordinates model.barXOffset model.barWidth model.windowSize model.yDirection
    in
    case msg of
        Restart ->
            ( { model
                | gameLost = False
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
                | coordinates = ( Tuple.first x, yResult.y )
                , xDirection = Tuple.second x
                , yDirection = yResult.direction
                , gameLost = yResult.gameLost
              }
            , Cmd.none
            )

        KeyDown key ->
            let
                keyParsed =
                    rawValue key
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

