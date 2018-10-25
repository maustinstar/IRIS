__author__ = "Max S. Zuo"

import cv2
import numpy as np
import urllib2
import random
import sys
import argparse

"""
You should pass the following parameters:

[filepath to imagenet url links txt] [filepath to data.npy (opt)] [filepath to label.npy (opt)]

"""

#Set argument requirements
parser = argparse.ArgumentParser()
parser.add_argument("-df", "--datafile", type=str, help="set filepath to data.npy")
parser.add_argument("-lf", "--labelfile", type=str, help="set filepath to label.npy")
parser.add_argument("-l", "--load", action="store_true", help="when selected, will load data.npy, label.npy")
parser.add_argument("-v", "--verbose", type=int, choices=[0, 1, 2], help="select how much output is received")
parser.add_argument("-u", "--url", type=int, help="set url to begin at")
parser.add_argument("url_text_path", type=str)

#Set default values
data = []					#used to store data
label = []					#used to store labels
dataFile = "data.npy"		#used for saving & loading previous data
labelFile = "label.npy"		#used for saving & loading previous labels
verbose = 1					#used to set print settings
threshold = -1				#used to start at a different index of urls
count = 0					#used to keep track of how many urls it has already read

def readImage(url):
	resp = urllib2.urlopen(url, timeout=3)
	img = np.asarray(bytearray(resp.read()), dtype="uint8")
	img = cv2.imdecode(img, cv2.IMREAD_COLOR)
	return np.asarray(img)

if __name__ == "__main__":
	#Receive/Parse arguments
	args = parser.parse_args()

	f = open(args.url_text_path)
	if args.verbose != None:
		#Set verbosity
		verbose = args.verbose
		print "verbosity:", verbose
	arg = args.datafile
	if arg != None:
		#Configure filepath to data.npy
		dataFile = arg
		if verbose > 1:
			print "Set filepath for \"data.npy\" to:\t" + dataFile
	arg = args.labelfile
	if arg != None:
		#Configure filepath to label.npy
		labelFile = arg
		if verbose > 1:
			print "Set filepath for \"label.npy\" to:\t" + labelFile
	if args.load:
		#Configure data[] and label[]
		data = np.load(dataFile)
		label = np.load(labelFile)
		if verbose > 0:
			print "Done loading all the previously retrieved values"

	#For detecting and removing unavailable flickr images
	unavailable = readImage("https://s.yimg.com/pw/images/en-us/photo_unavailable.png")

	for line in f:
		
		count += 1

		#start after url count reaches threshold and read only every 50 images (ImageNet is too large :D)
		if count < threshold or count % 50 != 0: continue

		if count % 200 == 0:
			if verbose > 0:
				print "#\n#\n#\tSaved", len(data), "images to " + dataFile + "\n#\n#\n"
			if verbose > 1:
				print "Script has looked at", count, "images."
			record = open("record.txt", 'w')
			record.writelines(str(count) + "\n")
			record.close()

		if len(data) != len(label):
			raise Exception("Error: len(data) differs from len(label)")
		try:
			#read in the image and get its dimensions
			img = readImage(line.split("\t")[1].split('\n')[0])
			img = np.asarray(img)
			x, y, _ = (img.shape)

			#If the image is the unavailable image, do not add to data
			if (x/float(y) == float(unavailable.shape[0])/unavailable.shape[1]
				and np.allclose(unavailable, img)):
				continue

			#if the image is too small for our purposes, do not add to data
			if x < 512 or y < 512:
				continue

			#take snapshots of the image - data augmentation
			for i in xrange(8):
				minimumx = random.randint(0, min(x, y) - 512)
				minimumy = random.randint(0, min(x, y) - 512)

				HR = img[minimumy:minimumy + 512, minimumx: minimumx + 512]
				label.append(HR)		#add the full resolution crop to our labelset
				LR = cv2.resize(HR, (0,0), fx=0.5, fy=0.5)
				data.append(LR)			#add the low resolution crop to our dataset

		except Exception, e:
			if verbose > 1:
				print "Exception... ", e
			pass
		finally:
			#save our progress

			np.save(dataFile, np.array(data))
			np.save(labelFile, np.array(label))
