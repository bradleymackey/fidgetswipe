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
        PLAYING, NOTPLAYING
    }

    // The current state of the game
    private State currentState;

    // The current score of the game
    private int gameScore;

    /// Keep track of the last action, so we don't do 2 of the same actions in a row.
    private Action lastAction


}
