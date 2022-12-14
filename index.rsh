'reach 0.1';

const [gameOutcome, A_WINS, B_WINS, DRAW] = makeEnum(3);

// function that computes the winner based on hands and guesses
const winner = (playHandA, playHandB, gHandA, gHandB) => {

  // if both guesses are the same
  if (gHandA == gHandB) {
    return DRAW;
  } else {
    // if first player guess is equal to total of both hands played
    if (gHandA == (playHandA + playHandB)) {
      return A_WINS;
    } else {
      // if second player guess is equal to total of both hands played
      if (gHandB == (playHandA + playHandB)) {
        return B_WINS;
        // else the outcome is a draw
      } else {
        return DRAW;
      }
    }
  }
};

// the asserts give the forall indicators as to expected outcomes
// can work with any value, we are more concernced with all
// possible combinations of the game outcome given inputs
assert(winner(0, 4, 0, 4) == B_WINS);
assert(winner(4, 0, 4, 0) == A_WINS);
assert(winner(0, 1, 0, 4) == DRAW);
assert(winner(5, 5, 5, 5) == DRAW);

// assert for all possible combinations of inputs
forall(UInt, playHandA =>
  forall(UInt, playHandB =>
    forall(UInt, gHandA =>
      forall(UInt, gHandB =>
        assert(gameOutcome(winner(playHandA, playHandB, gHandA, gHandB)))))));

// assert for all possible hands where guesses are the same
forall(UInt, playHandA =>
  forall(UInt, playHandB =>
    forall(UInt, sameGuess => // this variable is local?
      assert(winner(playHandA, playHandB, sameGuess, sameGuess) == DRAW))));

// shared player method signatures
const Player = {
  ...hasRandom, 
  getHand: Fun([], UInt),
  getGuess: Fun([UInt], UInt),
  seeActual: Fun([UInt], Null),
  seeOutcome: Fun([UInt], Null),
  informTimeout: Fun([], Null),
};

// Reach app starts here
export const main = Reach.App(() => {

  // participant interact interface
  const Alice = Participant('Alice', {
    ...Player, // inherit all Player functions
    wager: UInt, // declare wager
    deadline: UInt, // declare deadline
  });

  // participant interact interface
  const Bob = Participant('Bob', {
    ...Player, // inherit all Player functions
    acceptWager: Fun([UInt], Null), // declare acceptWager method signature
  });

  // initialize the app
  init();

  const informTimeout = () => {
    each([Alice, Bob], () => {
      interact.informTimeout();
    });
  };

  // first participant creates the wager and deadline
  Alice.only(() => {
    const wager = declassify(interact.wager);
    const deadline = declassify(interact.deadline);
  });

  // The first one to publish deploys the contract
  Alice.publish(wager, deadline)
    .pay(wager);
  commit();

  // Bob always accepts this wager
  Bob.only(() => {
    interact.acceptWager(wager);
  });

  // The second one to publish always attaches
  Bob.pay(wager)
    .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));

  var outcome = DRAW;

  // invariant must be true after the execution of the while loop
  // has the balance of the contract stayed the same?
  // is the outcome valid against enumerated type gameOutcome?
  invariant(balance() == 2 * wager && gameOutcome(outcome));

  // while the outcome is still a draw, continue to loop
  while ( outcome == DRAW ) {
    commit();

    Alice.only(() => {
      const _playHandA = interact.getHand();
      // getGuess takes in the value of your hand, so that you can
      // add what you think the other player has
      const _gHandA = interact.getGuess(_playHandA);

      // makeCommitment with salt values
      const [_commitA, _saltA] = makeCommitment(interact, _playHandA);
      const commitA = declassify(_commitA);
      const [_guessCommitA, _guessSaltA] = makeCommitment(interact, _gHandA);
      const guessCommitA = declassify(_guessCommitA);
    });

    // publish commitment to hand and commitment to guess value
    Alice.publish(commitA, guessCommitA)
      .timeout(relativeTime(deadline), () => closeTo(Bob, informTimeout));
    commit();

    // Bob cannot know these values at this state
    unknowable(Bob, Alice(_playHandA, _saltA));
    unknowable(Bob, Alice(_gHandA, _guessSaltA));

    Bob.only(() => {
      const _playHandB = interact.getHand();
      const _gHandB = interact.getGuess(_playHandB);
      const playHandB = declassify(_playHandB);
      const gHandB = declassify(_gHandB);
    });

    Bob.publish(playHandB, gHandB)
      .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));
    commit();

    // Alice can reveal his info
    Alice.only(() => {
      const [saltA, playHandA] = declassify([_saltA, _playHandA]);
      const [guessSaltA, gHandA] = declassify([_guessSaltA, _gHandA]);
    });

    // Alice can publish unhashed values
    Alice.publish(saltA, playHandA, guessSaltA, gHandA)
      .timeout(relativeTime(deadline), () => closeTo(Alice, informTimeout));
    //checkCommitment only takes 3 values
    checkCommitment(commitA, saltA, playHandA);
    checkCommitment(guessCommitA, guessSaltA, gHandA);

    /*
    * having trouble with the front end displaying this
    *
    const winningNum = playHandA + playHandB;

    each([Alice, Bob], () => {
      interact.seeActual(winningNum);
    });
    */

    // all Reach loops require this continue explicitly
    // variables are only permitted to be assigned values
    // immediately preceeding a continue
    outcome = winner(playHandA, playHandB, gHandA, gHandB);
    continue;
  }; // end of while loop

  // make sure that someone has won
  assert(outcome == A_WINS || outcome == B_WINS);

  // transfer winnings to player
  transfer(2 * wager).to(outcome == A_WINS ? Alice : Bob);
  commit();

  // show each player the outcome
  each([Alice, Bob], () => {
    interact.seeOutcome(outcome);
  });
  exit();
});
