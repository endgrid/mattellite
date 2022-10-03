![Mattellite](https://user-images.githubusercontent.com/104172903/193669747-a0ab9855-4a38-4901-b46c-5ece9d23dfd0.png)
# mattellite
Network change monitoring watchtower (plug-and-play nmap ndiff result email alerting)

Monitoring large networks is difficult. Locating and ensuring the correct configuration of devices on those networks is a daunting task.
Mattellite is a simple, one script program designed to use minimal resources and grant maximum network visibility. I built it to run on an Ubuntu VM but you could also put it on a Pi to take advantage of physical access.

## Step 1: [Configuring Gmail as a Sendmail email relay](https://linuxconfig.org/configuring-gmail-as-sendmail-email-relay)
I recommend the above tutorial by Luke Reynolds for setting up a mail relay.
You will need to install sendmail:
`sudo apt install sendmail mailutils sendmail-bin`
Switch to root:
`su`
Create the gmail configuration file:
`#mkdir -m 700 /etc/mail/authinfo/
cd /etc/mail/authinfo/
nano gmail-auth
AuthInfo: "U:YOUR USER" "I:YOUR GMAIL EMAIL ADDRESS" "P:YOUR PASSWORD"`
Create a hashmap for the auth file:
`makemap hash gmail-auth < gmail-auth`
Configure sendmail:
`nano /etc/mail/sendmail.mc`



divert(-1)dnl
#-----------------------------------------------------------------------------
# $Sendmail: debproto.mc,v 8.15.2 2021-12-09 00:18:01 cowboy Exp $
#
# Copyright (c) 1998-2010 Richard Nelson.  All Rights Reserved.
#
# cf/debian/sendmail.mc.  Generated from sendmail.mc.in by configure.
#
# sendmail.mc prototype config file for building Sendmail 8.15.2
#
# Note: the .in file supports 8.15.0 - 9.0.0, but the generated
#       file is customized to the version noted above.
#
# This file is used to configure Sendmail for use with Debian systems.
#
# If you modify this file, you will have to regenerate /etc/mail/sendmail.cf
# by running this file through the m4 preprocessor via one of the following:
#       * make   (or make -C /etc/mail)
#       * sendmailconfig
#       * m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
# The first two options are preferred as they will also update other files
# that depend upon the contents of this file.
#
# The best documentation for this .mc file is:
# /usr/share/doc/sendmail-doc/cf.README.gz
#
#-----------------------------------------------------------------------------
divert(0)dnl
#
#   Copyright (c) 1998-2005 Richard Nelson.  All Rights Reserved.
#
#  This file is used to configure Sendmail for use with Debian systems.
#
define(`_USE_ETC_MAIL_')dnl
include(`/usr/share/sendmail/cf/m4/cf.m4')dnl
VERSIONID(`$Id: sendmail.mc, v 8.15.2-22ubuntu3 2021-12-09 00:18:01 cowboy Exp $')
OSTYPE(`debian')dnl
DOMAIN(`debian-mta')dnl
dnl # Items controlled by /etc/mail/sendmail.conf - DO NOT TOUCH HERE
undefine(`confHOST_STATUS_DIRECTORY')dnl        #DAEMON_HOSTSTATS=
dnl # Items controlled by /etc/mail/sendmail.conf - DO NOT TOUCH HERE
dnl #
dnl # General defines
dnl #
dnl # SAFE_FILE_ENV: [undefined] If set, sendmail will do a chroot()
dnl #   into this directory before writing files.
dnl #   If *all* your user accounts are under /home then use that
dnl #   instead - it will prevent any writes outside of /home !
dnl #   define(`confSAFE_FILE_ENV',             `')dnl
dnl #
dnl # Daemon options - restrict to servicing LOCALHOST ONLY !!!
dnl # Remove `, Addr=' clauses to receive from any interface
dnl # If you want to support IPv6, switch the commented/uncommentd lines
dnl #
FEATURE(`no_default_msa')dnl
dnl DAEMON_OPTIONS(`Family=inet6, Name=MTA-v6, Port=smtp, Addr=::1')dnl
DAEMON_OPTIONS(`Family=inet,  Name=MTA-v4, Port=smtp, Addr=127.0.0.1')dnl
dnl DAEMON_OPTIONS(`Family=inet6, Name=MSP-v6, Port=submission, M=Ea, Addr=::1')dnl
DAEMON_OPTIONS(`Family=inet,  Name=MSP-v4, Port=submission, M=Ea, Addr=127.0.0.1')dnl
dnl #
dnl # Be somewhat anal in what we allow
define(`confPRIVACY_FLAGS',dnl
`needmailhelo,needexpnhelo,needvrfyhelo,restrictqrun,restrictexpand,nobodyreturn,authwarnings')dnl
dnl #

dnl # Define connection throttling and window length
define(`confCONNECTION_RATE_THROTTLE', `15')dnl
define(`confCONNECTION_RATE_WINDOW_SIZE',`10m')dnl
dnl #
dnl # Features
dnl #
dnl # use /etc/mail/local-host-names
FEATURE(`use_cw_file')dnl
dnl #
dnl # The access db is the basis for most of sendmail's checking
FEATURE(`access_db', , `skip')dnl
dnl #
dnl # The greet_pause feature stops some automail bots - but check the
dnl # provided access db for details on excluding localhosts...
FEATURE(`greet_pause', `1000')dnl 1 seconds
dnl #
dnl # Delay_checks allows sender<->recipient checking
FEATURE(`delay_checks', `friend', `n')dnl
dnl #
dnl # If we get too many bad recipients, slow things down...
define(`confBAD_RCPT_THROTTLE',`3')dnl
dnl #
dnl # Stop connections that overflow our concurrent and time connection rates
FEATURE(`conncontrol', `nodelay', `terminate')dnl
FEATURE(`ratecontrol', `nodelay', `terminate')dnl
dnl #
dnl # If you're on a dialup link, you should enable this - so sendmail
dnl # will not bring up the link (it will queue mail for later)
dnl define(`confCON_EXPENSIVE',`True')dnl
dnl #
dnl # Dialup/LAN connection overrides
dnl #
include(`/etc/mail/m4/dialup.m4')dnl
include(`/etc/mail/m4/provider.m4')dnl
dnl #
dnl # Masquerading options
FEATURE(`always_add_domain')dnl
MASQUERADE_AS(`mattellite')dnl
FEATURE(`allmasquerade')dnl
FEATURE(`masquerade_envelope')dnl
dnl #
dnl # Default Mailer setup
MAILER_DEFINITIONS
define(`SMART_HOST',`[smtp.gmail.com]')dnl
define(`RELAY_MAILER_ARGS', `TCP $h 587')dnl
define(`ESMTP_MAILER_ARGS', `TCP $h 587')dnl
define(`confAUTH_OPTIONS', `A p')dnl
TRUST_AUTH_MECH(`EXTERNAL DIGEST-MD5 CRAM-MD5 LOGIN PLAIN')dnl
define(`confAUTH_MECHANISMS', `EXTERNAL GSSAPI DIGEST-MD5 CRAM-MD5 LOGIN PLAIN ')dnl
FEATURE(`authinfo', `hash -o /etc/mail/authinfo/gmail-auth.db')dnl
MAILER(`local')dnl
MAILER(`smtp')dnl



#!/bin/sh
date=`date +%F`
cd /root/scans
nmap -v -T4 -sn 192.168.0.0/24 -oX scan-$date.xml > /dev/null
if [ -e scan-prev.xml ] ; then
        ndiff -v scan-prev.xml scan-$date.xml > diff-$date
        echo -e "Network changes since last scan: \n$(cat diff-$date)" | mail ->
fi
mv -f scan-$date.xml scan-prev.xml
rm -f scan-2*
rm -f diff*
