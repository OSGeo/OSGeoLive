# -*- coding: utf-8 -*-
"""
A simple helper script to tweet the sys.argv[1] (a text input).
Using Python Twitter Tools to communicate with the twitter api.
Damian Avila, 2013
"""
import sys
from twitter import Twitter, OAuth, read_token_file
from twitter.cmdline import CONSUMER_KEY, CONSUMER_SECRET, OPTIONS


def tweet(entry):

    oauth_filename = OPTIONS['oauth_filename']
    oauth_token, oauth_token_secret = read_token_file(oauth_filename)

    t = Twitter(
        auth=OAuth(
            oauth_token, oauth_token_secret, CONSUMER_KEY, CONSUMER_SECRET
        )
    )

    status = '%s' % (entry)
    t.statuses.update(status=status)

try:
    tweet(sys.argv[1])
except IndexError:
    # Message specifically aimed to IPython notebook cells.
    print "Please load your cell with content before tweet it!"