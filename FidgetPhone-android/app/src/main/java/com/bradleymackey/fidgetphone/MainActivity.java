package com.bradleymackey.fidgetphone;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.AudioManager;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.bradleymackey.fidgetphone.animation.ProgressBarAnimation;
import com.bradleymackey.fidgetphone.helpers.OnSwipeTouchListener;
import com.bradleymackey.fidgetphone.model.Action;
import com.bradleymackey.fidgetphone.model.Game;
import com.bradleymackey.fidgetphone.model.TurnData;

import org.w3c.dom.Text;

import java.util.Timer;
import java.util.TimerTask;

import static com.bradleymackey.fidgetphone.model.Action.*;

public class MainActivity extends AppCompatActivity implements SensorEventListener {

    // MARK: Logging

    public static final String TAG = "mainac";

    // MARK: The Shake Threshold

    private static final int SHAKE_THRESHOLD = 800;

    // MARK: Animation Constants

    public static final long GREEN_FLASH_ANIMATION_TIME = 200;
    public static final long RED_FLASH_ANIMATION_TIME = 500;
    public static final long NEXT_MOVE_ANIMATION_TIME = 250;
    public static final long RESTORE_PROGRESS_BAR_ANIMATION_TIME = 100;

    // MARK: Game Management

    // Manages the whole game
    private Game game = new Game();
    private TurnData currentTurn;

    // Manage the timing of turns
    private Timer turnTimer = new Timer("turn_timer");
    private TimerTask timerTask = new TimerTask() {
        @Override
        public void run() {
            MainActivity.this.timeRanOut();
        }

        @Override
        public boolean cancel() {
            Log.i(TAG, "timer task being cancelled!");
            return super.cancel();
        }
    };

    /// Variable so we know when we should accept user input (spam prevention)
    private boolean acceptInput = true;

    /// Whether the game has ended or not
    private boolean gameEnded = false;

    // Manage accelerometer
    private SensorManager mSensorManager;
    private Sensor mAccelerometer;

    // MARK: Game Elements

    private ProgressBar mProgressBar;
    private TextView mScoreLabel;
    private TextView mHighscoreLabel;
    private ImageView mActionImageView;
    private TextView mPromptLabel;

    // MARK: Initalisation

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Get the elements from the xml
        setViewElementVariables();

        // set volume mode to affect music, not ringer.
        // it shouldn't affect it anyway, but just in case
        setVolumeControlStream(AudioManager.STREAM_MUSIC);

        // Set the gesture listeners
        View rootView = findViewById(android.R.id.content);
        setGestureListenersForView(rootView);

        // Set the accelerometer sensor variables
        mSensorManager = (SensorManager)getSystemService(SENSOR_SERVICE);
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

