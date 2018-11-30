"""
Simple code designed to allow the usage of git commands from within python files easily.
Copyright Max Zuo 2018
"""

import os
import sys

def commit(message="", auto_push=True):
	os.system('git commit -m "' + message + '"')
	if (auto_push): push()

def add(filename):
	os.system('git add ' + filename)


def config(username, password, repo_url):
	os.system('git config remote.origin.url https://{}:{}@{}'.format(username, password, repo_url.split("//")[1]))

def push():
	os.system('git push -u')

if __name__ == "__main__":
	if len(sys.argv) <= 1:
		sys.exit(1)
	message = sys.argv[1]
	commit(message)
