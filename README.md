# MacMoveToRift

This is a Unity plugin which will let you move your game onto a user's Oculus Rift DK2, if one is attached, without any intervention on their part. To install, put the `MoveRiftToMac.bundle` plugin in your Unity `Assets/Plugins` folder. (You can also build it via the XCode project in `src`.)

To use the plugin, declare a DllImport for it in one of your MonoBehaviors:

```
#if UNITY_STANDALONE_OSX
	[DllImport ("MoveToRiftPlugin")]
	private static extern bool MoveWindowToRift();
#endif
```

And then to actually move the app onto the Rift, you'll need to move it out of full screen mode, call the plugin, and move it back into full screen mode. This example shows how you'd do it from inside of a coroutine:

```
#if UNITY_STANDALONE_OSX
		if (Application.platform == RuntimePlatform.OSXPlayer)
		{
			// Take it out of full screen if it is in full screen on mac so we can move it to the rift.
			var wasFullScreen = Screen.fullScreen;

			if (wasFullScreen)
			{
				yield return new WaitForSeconds(2.0f);
			}

			Screen.fullScreen = false;
			Screen.SetResolution (1920, 1080, false);

			if (wasFullScreen)
			{
				yield return new WaitForSeconds(2.0f);
			} 

			MoveWindowToRift();

			Screen.SetResolution (1920, 1080, true);
		}
#endif
```		
