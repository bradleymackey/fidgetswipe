package com.bradleymackey.fidgetphone.model;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;

public enum Action {

    TAP,
    SWIPE_UP,
    SWIPE_DOWN,
    SWIPE_RIGHT,
    SWIPE_LEFT,
    SHAKE,
    UPSIDE_DOWN,
    VOLUME_UP,
    VOLUME_DOWN,
    FACE_UP,
    FACE_DOWN,
    TIME_RAN_OUT; // the special action

    private static final List<Action> VALUES =
            Collections.unmodifiableList(Arrays.asList(values()));
    private static final int SIZE = VALUES.size();
    private static final Random RANDOM = new Random();

    public static Action random()  {
        Action randomAction = TIME_RAN_OUT;
        while (randomAction == TIME_RAN_OUT) {
            randomAction = VALUES.get(RANDOM.nextInt(SIZE)-1);
        }
        return VALUES.get(RANDOM.nextInt(SIZE));
    }

    public String getDescription() {
        switch (this) {
            case TAP:
                return "TAP";
            case SWIPE_UP: case SWIPE_LEFT: case SWIPE_DOWN: case SWIPE_RIGHT:
                return "SWIPE";
            case SHAKE:
                return "SHAKE";
            case UPSIDE_DOWN:
                return "ROTATE";
            case VOLUME_UP:
                return "VOLUME UP";
            case VOLUME_DOWN:
                return "VOLUME DOWN";
            case FACE_UP:
                return "FACE UP";
            case FACE_DOWN:
                return "FACE DOWN";
            default:
                throw new RuntimeException("Invalid! No description for this Action");
        }
    }

    public boolean isMotionChallenge() {
        switch (this) {
            case UPSIDE_DOWN: case FACE_UP: case FACE_DOWN: case SHAKE:
                return true;
            default:
                return false;
        }
    }

}
