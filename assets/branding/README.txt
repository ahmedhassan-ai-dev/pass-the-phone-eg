Pass The Phone — branding asset handoff

Approved name: Pass The Phone
Package ID: com.ahmedhassan.passthephone (DO NOT CHANGE)

Files:
launcher_icon_1024.png: approved rounded-square graphic on transparent canvas (legacy icon source).
adaptive_foreground_1024.png: safe-zone-sized approved complete graphic (not a separately extracted foreground illustration).
adaptive_background_1024.png: solid purple background.
splash_logo_1024.png: centered transparent-logo source.
play_store_icon_512.png: opaque 512x512 store icon candidate.

Adaptive limitation: the approved image is flattened; its original internal purple square is embedded in the foreground. This is a safe-size approximation, NOT a proper separated foreground/background design. Inspect on Samsung, Pixel/circle and themed icon launchers. Ideally redraw two clean independent layers before final Play launch.
Use Android 12+ SplashScreen API; avoid forced duration. Keep all gameplay and signing unchanged.
