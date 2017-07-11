package com.bradleymackey.fidgetphone.model;

import static com.bradleymackey.fidgetphone.model.Action.*;

public final class Game {

    // MARK: Move Times
    public static final long TAP_TIME = 1700;
    public static final long SWIPE_TIME = 1700;
    public static final long SHAKE_TIME = 2000;
    public static final long UPSIDE_DOWN_TIME = 2100;
    public static final long FACE_TIME = 2100;
    public static final long VOLUME_TIME = 2100;

    // Gives a notion of state to the game.
    private enum State {
        PLAYING,
        NOT_PLAYING
    }

    // The current state of the game
    // ONLY EVER SET THIS WITH THE DESIGNATED SETTER, BECAUSE WE NEED CUSTOM BEHAVIOUR UPON SETTING
    private State currentState = State.NOT_PLAYING;

    // The custom setter for currentState
    private void setCurrentState(State newState) {
        if (currentState == State.NOT_PLAYING && newState == State.PLAYING) {
            gameScore = 0;
        }
        this.currentState = newState;
    }

    // The current score of the game
    private int gameScore = 0;

    /// Keep track of the last action, so we don't do 2 of the same actions in a row.
    private Action previousAction = Action.VOLUME_DOWN; // doesn't really matter what this is

    /// The expected next move of the player.
    /// - note: `null` if game is not currently playing.
    private Action expectedPlayerMove = TAP; // initial value does not really matter

    /// Whether or not we have the ability to play the motion challenges.
    private boolean motionChallengesEnabled = true;

    /// Whether we have played the first turn or not, because the first turn should never be a motion challenge.
    private boolean hasHadFirstTurn = false;

    // nothing needed in here, all properties are already initalised
    public Game() { }

    public boolean isMotionChallengesEnabled() {
        return motionChallengesEnabled;
    }

    public void setMotionChallengesEnabled(boolean motionChallengesEnabled) {
        this.motionChallengesEnabled = motionChallengesEnabled;
    }

    public TurnData nextMove() {
        // set the move to a random move
        this.expectedPlayerMove = Action.random();
        // if motion challenges are not enabled, do not choose motion challenges (also do not perform a motion challenge for the first turn AND we cannot have 2 motion challenges in a row).
        // make sure not to repeat the same action 2 times in a row
        if (!motionChallengesEnabled || !hasHadFirstTurn || previousAction.isMotionChallenge()) {
            hasHadFirstTurn = true;
            while (expectedPlayerMove.isMotionChallenge() || expectedPlayerMove == previousAction || expectedPlayerMove == TIME_RAN_OUT) {
                this.expectedPlayerMove = Action.random();
            }
        } else {
            while (expectedPlayerMove == previousAction || expectedPlayerMove == TIME_RAN_OUT) {
                this.expectedPlayerMove = Action.random();
            }
        }
        // set the previous action
        this.previousAction = this.expectedPlayerMove;
        return new TurnData(this.expectedPlayerMove, this.gameScore, timeForMove(this.expectedPlayerMove));
    }

    /// The time allowed for each given move
    private long timeForMove(Action action) {
        switch (action) {
            case SWIPE_DOWN: case SWIPE_LEFT: case SWIPE_RIGHT: case SWIPE_UP:
                return SWIPE_TIME;
            case TAP:
                return TAP_TIME;
            case VOLUME_DOWN: case VOLUME_UP:
                return VOLUME_TIME;
            case FACE_DOWN: case FACE_UP:
                return FACE_TIME;
            case UPSIDE_DOWN:
                return UPSIDE_DOWN_TIME;
            case SHAKE:
                return SHAKE_TIME;
            default:
                throw new RuntimeException("time ran out for an action that does not have a time");
        }
    }

    /// Player calls this when they take a move.
    /// - returns: true if this was a valid action, false if this was not, the game has now ended.
    public boolean takeMove(Action move) {

        // we have taken a move, so we are now playing
        setCurrentState(State.PLAYING);

        // evaluate this move we have just taken, ending the game if we need to
        if (move != this.expectedPlayerMove) {
            setCurrentState(State.NOT_PLAYING);
            hasHadFirstTurn = false;
            return false;
        } else {
            setCurrentState(State.PLAYING);
            gameScore += 1;
            return true;
        }

    }

}
