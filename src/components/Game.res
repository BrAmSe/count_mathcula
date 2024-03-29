module FaGear = {
  @module("react-icons/fa6") @react.component external make: () => React.element = "FaGear"
}

@send external showModal: (Dom.element ) => unit = "showModal"
@send external close: (Dom.element ) => unit = "close"

// //////////////////////////////////////////////////////////
// TYPE DEFINITION
// //////////////////////////////////////////////////////////
let gameStatuses = {
  "new": "new",
  "lost": "lost",
  "won": "won",
  "playing": "playing"
}

type state = {
  gameStatus: string,
  initialSeconds: int,
  accum: int,
}

// //////////////////////////////////////////////////////////
// COMPONENT
// /////////////////////////////////////////////////////////
@react.component
let make = (~iSeconds, ~challengeSize, ~challengeRange) => {
  // //////////////////////////////////////////////////////////
  // STATE
  // /////////////////////////////////////////////////////////
  let (gameStatus, setGameStatus) = React.useState(() => gameStatuses["new"])

  let (accum, setAccum) = React.useState(() => 0)
  let (challengeOptions, setChallengeOptions) = React.useState(() => list{})
  let (targetValue, setTargetValue) = React.useState(() => 0)
  let (gameSettings, setGameSettings) = React.useState(() => {
    let (minValue, maxValue) = challengeRange
    {
      "challengeSize": challengeSize,
      "challengeMaxValue": maxValue,
      "challengeMinValue": minValue
    }
  })

  // //////////////////////////////////////////////////////////
  // REFS
  // /////////////////////////////////////////////////////////
  let refModal = React.useRef(Js.Nullable.null)

  // //////////////////////////////////////////////////////////
  // FUNCTIONS
  // /////////////////////////////////////////////////////////
  let generateOptions =
      (challengeSize, challengeMaxValue, challengeMinValue) => {
    Utils.randomListOfSize(challengeMinValue, challengeMaxValue, challengeSize)
  }

  let selectOption = (targetValue, value) => {
    if (accum + value > targetValue) {
      setGameStatus(_ => gameStatuses["lost"])
    } else if (accum + value == targetValue) {
      setGameStatus(_ => gameStatuses["won"])
    }
    setAccum(prev => prev + value)
  }

  let deselectOption = value => setAccum(prev => prev - value)

  let generateTargetValue = (challengeOptions) => {
    switch(Utils.listSample(challengeOptions, Utils.randomNumber(2, gameSettings["challengeSize"] - 2))) {
      | None => failwith("This should never happen")
      | Some(randomNumberList) =>  Utils.sum(randomNumberList)
    }
  }

  let generateChallenge = () => {
    let challengeOptions = generateOptions(gameSettings["challengeSize"], gameSettings["challengeMaxValue"], gameSettings["challengeMinValue"])
    let targetValue = generateTargetValue(challengeOptions)
    setChallengeOptions(_ => challengeOptions)
    setTargetValue(_ => targetValue)
  }

  let openGameSettingsForm = () => {
    refModal.current
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(modal => modal -> showModal)
  }

  let closeGameSettingsForm = () => {
    refModal.current
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(modal => modal -> close)
  }
  // //////////////////////////////////////////////////////////
  // EFFECTS
  // /////////////////////////////////////////////////////////
  React.useEffect1(
    () => {
      generateChallenge()
      None
    },
    [gameSettings]
  )

  // //////////////////////////////////////////////////////////
  // EVENTS
  // /////////////////////////////////////////////////////////
  let onClickPlayAgain = () => {
    setGameStatus(_ => gameStatuses["new"])
  }

  let onGameStart = () => {
    generateChallenge()
    setAccum(_ => 0)
    setGameStatus(_ => gameStatuses["playing"])
  }

  let onGameReset = () => {
    setGameStatus(_ => gameStatuses["new"])
  }

  let onTimeUp = () => {
    setGameStatus(_ => gameStatuses["lost"])
  }

  // //////////////////////////////////////////////////////////
  // RENDERS
  // /////////////////////////////////////////////////////////
  let renderChallengeOptions = challengeOptions => {
    List.mapWithIndex(
      challengeOptions,
      (index, challengeOption) => {
        <ChallengeOption
          key={string_of_int(index)}
          value=challengeOption
          disabled={gameStatus != gameStatuses["playing"]}
          selectOption={selectOption(targetValue)}
          deselectOption
        />
      }
    )
  }

  let renderSettingsButton = () => {
    if (gameStatuses["new"] == gameStatus) {
      <button className="btn" onClick={_evt => openGameSettingsForm()}>
        <FaGear/>
      </button>
    } else {
      <></>
    }
  }

  let renderFooter = () => {
    if (gameStatuses["won"] == gameStatus || gameStatuses["lost"] == gameStatus) {
      <div className="col-12 col flex-right">
        <button className="btn" onClick={_evt => onClickPlayAgain()}>
          {React.string("Play Again")}
        </button>
      </div>
    } else {
      <>
        <Timer
          value=iSeconds
          onStart=onGameStart
          onReset=onGameReset
          onFinish=onTimeUp
        />
        {renderSettingsButton()}
      </>
    }
  }

  <section>
    <dialog ref={ReactDOM.Ref.domRef(refModal)}>
      <GameSettingsForm
        initialValues={gameSettings}
        onSubmit={(values) => {
          setGameSettings(_ => values)
          closeGameSettingsForm()
        }}
      />
    </dialog>
    <header className="row align-center flex-center">
      <h3>
        {React.string(
           "Pick numbers that sum to the target in "
           ++ string_of_int(iSeconds)
           ++ " seconds",
         )}
      </h3>
    </header>
    <div className="row flex-center">
      <Target value=targetValue status=gameStatus />
    </div>
    <div className="row col-8 flex-center">
      {React.array(
        List.toArray(renderChallengeOptions(challengeOptions))
      )}
    </div>
    <footer className="row flex-center">
      <div className="col-8">
        {renderFooter()}
      </div>
    </footer>
  </section>
}