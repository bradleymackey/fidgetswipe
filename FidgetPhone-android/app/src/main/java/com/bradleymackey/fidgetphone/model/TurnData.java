package com.bradleymackey.fidgetphone.model;


public final class TurnData implements Cloneable {

    /// The action that this turn requires from the user.
    private Action action;

    /// The user's score as it stands at the moment.
    private int newScore;

    /// The time allowed for this move.
    private double timeForMove;

    public TurnData(Action action, int newScore, double timeForMove) {
        this.action = action;
        this.newScore = newScore;
        this.timeForMove = timeForMove;
    }

    public Action getAction() {
        return action;
    }

    public int getNewScore() {
        return newScore;
    }

    public double getTimeForMove() {
        return timeForMove;
    }

    public TurnData clone() {
        return new TurnData(action,newScore,timeForMove);
    }


}
