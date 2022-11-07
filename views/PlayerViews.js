import React from 'react';

const exports = {};

exports.GetHand = class extends React.Component {
  render() {
    const {parent, playable, hand} = this.props;
    return (
      <div>
        {hand ? 'Close enough! It\'s a draw, pick another hand.' : ''}
        <br />
        {!playable ? 'Please wait...' : ''}
        <br />
        {'Please pick a hand'}
        <br />
        <br />
        <button
          disabled={!playable}
          onClick={() => parent.playHand(0)}
        >0</button>
        <button
          disabled={!playable}
          onClick={() => parent.playHand(1)}
        >1</button>
        <button
          disabled={!playable}
          onClick={() => parent.playHand(2)}
        >2</button>
        <button
          disabled={!playable}
          onClick={() => parent.playHand(3)}
        >3</button>
        <button
          disabled={!playable}
          onClick={() => parent.playHand(4)}
        >4</button>
        <button
          disabled={!playable}
          onClick={() => parent.playHand(5)}
        >5</button>
      </div>
    );
  }
}

exports.GetGuess = class extends React.Component{
  render(){
    const {parent, playable, guess} = this.props;
    return(
      <div>
        {guess ? 'Close enough! It\'s a draw, guess another.' : ''}
        <br />
        {!playable ? 'Please Wait...' : ''}
        <br />
        {'Please guess the total'}
        <br />
        <br />
        <button
          disabled={!playable}
          onClick={() => parent.playGuess(0)}
        >0</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(1)}
        >1</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(2)}
        >2</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(3)}
        >3</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(4)}
        >4</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(5)}
        >5</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(6)}
        >6</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(7)}
        >7</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(8)}
        >8</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(9)}
        >9</button>
        <button
          disable={!playable}
          onClick={() => parent.playGuess(10)}
        >10</button>
      </div>
    );
  }
}

exports.WaitingForResults = class extends React.Component {
  render() {
    return (
      <div>
        Waiting for results...
      </div>
    );
  }
}

exports.Done = class extends React.Component {
  render() {
    const {outcome} = this.props;
    return (
      <div>
        Thank you for playing. The winner:
        <br />{outcome || 'Unknown'}
      </div>
    );
  }
}

exports.Timeout = class extends React.Component {
  render() {
    return (
      <div>
        There's been a timeout. (Someone took too long.)
      </div>
    );
  }
}

export default exports;
