package com.angrypanda.androidflutter;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;

import io.flutter.facade.Flutter;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends AppCompatActivity {

    public static final String FlutterToAndroidCHANNEL  = "com.angrypanda.androidflutter/toandroid";
    public static final String  AndroidToFlutterCHANNEL= "com.angrypanda.androidflutter/toflutter";

    private Button mBtn;
    private View flutterView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        flutterView = Flutter.createView(
                MainActivity.this,
                getLifecycle(),
                "route2"
        );
        mBtn = (Button)findViewById(R.id.button);
        mBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FrameLayout.LayoutParams layout = new FrameLayout.LayoutParams(600, 800);
                layout.leftMargin = 200;
                layout.topMargin = 200;
                addContentView(flutterView, layout);
            }
        });

        /**
         * Android 原生向Flutter传递数据
         */
        new EventChannel((BinaryMessenger) flutterView, AndroidToFlutterCHANNEL)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink eventSink) {
                        String androidParmas = "来自android原生的参数";
                        /**
                         * 本地发送消息事件
                         * 初始化以后可以在任意地方调用
                         */
                        eventSink.success(androidParmas);
                    }
                    @Override
                    public void onCancel(Object o) {

                    }
                });

        /**
         * Flutter 发起对Android原生的会话
         */
        new MethodChannel((BinaryMessenger) flutterView, FlutterToAndroidCHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                //接收来自flutter的指令oneAct
                if (methodCall.method.equals("withoutParams")) {

                    //跳转到指定Activity
                    Intent intent = new Intent(MainActivity.this, Main2Activity.class);
                    startActivity(intent);

                    //返回给flutter的参数
                    result.success("success");
                }
                //接收来自flutter的指令twoAct
                else if (methodCall.method.equals("withParams")) {

                    //解析参数
                    String text = methodCall.argument("flutter");

                    //带参数跳转到指定Activity
                    Intent intent = new Intent(MainActivity.this, MainActivity.class);
                    intent.putExtra("test", text);
                    startActivity(intent);

                    //返回给flutter的参数
                    result.success("success");
                } else {
                    result.notImplemented();
                }
            }
        });

    }
}
