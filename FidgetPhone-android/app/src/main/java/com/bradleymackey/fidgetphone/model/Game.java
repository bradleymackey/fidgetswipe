package com.bradleymackey.fidgetphone.model;

public final class Game {

    // MARK: Move Times
    public static final double TAP_TIME = 1.7;
    public static final double SWIPE_TIME = 1.7;
    public static final double SHAKE_TIME = 2.0;
    public static final double UPSIDE_DOWN_TIME = 2.1;
    public static final double FACE_TIME = 2.1;
    public static final double VOLUME_TIME = 2.1;

    // Gives a notion of state to the game.
    private enum State {
        PLAYING,
        NOTPLAYING;
    }

    // The current state of the game
    private State currentState;

    // The current score of the game
    private int gameScore;

    /// Keep track of the last action, so we don't do 2 of the same actions in a row.
    private Action lastAction = Action.VOLUME_DOWN; // doesn't really matter what this is

    /// The expected next move of the player.
    /// - note: `null` if game is not currently playing.
    private Action expectedPlayerMove;

    /// Whether or not we have the ability to play the motion challenges.
    private boolean motionChallengesEnabled;

    /// Whether we have played the first turn or not, because the first turn should never be a motion challenge.
    private boolean hasHadFirstTurn;

    public Game() {
        this.gameScore = 0;
        this.currentState = State.NOTPLAYING;
        this.expectedPlayerMove = Action.TAP;
    }

    public

}
