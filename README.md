# IRIS

IRIS *(Intelligent Resolution Imaging System)* uses a mobile-optimized neural network to increase the resolution of photos by synthesizing probable details. The iOS framefork is responsible for decomposing large images into smaller patches for the network to process. The model was trained on approximately 20,000 images from the internet using Keras in Python.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

* [XCode 10.0+](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)
* (device or simulator) iOS 12.0+

### Installation

* Clone this repository.

## Running

Open IRIS.xcworkspace in XCode, and sign in with a Developer account.

### App

* Select "IRIS iOS" target to run on simulator or device

### App Extension

* Select "IRIS Extension" target to run on simulator or device
* Choose to launch in "Photos"
* Preview a photo and select "edit"
* Press the "(…)" icon in the lower right-hand corner
* Choose App Extension "IRIS iOS"

## Authors

* **Michael Verges** - *iOS Framework*
* **Max Zuo** - *CoreML Model/Keras Model*

## Future Steps
* Max
  * will continue to refine/train the CNN model for 200x200 ---> 200x200
  * develop new neural network for 256x256 ---> 512x512 and 512x512 ---> 1024x1024 for experimentation
  * develop new "4x zoom" GAN
  * develop new feature "Organic Superresolution"
  * develop new feature "Night Vision"
* Michael
  * decrease memory required to operate the IRIS model
  * increase speed and efficiency of Iris
  * expand IRIS framework to be able to accept new models rapidly
  * create Camera UI for IRIS app

## Acknowledgements

* [HackGT](https://hack.gt) - *a 36 hour MLH competition hosted by Georgia Institute of Technology*
