# Log-Messenger
An iOS instant messaging app (currently in progress) - written using Swift.

# Motivation

I was motivated to start this project because I always wondered if it were **possible** for **one** person to create an entire instant-messaging app, I am here to test that challenge (with support of close friends as well!)
    
# Getting Started**

**Pre-Requisites**

*Install the following components; they are required.*

- Install [Homebrew](https://brew.sh)

- Install [Carthage](https://github.com/Carthage/Carthage)

You also need Xcode Tools, which are automatically installed when Xcode is installed.

# Setting Up The Project

**Download the repository from GitHub**

`git clone https://github.com/Colourhood/Log-Messenger.git`

**Install app dependencies using Carthage**

`carthage update --platform iOS` *We only want to fetch dependencies for the iOS Platform, otherwise this could take a while*

**AWS SDK Credentials - Required to run project**

*Note:* These is very sensitive information that cannot and should not be shared due to security reasons, just like your SS#; do not share.

**Get Keys**
You must request and submit permissions from the REPO Owner in order to obtain the appropriate credentials to connect to the AWS SDK. Contact *andrei@colourhood.org* for more information.

**Setting up keys (if provided)**

`mkdir ~/.aws && cd ~/.aws && touch credentials.json && cat >> credentials.json [press enter; then paste the keys into the file; press enter; then press Control-D]`

We will creating a diretory called *.aws* in the users root directory and storing the AWS keys within a file called *credentials.json*

**Installing keys to the Xcode project**

1. Open the file with extension of `.xcodeproj`
2. Head over to `Build Phases` and select `Copy Bundle Resources`
3. We need to reference the local `credentials.json` from the last step
4. You may notice there is one file already linked; remove that file reference (otherwise the project won't run appropriately - those key references are from the original owner)
5. And select the `credentials.json` file created within */.aws* (You may have to do [Command-Shift-.] in order to reveal the hidden directories/files

# Run App

**Time to run the project**

There are three ways to do this:

Method #1 - Select `Product` then `Run`
Method #2 - Press [Command-R]
Method #2 - Within the Xcode IDE Select the 'play' button

# Installing New Dependencies (Carthage)

*If you are new to Carthage I recommend reading their documentation to installing new dependencies!*

[Carthage Documentation](https://github.com/Carthage/Carthage)

# License

Log-Messenger is released under the MIT License.


