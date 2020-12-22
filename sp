#!/usr/bin/env python3

import dbus
import sys
argv = sys.argv

SP_DEST='org.mpris.MediaPlayer2.spotify'
SP_DESTD='org.mpris.MediaPlayer2.spotifyd'
SP_PATH='/org/mpris/MediaPlayer2'
SP_MEMB='org.mpris.MediaPlayer2.Player'

try:
    bus = dbus.SessionBus()
    spotify = bus.get_object(SP_DEST, SP_PATH)
    inter = dbus.Interface(spotify, dbus_interface=SP_MEMB)
    props = dbus.Interface(spotify, dbus_interface='org.freedesktop.DBus.Properties')
except dbus.exceptions.DBusException:
    try:
        bus = dbus.SessionBus()
        spotify = bus.get_object(SP_DESTD, SP_PATH)
        inter = dbus.Interface(spotify, dbus_interface=SP_MEMB)
        props = dbus.Interface(spotify, dbus_interface='org.freedesktop.DBus.Properties')
    except dbus.exceptions.DBusException:
        print('Could not connect with spotify or spotifyd')
        sys.exit()

def get_metadata():
    mdata = props.Get(SP_MEMB, 'Metadata')
    vec = {}
    for key, value in mdata.items():
        key = str(key.split(':')[1])
        if type(value) == dbus.Array:
            value = ', '.join((str(x) for x in value))
        vec[key] = str(value)
    return vec

if len(argv) == 2 and argv[1] != 'help':
    command = argv[1]

    if command == 'play':
        inter.PlayPause()
    elif command == 'pause':
        inter.Pause()
    elif command == 'next':
        inter.Next()
    elif command == 'prev':
        inter.Previous()
    elif command == 'metadata':
        for key, value in get_metadata().items():
            print(f'{key}|{value}')
    elif command == 'current':
        meta = get_metadata()
        if len(meta) != 0:
            print(f'Album       {meta["album"]}')
            print(f'AlbumArtist {meta["albumArtist"]}')
            print(f'Artist      {meta["artist"]}')
            print(f'Title       {meta["title"]}')
    elif command == 'current-oneline':
        meta = get_metadata()
        if len(meta) != 0:
            print(f'{meta["artist"]} | {meta["title"]}')
    else:
        print(f'{command} is not a valid command. Use `sp help` fore more information.')
else:
    print("""
Usage: sp [COMMAND]
Control a running Spotify instance from the command line.

COMMAND:
    play             - Play/pause spotify
    pause            - Pause spotify
    next             - Play next track
    prev             - Play previous track

    metadata         - Dump the current track's metadata
    current          - Format the currently playing track
    current-oneline  - prints `atrist | title`

    help      - Print this help message and exit
""")
