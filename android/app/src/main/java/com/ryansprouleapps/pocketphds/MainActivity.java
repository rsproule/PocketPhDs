package com.ryansprouleapps.pocketphds;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.EmailAuthProvider;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.UserInfo;

import java.util.Map;

public class MainActivity extends FlutterActivity {
  private FirebaseAuth firebaseAuth;

  private static final String CHANNEL = "rsproule.pocketphds/sendResetPasswordEmail";


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
//    FirebaseApp.initializeApp(registrar.context());



    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if(call.method.equals("sendPasswordResetEmail")) {
                  handleSendPasswordResetEmail(call, result);
                }
              }
            });

  }

  private void handleSendPasswordResetEmail(MethodCall call, final Result result){
    Map<String, String> args = call.arguments();
    String email = args.get("email");
    FirebaseAuth.getInstance().sendPasswordResetEmail(email)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
              @Override
              public void onComplete(@NonNull Task<Void> task) {
                if (task.isSuccessful()) {
                  result.success(true);
                }else{
                  result.success(false);
                }
              }
            });
  }
}

