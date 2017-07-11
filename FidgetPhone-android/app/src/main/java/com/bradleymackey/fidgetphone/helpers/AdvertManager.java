package com.bradleymackey.fidgetphone.helpers;

import android.app.Activity;
import android.support.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
// import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;

import java.util.HashMap;

public final class AdvertManager {

    private static AdvertManager sharedInstance = new AdvertManager();

    private FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.getInstance();

    private AdvertManager() {
       // remoteConfig.setConfigSettings(new FirebaseRemoteConfigSettings.Builder().setDeveloperModeEnabled(true).build());
        HashMap<String,Object> defaultValues = new HashMap<>();
        defaultValues.put("ads_enabled",false);
        defaultValues.put("ad_placement_id","");
        remoteConfig.setDefaults(defaultValues);
    }

    public AdvertManager getInstance() {
        return sharedInstance;
    }

    public void updateValues(final Activity activity) {
        final Task<Void> fetch = remoteConfig.fetch(43200);
        fetch.addOnSuccessListener(activity, new OnSuccessListener<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                FirebaseAnalytics.getInstance(activity).logEvent("remote_fetch_success", null);
                remoteConfig.activateFetched();
            }
        });
        fetch.addOnFailureListener(activity, new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                FirebaseAnalytics.getInstance(activity).logEvent("remote_fetch_fail",null);
            }
        });
    }

    public boolean isAdvertsEnabled() {
        return remoteConfig.getBoolean("ads_enabled");
    }

    public String adPlacementId() {
        return remoteConfig.getString("ad_placement_id");
    }

}
