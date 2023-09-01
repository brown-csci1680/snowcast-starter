# CS1680 Snowcast Dissector

This directory contains a dissector (also known as a decoder) for the Snowcast
protocol implementation for CS168.

## Installation Instructions

The dissector is provided as a Lua script in this directory.  For security
reasons, Wireshark does not run Lua scripts when run as root--therefore, you
must ensure that you are using Wireshark as your local user, not with root or
sudo.  To run wireshark as a standard user, make sure your user is added to the
`wireshark` group.  If you are using the provided VM, the the vagrant user is
already in the wireshark group.  However, if you are running Wireshark on your
own system, you will need to configure this yourself.  

Once you have Wireshark running as your user.  Add the dissector to Wireshark,
by copying the script into your plugins directory.

To do this:

 1. Run wireshark as your user (**not with root or sudo**).  
 2. Open Wireshark's Help menu and select "About Wireshark".
 3. In the folders tab, find the entry "Personal Lua Plugins". For example:
    `~/.config/wireshark/plugins`
 4. Copy the script to this directory (if it doesn't exist, create it) and
    restart wireshark
 5. Open the "About Wireshark" window again and look in the Plugins tab. You
    should now see cs168_snowcast.lua in the list of plugins.

## Using the dissector

_To make sure your dissector is working, please run the Snowcast reference
binaries_

Wireshark will automatically invoke the Snowcast dissector when it encounters a
TCP packets on port 1680. This means that if you start the Snowcast server on
port 1680, TCP packets on port 1680 will automatically be decoded as Snowcast
commands and replies.

To use the Snowcast dissector with other port numbers we can instruct wireshark
to interpret TCP packets on a given port as Snowcast commands and responses.
We can tell wireshark to do this using Wireshark's "User-Specified Decodes"
feature:

1. Run your binaries and to start capturing packets. You should be capturing
   packets on the loopback interface.
2. Find a TCP packet related to this assignment and select it. These packets
   will have a destination and source port number. One of these port numbers
   should be the port number you selected when starting up the Snowcast server.
3. Right click on the TCP packet and select "Decode As..."
4. Double click "(none)" under "current" and select CS168SNOWCAST.

Wireshark should now update and decode the TCP packets with your specified port
number as Snowcast commands and replies.

If you do not see Snowcast commands and replies, check your "Decode As..." rule
from step 4. If you still do not see Snowcast commands and replies, make sure
that the plugin is loaded in the help menu.

### Disclaimer

The steps listed above will invoke the decoder only on a single TCP port. You
should repeat the steps above each time you change TCP ports

## Feedback

If you have questions or encounter any issues with the decoder, please post on
EdStem or see the course staff for help.
