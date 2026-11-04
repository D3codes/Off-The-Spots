# Off The Spots

Add the **Songs** or **Set Lists** Home Screen widget in medium, large, extra-large, or
extra-large portrait size (iOS 27 and later). Song
titles follow your library order, with a play button on the right that opens
Off The Spots and starts the song's selected track. Use the page arrows to reach
the rest of your library. The existing free-song limit also applies to widget
playback.

The **Set Lists** widget starts each set list from its first song and continues
through its saved song order. Set-list playback requires Pro, just like in the
app. Both widgets share the blue gradient, fixed title and page controls, and
top-aligned rows. Their page selections are independent.

Open the app once after installing to populate the widget. Library changes are
shared when the app runs; iOS controls when the Home Screen refreshes.

The small **Spot** widget pairs a random Spot image with one of his quotes,
using the same artwork, themed phrases, and lettering as the in-app Random Spot
view. It schedules a new pairing hourly; iOS controls the exact refresh time.

For device builds, enable App Groups for both **Off The Spots** and
**SongsWidget**, and register `group.codes.d3.Off-The-Spots` with the signing team.
Both targets must have that group in their provisioning profiles. The widget
shares only song and set-list titles and IDs; the existing SwiftData store and audio files
stay in place.
