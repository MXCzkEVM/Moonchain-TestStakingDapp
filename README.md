# Test Staking Web App

This is a testing Web APP to test the staking process, written in Flutter. The layout design is only considered for mobile devices.



Update JSON annotations.

```
./update_json_annotations.sh
```



Start the web server and use the browser with Metamask to test the app.

```
flutter run -d web-server --web-port 50080
```

If you want to browse from other device, add `--web-hostname 0.0.0.0`.

If you are using a HTTPS proxy and not serving at root, you will need to comment out the `base href` at `web/index.html`.

```
  <!-- <base href="$FLUTTER_BASE_HREF"> -->
```



Build web app for release.

```
flutter build web --no-tree-shake-icons
```

Add `--base-href "/somepath/"` if you are not deploying at web server root.



Run this to patch the `flutter_bootstrap.js` and make it load the `main.dart.js` every time.

```
./patch_for_release.sh
```

