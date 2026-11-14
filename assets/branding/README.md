# Android branding sources

Use the owner's existing PNGs as supplied; do not regenerate the illustration.

| Source | Usage |
| --- | --- |
| `adaptive_foreground.png` | Transparent launcher handoff artwork; adaptive foreground and legacy raster fallback |
| `adaptive_background2.png` | Vivid gradient launcher background |
| `adaptive_background.png` | Dark purple palette reference; center sample `#2D037F` is the native splash background |
| `splash_logo.png` | Dedicated transparent native splash emblem |

Sources are 1254x1254. The old flattened `_1024.png` files were removed by the owner and are no longer required. No Play Store image is generated or published by this configuration.

Run from the project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tool/sync_android_branding.ps1
```

The script validates source presence, copies the splash PNG into Android's `drawable-nodpi`, and runs the existing launcher generator. Generated density resources are checked in alongside the native XML. Flutter runtime asset declarations are unnecessary for these native resources.

Android 26+ composes the vivid background and foreground using the adaptive icon API, with 20% foreground inset per side. Android 24/25 uses `mipmap-anydpi/ic_launcher.xml`, a native layer-list over the same generated layers with 7% inset because legacy icons do not use the adaptive icon's enlarged layer viewport. This avoids dependence on a separately edited flattened image.

Splash screens use the same solid purple in light/dark mode and a separate 20% inset emblem. Pre-12 Android centers a 288dp drawable; Android 12+ uses the system splash icon. A uniform color matches Android 12's native background constraint, avoiding an extra Flutter splash route or artificial delay.

`docs/branding/preview.html` shows static approximations, including the legacy icon. Device mask behavior and physical launch transitions require owner review. Supplied source edge residue has not been retouched; this integration does not certify the illustration's edge quality.
