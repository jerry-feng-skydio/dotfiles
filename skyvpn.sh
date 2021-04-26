#!/bin/sh

## Need to install 1password (op) and json commandline tool (jq)
## Get op here: https://support.1password.com/command-line-getting-started/
# sudo apt-get install jq

# Ensure fresh sudo timestamp
sudo -v

## Initial set up for 1password, user will need to provide secret key and auth code 
# op signin skydio.1password.com jerry.feng@skydio.com

# Signin, with shorthand
eval $(op signin skydio)

# I've made a login item called "OpenVpn" in my personal vault
VPN_CONFIG="~/pfSense-UDP4-1194-config.ovpn"
VPN_USER=$(op get item OpenVpn | jq -r '.details.fields[] | select(.designation=="username").value')
VPN_PASS=$(op get item OpenVpn | jq -r '.details.fields[] | select(.designation=="password").value')

if [ ! -z $VPN_USER ]
then
    echo "Logging into vpn for user $VPN_USER"
    sudo -b bash -c 'openvpn --config ~/pfSense-UDP4-1194-config.ovpn --daemon --auth-user-pass <(echo -e "'"$VPN_USER"'\n'"$VPN_PASS"'")'
else
    echo "Could not get credentials from 1password?"
fi
