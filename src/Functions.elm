module Functions exposing (..)
import Types exposing (Flags, WindowSize, Model, Msg, Coordinates, SetYPositionReturnType)
import Constants exposing (circleRadius, pxByMove, barHeight, barYOffset)


getBarWidth : Flags -> Int
getBarWidth flags =
    Basics.floor (Basics.min (Basics.toFloat flags.windowWidth / 2) 300)


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { coordinates = ( Basics.floor (toFloat flags.windowWidth / 2), Basics.floor (toFloat flags.windowHeight / 2) )
      , xDirection = 1
      , yDirection = -1
      , barXOffset = Basics.floor ((toFloat flags.windowWidth / 2) - (Basics.toFloat (getBarWidth flags) / 2))
      , gameLost = False
      , gameStarted = False
      , barWidth = getBarWidth flags
      , windowSize =
            { width = flags.windowWidth
            , height = flags.windowHeight
            }
      }
    , Cmd.none
    )



-- UPDATE


setXPosition : Int -> WindowSize -> Int -> ( Int, Int )
setXPosition x windowSize direction =
    if x < circleRadius then
        ( x + pxByMove, 1 )

    else if x >= windowSize.width - circleRadius then
        ( x - pxByMove, -1 )

    else if direction == 1 then
        ( x + pxByMove, 1 )

    else
        ( x - pxByMove, -1 )


setYPosition : Coordinates -> Int -> Int -> WindowSize -> Int -> SetYPositionReturnType
setYPosition coordinates barXOffset barWidth windowSize direction =
    if Tuple.second coordinates <= circleRadius then
        { y = Tuple.second coordinates + pxByMove, direction = 1, gameLost = False }

    else if Tuple.second coordinates >= windowSize.height - circleRadius then
        { y = Tuple.second coordinates - pxByMove, direction = -1, gameLost = True }

    else if direction == 1 && Tuple.second coordinates >= (windowSize.height - barHeight - barYOffset - circleRadius) then
        if Tuple.first coordinates >= barXOffset && Tuple.first coordinates <= barXOffset + barWidth then
            { y = Tuple.second coordinates - pxByMove, direction = -1, gameLost = False }

        else
            { y = Tuple.second coordinates + pxByMove, direction = 1, gameLost = False }

    else if direction == 1 then
        { y = Tuple.second coordinates + pxByMove, direction = 1, gameLost = False }

    else
        { y = Tuple.second coordinates - pxByMove, direction = -1, gameLost = False }


barOffsetFromLeft : Int -> Int
barOffsetFromLeft currentPosition =
    Basics.max currentPosition 0


barOffsetFromRight : Int -> WindowSize -> Int -> Int
barOffsetFromRight nextPosition windowSize barWidth =
    Basics.min nextPosition (windowSize.width - barWidth)

