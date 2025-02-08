#Decisionlog

## Example
- **Status**: (Proposed | Accepted | Rejected | Deprecated)
- **Date**: YYYY-MM-DD
- **Context**: What is the problem or decision to be made?
- **Decision**: What choice was made?
- **Consequences**: What are the pros/cons or trade-offs?
- **Alternatives Considered**: Other options that were evaluated.
- **References**: Links to relevant discussions or issues.

## Example
- **Status**: Proposed
- **Date**: 2025-03-05
- **Context**: By trying out the macOS build, we had to allow outgoing connections. The question is raised if only HTTPS should be allowed. We believe some people won't use https. We are unsure if we should allow connections to http.
- **Decision**: We will keep https only
- **Consequences**: People who are using http connections, are not able to use the macOS app
- **Alternatives Considered**: allowing http by adding the following in Info.plist:
        <key>NSAppTransportSecurity</key>
        <dict>
            <key>NSAllowsArbitraryLoads</key>
            <true/>
        </dict>
- **References**: None

## No FLAC support
- **Status**: Accepted
- **Date**: 2025-02-23
- **Context**: While implementing the music feature, we found a bug concerning the FLAC files. We discovered FLAC files will fail to correctly display the correct time when the seek function (changing the current position in the song) has been used. This does not happen for .wav or .mp3 files. This can be tested by playing a FLAC and fastforwarding it to the end of the song. The song will keep playing, even though the musicplayer will state the song has ended.

    This issue is not only in JellyFM, but on all other clients using apple architecture. Even the official client in web (safari) will not show the correct time if a seek has been done.
- **Decision**: Currently we choose to not allow flacs. Flacs will be downsized to an mp3/mp4. This is on time of writing not a problem, since only streaming is allowed.
- **Consequences**: Loseless audio is not available. For streaming this would be always a "not allowed". But this decision also impacts future development. Downloading the flac will not be allowed
- **Alternatives Considered**: We could just allow the use of FLACS, and let the UI bug out. This approach is currently used in some other apps. We could let the user choose himself if he want to be able to download the flacs. We will allow donwloading WAV's. We could check if ALAC's are a posibility.'
- **References**: Issue 24 in JellyFM. issue 11113 in Jellyfin
