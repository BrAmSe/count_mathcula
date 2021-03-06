// //////////////////////////////////////////////////////////
// TYPE DEFINITION
// //////////////////////////////////////////////////////////
type state = {selected: bool};

// //////////////////////////////////////////////////////////
// FUNCTIONS
// //////////////////////////////////////////////////////////
let getSelectedStyle = selected => if (selected) {" btn-secondary"} else {""};

let getDisabledStyle = disabled => if (disabled) {" disabled"} else {""};

// //////////////////////////////////////////////////////////
// COMPONENT
// /////////////////////////////////////////////////////////
[@react.component]
let make = (~value: int, ~gStatus: string, ~selectOption, ~deselectOption) => {
  // //////////////////////////////////////////////////////////
  // STATE
  // /////////////////////////////////////////////////////////
  let (selected, setSelected) = React.useState(() => false);
  let (disabled, setDisabled) = React.useState(() => true);

  // //////////////////////////////////////////////////////////
  // EFFECTS
  // /////////////////////////////////////////////////////////
  React.useEffect1(
    () => {
      Js.log(gStatus);
      if (gStatus == "playing") {
        setDisabled(_ => false);
        setSelected(_ => false);
      } else {
        setDisabled(_ => true);
      };
      None;
    },
    [|gStatus|],
  );

  // //////////////////////////////////////////////////////////
  // EVENTS
  // /////////////////////////////////////////////////////////
  let onClick = () =>
    if (!disabled) {
      if (selected) {
        setSelected(_ => false);
        deselectOption(value);
      } else {
        setSelected(_ => true);
        selectOption(value);
      };
    };
  // //////////////////////////////////////////////////////////
  // RENDERS
  // /////////////////////////////////////////////////////////
  <div className="col-6 col">
    <button
      onClick={_evt => onClick()}
      className={
        "btn-block"
        ++ getSelectedStyle(selected)
        ++ getDisabledStyle(disabled)
      }>
      {React.string(string_of_int(value))}
    </button>
  </div>;
};