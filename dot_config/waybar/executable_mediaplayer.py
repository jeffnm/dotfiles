#!/usr/bin/env python3
import argparse
import logging
import sys
import signal
import gi
import json
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')


def write_output(text, player):
    """Write output to stdout."""
    logger.info('Writing output')

    output = {'text': text,
              'class': 'custom-' + player.props.player_name,
              'alt': player.props.player_name,
              'loop': player.get_property('loop-status')}

    sys.stdout.write(json.dumps(output) + '\n')
    sys.stdout.flush()


def on_play(player, status, manager):
    """Handle playback status change."""
    logger.info('Received new playback status')
    on_metadata(player, player.props.metadata, manager)


def on_metadata(player, metadata, manager):
    """Handle metadata change."""
    logger.info('Received new metadata')
    track_info = ''

    # Check if Spotify ad is playing
    if player.props.player_name == 'spotify' and \
            'mpris:trackid' in metadata.keys() and \
            ':ad:' in player.props.metadata['mpris:trackid']:
        track_info = 'AD PLAYING'
    # Check if artist and title are available
    elif player.get_artist() != '' and player.get_title() != '':
        track_info = '{artist} - {title}'.format(artist=player.get_artist(),
                                                 title=player.get_title())
    else:
        track_info = player.get_title()

    # Add status icon based on player state
    if player.props.status == 'Playing':
        track_info = ' ' + track_info
    else:
        track_info = ' ' + track_info

    # Add loop status indicators - only updates on metadata/playback changes
    # Loop status values: 0=None, 1=Track, 2=Playlist
    # Note: Not all players implement loop status (e.g. Firefox)
    try:
        loop_status = player.get_property('loop-status')
        if loop_status == 1:
            track_info = '󰑘 ' + track_info  # Track repeat
        elif loop_status == 2:
            track_info = '󰑖 ' + track_info  # Playlist repeat
    except GLib.Error:
        pass  # Player doesn't support loop status
    except Exception as e:
        logger.error(f"Unexpected error getting loop status: {e}")

    write_output(track_info, player)


def on_player_appeared(manager, player, selected_player=None):
    """Handle player appearance."""
    if player is not None and (selected_player is None or player.name == selected_player):
        init_player(manager, player)
    else:
        logger.debug("New player appeared, but it's not the selected player, skipping")


def on_player_vanished(manager, player):
    """Handle player disappearance."""
    logger.info('Player has vanished')
    sys.stdout.write('\n')
    sys.stdout.flush()


def init_player(manager, name):
    """Initialize player."""
    logger.debug('Initialize player: {player}'.format(player=name.name))
    player = Playerctl.Player.new_from_name(name)
    player.connect('playback-status', on_play, manager)
    player.connect('metadata', on_metadata, manager)
    manager.manage_player(player)
    on_metadata(player, player.props.metadata, manager)


def signal_handler(sig, frame):
    """Handle signal."""
    logger.debug('Received signal to stop, exiting')
    sys.stdout.write('\n')
    sys.stdout.flush()
    # loop.quit()
    sys.exit(0)


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser()

    # Increase verbosity with every occurrence of -v
    parser.add_argument('-v', '--verbose', action='count', default=0)

    # Define for which player we're listening
    parser.add_argument('--player')

    return parser.parse_args()


def main():
    """Main function."""
    arguments = parse_arguments()

    # Initialize logging
    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    # Log the sent command line arguments
    logger.debug('Arguments received {}'.format(vars(arguments)))

    manager = Playerctl.PlayerManager()
    loop = GLib.MainLoop()

    manager.connect('name-appeared', lambda *args: on_player_appeared(*args, arguments.player))
    manager.connect('player-vanished', on_player_vanished)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)

    for player in manager.props.player_names:
        if arguments.player is not None and arguments.player != player.name:
            logger.debug('{player} is not the filtered player, skipping it'
                         .format(player=player.name)
                         )
            continue

        init_player(manager, player)

    loop.run()


if __name__ == '__main__':
    main()
