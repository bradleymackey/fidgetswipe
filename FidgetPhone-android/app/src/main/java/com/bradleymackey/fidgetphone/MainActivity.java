package com.bradleymackey.fidgetphone;

import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.AudioManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.content.ContextCompat;
import android.support.v4.graphics.drawable.DrawableCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.app.AppCompatDelegate;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.ScaleAnimation;
import android.widget.ImageSwitcher;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.bradleymackey.fidgetphone.animation.ProgressBarAnimation;
import com.bradleymackey.fidgetphone.helpers.OnSwipeTouchListener;
import com.bradleymackey.fidgetphone.model.Action;
import com.bradleymackey.fidgetphone.model.Game;
import com.bradleymackey.fidgetphone.model.TurnData;

import java.util.Timer;
import java.util.TimerTask;

import static com.bradleymackey.fidgetphone.model.Action.*;

public class MainActivity extends AppCompatActivity implements SensorEventListener {

    static {
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);
    }

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

    private class MyTimerTask extends TimerTask {
        @Override
        public void run() {
            MainActivity.this.timeRanOut();
        }
    }

    /// Variable so we know when we should accept user input (spam prevention)
    private boolean acceptInput = false;

    /// Whether the game has ended or not
    private boolean gameEnded = false;

    // Manage accelerometer
    private SensorManager mSensorManager;
    private Sensor mAccelerometer;

    // MARK: Game Elements

    private ProgressBar mProgressBar;
    private TextView mScoreLabel;
    private TextView mHighscoreLabel;
    private ImageSwitcher mActionImageSwitcher;
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
        mHighscoreLabel.setAlpha(0.0f); // highscore label initially hidden
        mActionImageSwitcher = (ImageSwitcher) findViewById(R.id.imageSwitcher);
        mPromptLabel = (TextView) findViewById(R.id.promptLabel);
        mActionImageSwitcher.setFactory(new ImageSwitcher.ViewFactory() {
            public View makeView() {
                ImageView myView = new ImageView(getApplicationContext());
                return myView;
            }
        });
        Animation aniIn = AnimationUtils.loadAnimation(this,android.R.anim.fade_in);
        aniIn.setDuration(300);
        mActionImageSwitcher.setInAnimation(aniIn);
        Animation aniOut = AnimationUtils.loadAnimation(this,android.R.anim.fade_out);
        aniOut.setDuration(25);
        mActionImageSwitcher.setOutAnimation(aniOut);
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
        Log.i(TAG,"x:" + x + " y:" + y + " z:" + z);
        switch (currentTurn.getAction()) {
            case FACE_DOWN:
                if (x < 1.5 && x > -1.5 && y < 1.5 && y > -1.5 && z < -8.5 && z > -11.5) {
                    progressGame(game.takeMove(FACE_DOWN),false);
                }
                break;
            case FACE_UP:
                if (x < 1.5 && x > -1.5 && y < 1.5 && y > -1.5 && z > 8.5 && z < 11.5) {
                    progressGame(game.takeMove(FACE_UP),false);
                }
                break;
            case UPSIDE_DOWN:
                if (y > -11.5 && y < -8.5) {
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
        acceptInput = false;

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

    private void animateActionRecievedForPreviousTurnValid(final boolean previousTurnValid, final boolean isFirstLaunch) {
        final long animationDuration = previousTurnValid ? GREEN_FLASH_ANIMATION_TIME : RED_FLASH_ANIMATION_TIME;
        // Animate progress bar back to full
        Handler progressBarHandler = new Handler(Looper.getMainLooper());
        progressBarHandler.post(new Runnable() {
            @Override
            public void run() {
                ProgressBarAnimation progressBarUpAnimation = new ProgressBarAnimation(mProgressBar,mProgressBar.getProgress(),mProgressBar.getMax());
                progressBarUpAnimation.setDuration(animationDuration);
                mProgressBar.startAnimation(progressBarUpAnimation);
            }
        });

        // set the tint color of the image and the progress bar (not animated)
        if (previousTurnValid && !isFirstLaunch) {
            //tintProgressBar(R.color.greenColor);
            mProgressBar.getProgressDrawable().setColorFilter(
                    ContextCompat.getColor(this,R.color.greenColor), android.graphics.PorterDuff.Mode.SRC_IN);
           // mActionImageSwitcher.setColorFilter(ContextCompat.getColor(this,R.color.greenColor));
        } else if (!previousTurnValid && !isFirstLaunch) {
            //tintProgressBar(R.color.redColor);
            mProgressBar.getProgressDrawable().setColorFilter(
                    ContextCompat.getColor(this,R.color.redColor), android.graphics.PorterDuff.Mode.SRC_IN);
           // mActionImageSwitcher.setColorFilter(ContextCompat.getColor(this,R.color.redColor));
        }

        /* code to run after the tint */
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                /* code that runs after the delay */
                // set the new score
                MainActivity.this.mScoreLabel.setText(String.valueOf(currentTurn.getNewScore()));
                // restore tint colors
                MainActivity.this.mProgressBar.getProgressDrawable().setColorFilter(
                        ContextCompat.getColor(MainActivity.this,R.color.colorAccent), android.graphics.PorterDuff.Mode.SRC_IN);
              //  MainActivity.this.mActionImageSwitcher.getForeground().setColorFilter(R.color.colorAccent);
                // display the next action
                MainActivity.this.displayNextAction(previousTurnValid,isFirstLaunch);
            }
        }, animationDuration);
    }

    private void tintProgressBar(int color) {
        // fixes pre-Lollipop progressBar indeterminateDrawable tinting
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            Drawable wrapDrawable = DrawableCompat.wrap(mProgressBar.getIndeterminateDrawable());
            DrawableCompat.setTint(wrapDrawable, ContextCompat.getColor(this, color));
            mProgressBar.setIndeterminateDrawable(DrawableCompat.unwrap(wrapDrawable));
        } else {
            mProgressBar.getIndeterminateDrawable().setColorFilter(ContextCompat.getColor(this, color), PorterDuff.Mode.SRC_IN);
        }
    }

    private void displayNextAction(final boolean previousTurnValid, boolean isFirstLaunch) {
        // cancel the timer
        turnTimer.cancel();
        // depending on first launch either directly set or animate image change.
        if (isFirstLaunch) {
//            mActionImageSwitcher.setImageResource(currentTurn.getImageId());
//            mPromptLabel.setText(currentTurn.getAction().getDescription());
        } else {
            ImageSwitcher imageSwitcher = new ImageSwitcher(this);

            // TODO: animate imageview with new image and prompt label (if not the first launch)
            // TODO: on animation complete, accept input again. Also - if previous turn valid - call `startProgressBarAnimating` and `startCountdownClock`
        }


        // TODO: delete this (make it an animation as the above todos explain
        mActionImageSwitcher.setImageDrawable(ContextCompat.getDrawable(this,currentTurn.getImageId()));
        mPromptLabel.setText(currentTurn.getAction().getDescription());

        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                MainActivity.this.acceptInput = true;
                if (previousTurnValid) {
                    startProgressBarAnimating();
                    startCountdownClock();
                }
            }
        }, 300);

        ///////////////////
    }

    private void startProgressBarAnimating() {
        // force the progress bar back to full
        mProgressBar.setProgress(mProgressBar.getMax());
        // start the progress bar animation back down to 0
        ProgressBarAnimation progressBarDownAnimation = new ProgressBarAnimation(mProgressBar,mProgressBar.getMax(),0);
        progressBarDownAnimation.setDuration(currentTurn.getTimeForMove());
        mProgressBar.startAnimation(progressBarDownAnimation);
    }

    private void startCountdownClock() {
        turnTimer = new Timer("turn timer");
        turnTimer.schedule(new MyTimerTask(),currentTurn.getTimeForMove());
    }

    private void timeRanOut() {
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                MainActivity.this.progressGame(game.takeMove(TIME_RAN_OUT),false);
            }
        });
    }

    private void updateScoreLabelsForGameEnded(boolean gameEnded) {
        // the ending values
        float endingScale = gameEnded ? 1.45f : 1.0f;
        float endingAlpha = gameEnded ? 1.0f : 0.0f;
        // set the score label to 1 to avoid glitching
        if (!gameEnded) { mScoreLabel.setText("1"); }
        // perform the animations
        mScoreLabel.animate().scaleX(endingScale).scaleY(endingScale).setDuration(150).start();
        mHighscoreLabel.animate().alpha(endingAlpha).setDuration(150).start();
    }

    private void changeExtraButtonsForGameEnded(boolean gameEnded) {
        // TODO: hide or show the share button depending on if the game has ended or not
    }

}
