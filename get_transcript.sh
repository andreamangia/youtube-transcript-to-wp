###################################
# YOUTUBE TRANSCRIPT TO WORDPRESS #
###################################
#
# A simple script to download videos from Youtube using youtube_transcript_api
# and WP CLI to send the data to a custom field in a post.
#
# Copyright 2019 Andrea Mangiatordi, andrea.mangiatordi@unimib.it
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# CONFIGURATION AND USAGE
#
# Fill in the "CONFIG VARIABLES" section with the right values for your
# environment then launch the script like this:
#
# ./get_transcript 123 <- where "123" is the ID of the post containing the video
#
# REQUIREMENTS
# WP-cli - https://wp-cli.org/
# youtube_transcript_api - https://pypi.org/project/youtube-transcript-api/
# jq - https://stedolan.github.io/jq/

# CONFIG VARIABLES
SSH_PORT="22" # SSH port of the web server
SSH_USER="user" # SSH User name
SSH_HOST="host" # SSH host
SITE_URL="example.com" # Website url (needed if the site is part of a Wordpress netowork)
WP_PATH="public_html" # Path to wrodpress install
TRANSCRIPT_CF="transcript" # Name of the Wordpress custom field where the transcription should end up to

# Wordpress Command Line Interface is required for this script to work
WPCLI_PATH="/home/User/wordpress/wp-cli.phar" # Path to your WP CLI script, i.e. /home/user/wordpress/wp-cli.phar
TRANSCRIPT_API_PATH="/usr/local/bin/youtube_transcript_api" # Path to Youtube Transcript API, i.e. /usr/local/bin/youtube_transcript_api

# Print the Wordpress post id
echo $1;

YT_ID=$($WPCLI_PATH --path=$WP_PATH --url=$SITE_URL --ssh=$SSH_USER@$SSH_HOST:$SSH_PORT post meta get $1 external_id)

$TRANSCRIPT_API_PATH $YT_ID --languages it --json > $YT_ID.txt

TRANSCRIPT_LENGTH=$(jq '."'"$YT_ID"'" | length' $YT_ID.txt)

TRANSCRIPT_HTML=""

TRANSCRIPT_HTML="<span class=\"video-links\">"

COUNTER=0
while [  $COUNTER -lt $TRANSCRIPT_LENGTH ]; do
  TRANSCRIPT_HTML+="<a href=\"#\" data-start=\""
  TRANSCRIPT_HTML+=$(jq '."'"$YT_ID"'"['"$COUNTER"'] | .start' --raw-output $YT_ID.txt)
  TRANSCRIPT_HTML+="\">"
  TRANSCRIPT_HTML+=$(jq '."'"$YT_ID"'"['"$COUNTER"'] | .text' --raw-output $YT_ID.txt)
  TRANSCRIPT_HTML+="</a> "
  let COUNTER=COUNTER+1
done
TRANSCRIPT_HTML+="</span>"

rm $YT_ID.txt # Cleanup the local subtitles file

$WPCLI_PATH --path=$WP_PATH --url=$SITE_URL --ssh=$SSH_USER@$SSH_HOST:$SSH_PORT post meta set $1 $TRASNCRIPT_CF "$TRANSCRIPT_HTML"
