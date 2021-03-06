Otamata-iOS
===========

Otamata iOS application
-----------------------
The Otamata app lets you play funny sound effects for your friends.  I got the idea one night when hanging out with one of my friends, let's call him "Todd", who was was still in the habit of saying "That's what she said!" after any potentially fitting statement.  You know that old yarn.  Anyway, I thought to myself how awesome it would be to play a "crickets..." sound effect after one of his less successful attempts.  Having an iPhone at the time, it seemed like a good idea to make an iPhone app.

Not ever having coded in Objective-C, there was a bit of a learning curve.  I had to learn the many square brackets, re-learn reference counting, and deal with things called "zombies" when you release too many references.

Anyway, a couple months later and the first version was in the Apple app store.  It got approved for a few subsequent updates as well, but ultimately my last update was NOT approved and basically the project was dead.

The source code is here mostly for academic purposes.  Perhaps someone might find it useful.

Unfortunately, there is some sensitive data in the config.h file relating to the backend API, so it's not included here.  So this probably won't compile.  Let me know if you need a version and I can try to create one.

There's a [backend API and website supporting the app](https://github.com/jbaumbach/Otamata-API-Web) as well, written in C#.

The website should still be live: [http://www.otamata.com/](http://www.otamata.com/)

Description
-----------

Enjoy some screenshots of the various UIViewControllers that make up the Otamata iOS app. 

<table cellpadding="10">

<tr>
<td width="280"><img src="Screenshots/ss-main-no-ad.png" alt="Screenshot" /></td>
<td>The main screen lets you play the perfect sound quickly from your library.</td>
</tr>

<tr>
<td><img src="Screenshots/ss-main-ad.png" alt="Screenshot" /></td>
<td>Those who preferred not to support their friendly neighborhood app developer with a $0.99 in-app purchase saw some ads on the homescreen!</td>
</tr>

<tr>
<td><img src="Screenshots/ss-browse.png" alt="Screenshot" /></td>
<td>You can search the sound database by title or a few other options.</td>
</tr>

<tr>
<td><img src="Screenshots/ss-download.png" alt="Screenshot" /></td>
<td>If you like the sound you're browsing, you can add it to your library or report it as inappropriate.</td>
</tr>

<tr>
<td><img src="Screenshots/ss-websearch.png" alt="Screenshot" /></td>
<td>One feature in the newest release that wasn't approved by Apple is the websearch.  This allowed the user to search
the interwebs for MP3 and WAV clips based on a text search.  This was much easier than having to upload sounds through
the webite.</td>
</tr>

<tr>
<td><img src="Screenshots/ss-icon-websearch.png" alt="Screenshot" /></td>
<td>Once you found a clip you liked on the web, you could also do an image search to find the perfect icon.  There's also a nice image cropping screen in the app (not shown), which had to be CUSTOM MADE, since (at the time) the built-in image cropper in iOS was private and not accessible to developers.</td>
</tr>

<tr>
<td><img src="Screenshots/ss-record-save.png" alt="Screenshot" /></td>
<td>Once you're happy with your searched sound, you can go ahead and save it with a title and description.</td>
</tr>

<tr>
<td><img src="Screenshots/ss-record.png" alt="Screenshot" /></td>
<td>You can also record your own sounds inside the app, up to 7 seconds.  These can be private to you, or shared with the sound community.</td>
</tr>

<tr>
<td><img src="Screenshots/ss-sharing.png" alt="Screenshot" /></td>
<td>What could possibly be more fun than sending the perfect sound effect to your friends!  Press and hold an icon on the main screen to share it (and do some more things, like delete it or rate it 1-5 stars).</td>
</tr>

<tr>
<td><img src="Screenshots/ss-intro-help-1.png" alt="Screenshot" /></td>
<td>Otamata could not be easier to use, but we still included a brief tutorial for the user when it's first installed.</td>
</tr>


</table>