        // setup the game's first action
        progressGame(false,true);

    }

    private void setViewElementVariables() {
        mProgressBar = (ProgressBar) findViewById(R.id.progressBar);
        mScoreLabel = (TextView) findViewById(R.id.scoreLabel);
        mHighscoreLabel = (TextView) findViewById(R.id.highscoreLabel);
        mActionImageView = (ImageView) findViewById(R.id.imageView);
        mPromptLabel = (TextView) findViewById(R.id.promptLabel);
    }

    // MARK: Interaction Handling


    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        switch (event.getKeyCode()) {
            case KeyEvent.KEYCODE_VOLUME_UP:
                Log.i(TAG,"VU");
                progressGame(game.takeMove(VOLUME_UP),false);
                return true;
            case KeyEvent.KEYCODE_VOLUME_DOWN:
                Log.i(TAG,"VD");
                progressGame(game.takeMove(VOLUME_DOWN),false);
                return true;
            default:
                return super.onKeyDown(keyCode, event);
        }
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
            public void quickTouch() {
                if (!acceptInput) { return; }
                Log.i(TAG, "quick tap!");
                MainActivity.this.progressGame(game.takeMove(TAP), false);
            }
        });
    }

    private void handleMotionActionVerification(float x, float y, float z) {
        switch (currentTurn.getAction()) {
            case FACE_DOWN:
                if (x < 0.25 && x > -0.25 && y < 0.25 && y > -0.25 && z < 1.25 && z > 0.75) {
                    progressGame(game.takeMove(FACE_DOWN),false);
                }
                break;
            case FACE_UP:
                if (x < 0.25 && x > -0.25 && y < 0.25 && y > -0.25 && z > -1.25 && z < -0.75) {
                    progressGame(game.takeMove(FACE_UP),false);
                }
                break;
            case UPSIDE_DOWN:
                if (y > 0.75 && y < 1.25) {
                    progressGame(game.takeMove(UPSIDE_DOWN),false);
                }
                break;
            case SHAKE:
                // run a custom method to verify a shake
                verifyShake(x,y,z);
                break;
            default:
                Log.e(TAG,"Trying to verify a device position even though this is not a motion challenge!");
                break;
        }
    }

    // Used for calculating a shake.
    private long lastUpdate = 0;
    private float last_x, last_y, last_z = 0;

    private void verifyShake(float x, float y, float z) {

        // set the values initially, so we have a delta
        if (lastUpdate == 0) {
            lastUpdate = System.currentTimeMillis();
            last_x = x;
            last_y = y;
            last_z = z;
            return;
        }

        // do the differential calculations
        long curTime = System.currentTimeMillis();
        // only allow one update every 100ms.
        if ((curTime - lastUpdate) > 100) {
            long diffTime = (curTime - lastUpdate);
            lastUpdate = curTime;

            float speed = Math.abs(x+y+z - last_x - last_y - last_z) / diffTime * 10000;

            if (speed > SHAKE_THRESHOLD) {
                Log.d("sensor", "shake detected w/ speed: " + speed);
                progressGame(game.takeMove(SHAKE),false);
                // reset the previous values to 0, so when we start another shake challenge we aren't using values from ages ago, which could cause glitches.
                lastUpdate = 0;
                last_x = 0;
                last_y = 0;
                last_z = 0;
            } else {
                last_x = x;
                last_y = y;
                last_z = z;
            }
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {
        Log.i(TAG,"Sensor accuracy changed!");
    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        // return if the sensor is not the accelerometer
        if (sensorEvent.sensor.getType() != Sensor.TYPE_ACCELEROMETER)
            return;
        float x = sensorEvent.values[0];
        float y = sensorEvent.values[1];
        float z = sensorEvent.values[2];
        handleMotionActionVerification(x,y,z);
    }

    // MARK: Game State

    private void progressGame(boolean previousTurnValid, boolean isFirstLaunch) {

        // stop accepting input (to prevent spamming)
        acceptInput = true;

        if (!previousTurnValid && currentTurn != null) {
            gameEnded = true;
            // make score label big and show highscore label
            updateScoreLabelsForGameEnded(true);
            // show the extra buttons
            changeExtraButtonsForGameEnded(true);
        } else if (gameEnded) {
            gameEnded = false;
            // return score label to normal size and hide the highscore label
            updateScoreLabelsForGameEnded(false);
            // hide the extra buttons
            changeExtraButtonsForGameEnded(false);
        }

        // get the next turn from the game
        currentTurn = game.nextMove();

        // start listening for accelerometer updates if needed (and stop if this is not a motion challenge)
        startAccelerometerUpdatesIfNeededForAction(currentTurn.getAction());

        // animate to the next turn
        animateActionRecievedForPreviousTurnValid(previousTurnValid,isFirstLaunch);
    }

    private void startAccelerometerUpdatesIfNeededForAction(Action action) {
        if (action.isMotionChallenge()) {
            mSensorManager.registerListener(this,mAccelerometer,SensorManager.SENSOR_DELAY_GAME);
        } else {
            mSensorManager.unregisterListener(this);
        }
    }

    private void animateActionRecievedForPreviousTurnValid(boolean previousTurnValid, boolean isFirstLaunch) {
        long animationDuration = previousTurnValid ? GREEN_FLASH_ANIMATION_TIME : RED_FLASH_ANIMATION_TIME;
        // Animate progress bar back to full
        ProgressBarAnimation progressBarUpAnimation = new ProgressBarAnimation(mProgressBar,mProgressBar.getProgress(),mProgressBar.getMax());
        progressBarUpAnimation.setDuration(animationDuration);
        mProgressBar.startAnimation(progressBarUpAnimation);
        // TODO: animate flash progress bar and score label red/green and [restore progress bar to 1](done)
        // TODO: on completion of that, update the score label, and remove the tint colours and call displayNextAction (below)
    }

    private void displayNextAction(boolean previousTurnValid,boolean isFirstLaunch) {
        // cancel the timer
        turnTimer.cancel();
        turnTimer.purge();
        // depending on first launch either directly set or animate image change.
        if (isFirstLaunch) {
            mActionImageView.setImageResource(currentTurn.getImageId());
            mPromptLabel.setText(currentTurn.getAction().getDescription());
        } else {
            // TODO: animate imageview with new image and prompt label (if not the first launch)
            // TODO: on animation complete, accept input again. Also - if previous turn valid - call `startProgressBarAnimating` and `startCountdownClock`
        }
    }

    private void startProgressBarAnimating() {
        // force the progress bar back to full
        mProgressBar.setProgress(mProgressBar.getMax(),false);
        // start the progress bar animation back down to 0
        ProgressBarAnimation progressBarDownAnimation = new ProgressBarAnimation(mProgressBar,mProgressBar.getMax(),0);
        progressBarDownAnimation.setDuration(currentTurn.getTimeForMove());
        mProgressBar.startAnimation(progressBarDownAnimation);
    }

    private void startCountdownClock() {
        turnTimer.cancel();
        turnTimer.purge();
        turnTimer.schedule(timerTask,currentTurn.getTimeForMove());
    }

    private void timeRanOut() {
        MainActivity.this.progressGame(game.takeMove(TIME_RAN_OUT),false);
    }

    private void updateScoreLabelsForGameEnded(boolean gameEnded) {
        if (gameEnded) {
            // TODO: animate score label big
            // TODO: present highscore label
        } else {
            // TODO: update score label to "1" and make small again
            // TODO: hide the highscore label
        }
    }

    private void changeExtraButtonsForGameEnded(boolean gameEnded) {
        // TODO: hide or show the share button depending on if the game has ended or not
    }

}
