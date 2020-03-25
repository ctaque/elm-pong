module Types exposing (..)
import Keyboard exposing (RawKey)
import Time


type Msg
    = Move Time.Posix
    | KeyDown RawKey
    | Restart
    | Start
    | LevelUp Time.Posix

type alias WindowSize =
    { width : Int
    , height : Int
    }


type alias SetYPositionReturnType =
    { y : Int
    , direction : Int
    , gameLost : Bool
    }


type alias Coordinates =
    ( Int, Int )


type alias Model =
    { coordinates : Coordinates
    , xDirection : Int
    , yDirection : Int
    , windowSize : WindowSize
    , barWidth : Int
    , barXOffset : Int
    , gameLost : Bool
    , gameStarted : Bool
    , level : Int
    }


type alias Flags =
    { windowHeight : Int
    , windowWidth : Int
    }
