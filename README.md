# MacMoveToRift

This is a Unity plugin which will let you move your game onto an OS X user's Oculus Rift DK2, if one is attached to their Mac, without any intervention on their part. To install, put the `MoveRiftToMac.bundle` plugin in your Unity `Assets/Plugins` folder. (You can also build it via the XCode project in `src`.)

To use the plugin, declare a DllImport for it in one of your MonoBehaviors:

```
#if UNITY_STANDALONE_OSX
	[DllImport ("MoveToRiftPlugin")]
	private static extern bool MoveWindowToRift();
#endif
```

And then to actually move the app onto the Rift, you'll need to switch the app out of screen mode, call the plugin to move it, and switch it back into full screen mode. This example shows how you'd do it from inside of a coroutine:

```
#if UNITY_STANDALONE_OSX
		if (Application.platform == RuntimePlatform.OSXPlayer)
		{
			// Take it out of full screen if it is in full screen on mac so we can move it to the rift.
			var wasFullScreen = Screen.fullScreen;

			if (wasFullScreen)
			{
				// Wait for the OS X full screen animation to complete.
				yield return new WaitForSeconds(2.0f);
			}

			// Take the app out of full screen.
			Screen.fullScreen = false;
			Screen.SetResolution (1920, 1080, false);

			if (wasFullScreen)
			{
				// Wait for the OS X full screen animation to complete.
				yield return new WaitForSeconds(2.0f);
			} 

			// Move it onto the Rift via the plugin.
			MoveWindowToRift();

			// Set the app to full screen on the Rift.
			Screen.SetResolution (1920, 1080, true);
		}
#endif
```		
