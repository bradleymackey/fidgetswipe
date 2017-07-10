package com.bradleymackey.fidgetphone;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

import com.bradleymackey.fidgetphone.model.Game;
import com.bradleymackey.fidgetphone.model.TurnData;

import static com.bradleymackey.fidgetphone.model.Action.*;

public class MainActivity extends AppCompatActivity {

    // MARK: Logging

    public static final String TAG = "mainac";

    // MARK: Animation Constants

    public static final double GREEN_FLASH_ANIMATION_TIME = 0.2;
    public static final double RED_FLASH_ANIMATION_TIME = 0.5;
    public static final double NEXT_MOVE_ANIMATION_TIME = 0.25;
    public static final double RESTORE_PROGRESS_BAR_ANIMATION_TIME = 0.1;

    // MARK: Game Management

    // Manages the whole game
    private Game game = new Game();
    private TurnData currentTurn;

    /// Variable so we know when we should accept user input (spam prevention)
    private boolean acceptInput = false;

    /// Whether the game has ended or not
    private boolean gameEnded = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Set the gesture listeners
        View rootView = findViewById(android.R.id.content);
        setGestureListenersForView(rootView);

        // setup the game's first action
        progressGame(false,true);

    }

    private void setGestureListenersForView(View view) {
        view.setOnTouchListener(new OnSwipeTouchListener(MainActivity.this) {
            @Override
            public void onSwipeBottom() {
                if (!acceptInput) { return; }
                Log.i(TAG, "swipe bottom");
                MainActivity.this.progressGame(game.takeMove(SWIPE_DOWN), false);
            }

            @Override
            public void onSwipeLeft() {
                if (!acceptInput) { return; }
                Log.i(TAG, "swipe left");
                MainActivity.this.progressGame(game.takeMove(SWIPE_LEFT), false);
            }

            @Override
            public void onSwipeRight() {
                if (!acceptInput) { return; }
                Log.i(TAG, "swipe right");
                MainActivity.this.progressGame(game.takeMove(SWIPE_RIGHT), false);
            }

            @Override
            public void onSwipeTop() {
                if (!acceptInput) { return; }
                Log.i(TAG, "swipe top");
                MainActivity.this.progressGame(game.takeMove(SWIPE_UP), false);
            }

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP && acceptInput) {
                    Log.i(TAG, "tap");
                    MainActivity.this.progressGame(game.takeMove(TAP), false);
                }
                return super.onTouch(v, event);
            }
        });
    }

    // MARK: Game State

    private void progressGame(boolean previousTurnValid, boolean isFirstLaunch) {

        // stop accepting input (to prevent spamming)
        acceptInput = false;

        if (!previousTurnValid && currentTurn != null) {
            gameEnded = true;
            // make score label big and show highscore label
            //updateScoreLabelsForGameEnded(true);
            // show the extra buttons
            //changeExtraButtonsForGameEnded(true);
        } else if (gameEnded) {
            gameEnded = false;
            // return score label to normal size and hide the highscore label
            //updateScoreLabelsForGameEnded(false);
            // hide the extra buttons
            //changeExtraButtonsForGameEnded(false);
        }

        // get the next turn from the game
        currentTurn = game.nextMove();

        // TODO: start listening for accelerometer updates if needed

        // animate to the next turn
        //animateActionRecievedForPreviousTurnValid(previousTurnValid,isFirstLaunch);


    }


}
