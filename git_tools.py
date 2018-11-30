import os
import sys

def commit(message="", push=True):
	os.sys('git commit -m "' + message + '"')
	if (push): os.sys('git push -u')

def add(filename):
	os.sys('git add ' + filename)






if __name__ == "__main__":
	if len(sys.argv) <= 1:
		return
	message = sys.argv[1]
	commit(message)
