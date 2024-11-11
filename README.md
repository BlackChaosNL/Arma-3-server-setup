# Arma 3 server setup using LinuxGSM

## Linux warning

I would like to preface this guide by saying that, if you do not have experience administering a linux server, there is other alternatives to this guide. See: https://apexminecrafthosting.com/games/arma-server-hosting/.

## Setup 

Setting up an ARMA 3 server using Docker on a Linux system provides a scalable and efficient way to host your gaming server, leveraging containerization technology. This method ensures your server remains isolated, portable, and easy to manage or update. Whether you're keen on providing a seamless multiplayer experience or exploring custom mods and scenarios, Docker offers flexibility and power without the overhead of traditional virtual machines.

In this guide, we will walk you through the process of setting up an ARMA 3 server in a containerized environment using Docker. We will cover everything from preparing your Linux system, ensuring it has the necessary dependencies, to pulling a suitable ARMA 3 server image, configuring your server settings, and finally, launching and managing your server container. By the end of this tutorial, you'll have a robust, efficient server setup, ready to host exciting ARMA 3 missions for your community.

Setting up container tools like Docker on an Ubuntu 24.04 server involves a series of steps. Read further for those steps.

### Installing Docker on Ubuntu 24.04 server

Update Package Information: Begin by updating your package index to ensure you have the latest software:
```bash
sudo apt update
```

Install Required Packages: Install the necessary packages to allow apt to use HTTPS:
```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

Add Docker’s Official GPG Key: Download and add Docker's GPG key to confirm the integrity of the packages:
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

Add Docker Repository: Add the Docker repository to your system:
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker: Update the package database again and install Docker:
```bash
sudo apt update
sudo apt install docker-ce
```

Verify Docker Installation: Check if Docker is installed correctly by running:
```bash
sudo systemctl status docker
```

Once both Docker is installed, you can choose to start enabling Docker to run at boot:
```bash
sudo systemctl enable docker
```

Download Docker Compose:

Check the latest version on the GitHub releases page, then replace v2.X.X in the command below:
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.X.X/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Apply executable permissions:
```bash
sudo chmod +x /usr/local/bin/docker-compose
```

Verify installation:
```bash
docker-compose --version
```

## Setting up your first server 

> [!WARNING]
>
> * You will need to create a new Steam account to download the ARMA 3 Server files. 
> * You will also need an account with ARMA 3 purchased, to download mods, if you need them.

> [!NOTE]
> Make sure the follow ports are open! 
>
> 

### Getting started

In the previous step you installed docker and docker compose. To get started we should name our work folder:
```bash
mkdir -p ~/docker/arma3-config/serverfiles # This is required for map persistance.
```

> [!NOTE]
> Always double check downloaded files! 

After you've created these folders, we can get started on downloading our `docker-compose.yml` file under the current repositories `executables` folder. Place your `docker-compose.yml` under `~/docker`.

### Setting up the ARMA 3 server

Once you have placed your `docker-compose.yml` into the docker folder, we'll do the following:

```bash
cd ~/docker && docker-compose up -d
```

Once the docker image has gone online you can `exec` into the new running LinuxGSM container named `arma3-server`:

```bash
docker exec -it arma3-server /bin/bash
```

You will end up with a prompt like the following:

```bash
<user>@<container_id>:/app#
```

Then you need to move to the LinuxGSM folder to set the new steam account:

```bash
cd /app/lgsm/config-lgsm/arma3server
```

Use your favorite editor to edit `arma3server.cfg` and add the following (After Newly created steam account):

```conf
##################################
####### Instance Settings ########
##################################
# PLACE INSTANCE SETTINGS HERE
## These settings will apply to a specific instance.
# Newly created steam account that does not have steam guard enabled:
steamuser=""
steampass=""

