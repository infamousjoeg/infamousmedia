# Blue Dream Cinema

Automated deployment for media automation.

## Containers

#### Transmission

This is used to download media via Torrent network.  Can be routed through OpenVPN, if desired.

#### Plex Media Server

This is what is hosting all media internally and externally.  Also, takes care of transcoding server-side.

#### Radarr

A fork of Sonarr that I'm using for movies.  It is similar to Couch Potato, which I've preferred in the past.  This time around, Radarr is far more developed and better.  Also, works well with Jackett.

#### Sonarr

This is being used the same as Radarr, but for TV Shows.  It is similar to SickRage/SickBeard.

#### Jackett

This is my centralized indexer that Radarr and Sonarr both use for index searches.  It pulls in RSS feeds from private, semi-private, and public Torrent websites and allows both Radarr and Sonarr to easily search them while giving you the control you want over them and what they bring in.

#### Ombi

I got tired of people texting or Slacking me what they want.  Ombi is what I use as a "marketplace" for friends to request TV Shows and Movies through.  After approval by an admin or power user, it kicks in the automation with Sonarr or Radarr to take it from there.

#### NGINX

I use NGINX as a reverse proxy for Ombi so that I can serve it externally.

## System Specifications

* Ubuntu 16.04 or 18.04 - _This was tested on 18.04_

## Pre-Requisites

These are not required and will be checked/installed during deployment.

* Docker CE
* Docker-Compose

## Deployment

1. Modify `bootstrap.env` to match the variables for your environment.
2. Modify `nginx.conf` to match your environment network settings.
3. `$ ./0-deploy.sh`