# YouTube transcript to WordPress
A simple script to download videos from Youtube using youtube_transcript_api and WP CLI to send the data to a custom field in a post.
This was done as a proof of concept for a small research project, it is not intended for huge production websites. Use it at your own risk.
 
## Configuration and usage

Fill in the "CONFIG VARIABLES" section in the get_transcript.sh file with the right values for your environment then launch the script like this:
```
./get_transcript 123
```
where "123" is the ID of the post containing the video

## Requirements

* WP-cli - https://wp-cli.org/
* youtube_transcript_api - https://pypi.org/project/youtube-transcript-api/
* jq - https://stedolan.github.io/jq/