# Set mods:
mods=""
```

After setting the `arma3server.cfg`, we need to disable `-autoinit` from the startup to enable us to set the parameters when selecting a mission (Use your favorite editor!):

```bash
cd /app/lgsm/config-default/config-lgsm/arma3server && nano _default.cfg
```

Find and remove `-autoinit` from your `startparameters=`

```bash
startparameters="-ip=${ip} -port=${port} -cfg=${networkcfgfullpath} -config=${servercfgfullpath} -mod=${mods} -servermod=${servermods} -bepath=${bepath} -autoinit -loadmissiontomemory"
```

Once you've removed the `autoinit`, we can start altering the name and admin password for the server:

```bash
cd /app/serverfiles/cfg && nano arma3server.server.cfg
```

And change the existing values: 

```conf
// ****************************************************************************
//                                                                            *
//     Arma 3 - server.cfg                                                    *
//     Version 060117                                                         *
//                                                                            *
// ****************************************************************************

// ArmA 3 Server Config File
//
// More info about parameters:
// https://community.bistudio.com/wiki/server.cfg


// GENERAL SETTINGS

// Hostname for server.
hostname = "My awesome server";

// Server password - for private servers.
password = "";

// Admin Password
passwordAdmin = "My awesome admin password";

// Auto-admin
admins[] = {"<UID>"};

// Server Slots
maxPlayers = 30;

// Logfile
logFile = "arma3server.log";
```

After you've changed the items you want to change, save the .cfg file and type:

```bash
exit
```

And restart your docker image! You should now have a running server with the base software! 

### Adding mods

Make sure your server is up and running.

```bash
cd ~/docker && docker-compose up -d
```

Once the docker image has gone online you can `exec` into the new running LinuxGSM container named `arma3-server`:

```bash
docker exec -it arma3-server /bin/bash
```

You will end up with a prompt like the following:

```bash
<user>@<container_id>:/app#
```

Move to the following directory:

```bash
cd /app/serverfiles
```

And create a folder called `mods`: 

```bash
mkdir ./mods && cd ./mods
```

Find the `install_mods.sh` in the `executables` folder and use the `raw` view of github to show the file and download it with `curl`. After downloading we make it into an executable.

```bash
curl -L -O <link> && chmod +x ./install_mods.sh
```

Use your favorite editor to change the modlist and the names of the mods and add your personal steam account:

```bash
nano install_mods.sh
```

> [!NOTE]
> Use https://steamworkshopdownloader.io to get the Mod IDs!

> [!WARNING]
> * Always start a mod name with an @, for example `@antistasi`
> * Use spaces inbetween MOD_NAMES=("@antistasi" "@Mod2") and MODS=(2867537125 123)

Change the following config items :

```conf
STEAM_ACCT_USERNAME="{steam account with ARMA 3 BOUGHT!}"

# Fill these two arrays with the mods of choosing. Make sure the mod names are correct.
MOD_NAMES=("@antistasi")
MODS=(2867537125)
```

Once you've setup the install_mods.sh script, execute it:

```bash
./install_mods.sh
```

And login to the steamcmd when prompted.

When the mods downloads are done, add the mods you've downloaded to your server:

You need to move to the LinuxGSM folder:

```bash
cd /app/lgsm/config-lgsm/arma3server
```

> [!NOTE]
> The mod downloader hasn't been made to automatically add mods to the instance settings. The author would like to make it automatic in the future.

> [!NOTE]
> Add your mods in this format: `mods="mods/@antistasi\;"`.
> Always make sure to escape the `;`!

Use your favorite editor to edit `arma3server.cfg` and add path for your mods in `mods=""`:

```conf
##################################
####### Instance Settings ########
##################################
# PLACE INSTANCE SETTINGS HERE
## These settings will apply to a specific instance.
# Newly created steam account that does not have steam guard enabled:
steamuser=""
steampass=""

# Set mods:
mods=""
```

Once you've done this, please restart your server, and it should show that you have mods.

## Thanks for reading!

I am open to pull requests for questions and improvements: https://github.com/BlackChaosNL/Arma-3-server-setup