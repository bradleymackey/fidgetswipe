package com.bradleymackey.fidgetphone.model;


import android.media.Image;

import com.bradleymackey.fidgetphone.R;

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

    // Returns the image ID for the image that this action represents.
    public int getImageId() {
        switch (action) {
            case TAP:
                return R.drawable.tap;
            case SWIPE_UP:
                return R.drawable.swipe_up;
            case SWIPE_LEFT:
                return R.drawable.swipe_left;
            case SWIPE_DOWN:
                return R.drawable.swipe_down;
            case SWIPE_RIGHT:
                return R.drawable.swipe_right;
            case SHAKE:
                return R.drawable.shake;
            case UPSIDE_DOWN:
                return R.drawable.upside_down;
            case VOLUME_UP:
                return R.drawable.volume_up;
            case VOLUME_DOWN:
                return R.drawable.volume_down;
            case FACE_UP:
                return R.drawable.face_up;
            case FACE_DOWN:
                return R.drawable.face_down;
            default:
                throw new RuntimeException("There is no image ID for this action!");
        }
    }

    public TurnData clone() {
        return new TurnData(action,newScore,timeForMove);
    }


}
