module Elm.Types exposing (..)

import Keyboard exposing (RawKey)
import RemoteData exposing (WebData)
import Table
import Time


type Msg
    = Move Time.Posix
    | KeyDown RawKey
    | KeyUp RawKey
    | GoLeft
    | GoRight
    | Restart
    | Start
    | LevelUp Time.Posix
    | GotWindowDimensions Int Int
    | MoveBar Time.Posix
    | HandlePseudoChange String
    | SetScore Time.Posix
    | GotScore (WebData (List Score))
    | GotTopScores (WebData (List Score))
    | SetTableState Table.State
    | FilterUsername String
    | GotJwt String


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


type Direction
    = Left
    | Right
    | None


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
    , direction : Direction
    , pseudo : String
    , pseudoErrors : Maybe String
    , apiUrl : String
    , jwtToken : String
    , score : Int
    , savedScore : Maybe Score
    , topScores : WebData (List Score)
    , tableState : Table.State
    , filterScoreUsername : String
    }


type alias Flags =
    { windowHeight : Int
    , windowWidth : Int
    , apiUrl : String
    , jwtToken : String
    }


type alias Score =
    { id : Int
    , pseudo : String
    , level : Int
    , score : Int
    , rank : Int
    }
