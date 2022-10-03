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

`#mkdir -m 700 /etc/mail/authinfo/`

`cd /etc/mail/authinfo/`

`nano gmail-auth`

Paste the following:

`AuthInfo: "U:root" "I:YOUR GMAIL EMAIL ADDRESS" "P:YOUR PASSWORD"`

Create a hashmap for the auth file:

`makemap hash gmail-auth < gmail-auth`

Edit the sendmail.mc file:

`nano /etc/mail/sendmail.mc`

Update sendmail.mc with [this file](https://github.com/endgrid/mattellite/blob/main/sendmail.mc)

Rebuild sendmail:

`make -C /etc/mail`

Restart sendmail:

`systemctl restart sendmail`

## Step 2: [Install nmap and ndiff](https://nmap.org/)

`sudo apt-get install nmap`

`sudo apt-get install -y ndiff`

## Step 3: [mattellite.sh](https://github.com/endgrid/mattellite/blob/main/mattellite.sh)

If not still root, switch to root:

`su`

Navigate to root:

`cd root`

Make the scans directory:

`mkdir scans`

Create the mattellite bash script:

`touch mattellite.sh`

Edit the recipient email in [mattellite.sh](https://github.com/endgrid/mattellite/blob/main/mattellite.sh) and copy script:

`echo -e "Network changes since last scan: \n$(cat diff-$date)" | mail -s "$(date +%D) Network report" recipient@gmail.com`

`nano mattellite.sh`

Make the script executable:

`chmod +x /root/mattellite.sh`

## Step 4: Run baseline scan

Run baseline scan:

`bash /root/mattellite.sh`

## Step 5: Schedule cron job

If not still root, switch to root:

`su`

Open crontab:

`crontab -e`

Add cron job:

`0 5 * * * /root/mattellite.sh`

## Result:

If any devices have entered or left your network, the alert will look something like this:

<img width="514" alt="email" src="https://user-images.githubusercontent.com/104172903/193688529-a610e050-289f-45ce-a913-b9a5f8103687.png">

Newly discovered hosts can be manually scanned again to capture more information, or the nmap command in the mattellite.sh file can be edited to perform more intense scans each time. Removing `-sn` from the nmap command enables port scanning.
