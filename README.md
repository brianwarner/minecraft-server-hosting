# Server hosting

This repo contains scripts and instructions for self-hosting a Minecraft Java Edition server.  It has been merged together from a variety of sources, with a big thanks in particular to the person who originally wrote the systemd script (I think it was [@agowa883](https://github.com/agowa338/MinecraftSystemdUnit/)), but there are also many others out there.

One thing to note about this setup is that it doesn't use `screen`, and instead uses [mcrcon](https://github.com/Tiiffi/mcrcon).  This way you can log in using the [manage.sh](manage.sh) script.

## What can I do with this?

These instructions help you run a (free) self-hosted multiplayer Minecraft server.  Please note that these instructions are for [Minecraft Java Edition](https://www.minecraft.net/en-us/store/minecraft-java-edition/) only.  At the time of writing, there are no options to self-host Minecraft Bedrock Edition.

You would want to follow these instructions if you want to set up a private Minecraft server for you or your kids and their friends.

## Prerequisites

It's fun (and sometimes reassuring) to run your own server, but there are a few things you need to know up front to make use of these instructions.

1. You need a working knowledge of command-line Linux (these instructions are geared toward Debian)
1. You need to be able to open up ports in your firewall
1. You need root access to your server
1. You either need a static IP, or Dynamic DNS

You probably want to run your own server, as Minecraft can be CPU and memory intensive.

## Setup

### Set up a website for the parents

It's a lot easier to get people involved if you can point them to a how-to.  I wrote my own and host it from the same system that runs the Minecraft server.

It helps answer the question of what they need to buy, and lays down some ground rules.

[Here's a basic site](website.html) you can reuse.

### Set up the server to host the game

In these instructions I'm assuming you're running Debian.  They probably work for other variants of Linux which run systemd.

#### Configure the server

First, install Java:

```
sudo apt-get install default-jre-headless
```

 
When you're done, running `java -version` should give you something like this:

```
openjdk version "..." 202x-xx-xx
OpenJDK Runtime Environment (build ...)
OpenJDK 64-Bit Server VM (build ..., mixed mode, sharing)
```

#### Create a separate Minecraft user

On the server, run: 

`$ sudo adduser --system --shell /bin/bash --home /opt/minecraft --group minecraft`

#### Get the (free) Minecraft Server .jar

Download the server from [https://www.minecraft.net/en-us/download/server/](https://www.minecraft.net/en-us/download/server/).

Move the downloaded `server.jar` file to `/opt/minecraft/server/server.jar`

```
$ sudo mkdir /opt/minecraft/server
$ sudo mv server.jar /opt/minecraft/server/`
```

#### Fix up the permissions

Make sure permissions are ok:

`$ sudo chown -R minecraft.minecraft /opt/minecraft`

#### Switch to the minecraft user

If you start the server as `root` but then later try to run it as the `minecraft` user, it will give you hard-to-diagnose errors (personal experience).  Switch to the `minecraft` user for the next part:

`$ sudo su minecraft`

#### Generate the game files

You are going to temporarily start the server so that you are prompted to accept the EULA, and so the game can create the necessary config files:

```
$ cd /opt/minecraft/server
$ java -Xmx2048M -Xms256M -jar server.jar nogui
```

It will say you haven't agreed to the EULA.  Edit `eula.txt` (which now appears in the directory with `server.jar`) and set `eula=true`, and then try again.

Once you've accepted the EULA, the server should start.  When you see a message that includes `[Server thread/INFO]: Done`, you'll know you've done it right.

At this point, type `stop` to shut it down gracefully.  You should now have a directory full of files, including `server.properties`, `whitelist.json`, `banned-ips.json`, `banned-players.json`, and `ops.json`.

#### Edit `server.properties`

In your text editor, open `server.properties`.  This is where you choose the difficulty level, the game mode, etc.  Edit [whatever settings you like](https://minecraft.gamepedia.com/Server.properties).  However, please pay attention to these ones:

```
white-list=true
pvp=false				# your call on this, but this definitely helps keep the peace...
server-ip=<your server's IP> # Change this to match your server's IP
server-port=<your game's port, unique for each game> # Change this from the default
enable-rcon=true
rcon.port=<a unique port for each game, NOT same as server-port> # Change this from the default, but different from server-port
rcon.password=<an admin password you choose, same for each game>
```

#### Set up your systemd file

Copy [minecraft@.service](minecraft\@.service) into `/etc/systemd/system/`

#### Install mcrcon

`mcrcon` is a utility for managing Minecraft servers.  Here's how you install it:

```
$ sudo apt-get install gcc git
$ cd /opt/minecraft
$ git clone https://github.com/Tiiffi/mcrcon
$ cd mcrcon
$ make
$ sudo make install
```

#### Configure mcrcon

Copy [mcrcon.conf](mcrcon.conf) to `/etc/mcrcon.conf`.

Note that <serverdirectory> is case sensitive.  So, for example, if you've set up a server in `/opt/minecraft/server` and `/opt/minecraft/server/server.properties` includes `rcon.port=26002`, your `/etc/mcrcon.conf` would need this line: `server=26002`

#### Start the service

At this point, you should be ready to start the service.

```
$ sudo systemctl start minecraft@server
```

#### Check if it's running

Remember when you set `server-ip` and `server-port` in `server.properties`?  You need those now.

Start up Minecraft Java Edition, go to Multiplayer and add a new server.  The address will be: `<server-ip>:<server-port>` (matching what you set in `server.properties` for that game).

If you can connect, congratulations, your server is running!  Now you need to make it available to the rest of the world.

#### Make it a permanent service

To make it a permanent service that restarts upon failure, run: `systemctl enable minecraft@server`.

#### Put it on a schedule

Yeah, seriously.  Do this so your kids aren't waking up at the crack of dawn to play.  It seriously works, they'll stay in bed longer if they know it won't even work.

`$ sudo crontab -e`

Copy and paste these lines into the crontab:

```
0 8 * * * systemctl start minecraft@server
0 20 * * * systemctl stop minecraft@server
```

Save the new crontab (and your sanity in the process).

#### Set up dynamic DNS

Use whatever service you like to set this.  You'll need to send this to parents so they can configure their client.

#### Open a port in your firewall (unless your players are all on your network)

Open the port which matches `server-port` in `server.properties` and point it to your Minecraft server's IP.  You don't (and shouldn't) open the port used for `rcon.port`.

#### Add the `manage.sh` script to the game directory

Copy [manage.sh](manage.sh) into your game directory (e.g., `/opt/minecraft/server`).  When you want to manage a running game without logging in, you can do this:

```
$ cd /opt/minecraft/server
$ ./manage.sh
```

This allows you to [run commands](https://minecraft.gamepedia.com/index.php?title=Commands#List_and_summary_of_commands).  At the very least, you should make your own player operator:

```
> op <yourplayername>
> Q
```

## What if I want to run multiple servers?

The beauty of this approach is that it scales easily.  To add a second server, do the following:

1. Make a copy of your server:

   `cp -r /opt/minecraft/server /opt/minecraft/second_server`

1. Delete the game directory from the copy. It's in `server.properties`, look for `level-name=` and delete that subdirectory. This causes the server to generate a new game upon restart.

1. Edit `server-port` and `rcon.port` in `/opt/minecraft/second_server/server.properties` to be something different from that in `server`.

1. Add the new values into `/etc/mcrcon.conf` (e.g., `second_server=<rcon.port>`)

1. Start the new server:

   `sudo systemctl start minecraft@second_server`

1. Ensure the new server starts when the system starts:

   `sudo systemctl enable minecraft@second_server`

1. Add another firewall rule opening the new `server-port`

If you want to keep your operators, players, and banned players the same across the games, you can symlink them.

For example, if you have `/opt/minecraft/server` and `/opt/minecraft/second_server`:

```
$ sudo systemctl stop minecraft@second_server
$ cd /opt/minecraft/second_server
$ rm ops.json whitelist.json banned-players.json banned-ips.json
$ ln -s ../server/ops.json
$ ln -s ../server/whitelist.json
$ ln -s ../server/banned-players.json
$ ln -s ../server/banned-ips.json
$ sudo systemctl start minecraft@second_server
```

When you change these files, you'll need to restart the servers with symlink'd configs so they pick up the change.

## Other tips

### Make nightly backups

When you shut down the server for the night, back up the game files. Young kids may not fully understand multiplayer etiquette yet, and you might want the ability to roll back to a prior day's version if someone is griefed badly.

### Make a PDF you can send to parents with the current connection info

When a parent emails you with their username requesting access to the server, you'll probably want to respond with a PDF (with screenshots) showing how to add the servers you've configured.  Remember they'll need to know your dynamic DNS domain and the port numbers.

## I found an error...

If you found an error in the above instructions, please open an issue or a PR.  If you have a different set of instructions for a different distro or OS, feel free to PR them as a separate file.

If you run into a problem you can't solve, please feel free to open an Issue.  I can't promise I can diagnose it, but maybe someone else can.