import os
import sys

def commit(message="", push=True):
	os.system('git commit -m "' + message + '"')
	if (push): os.system('git push -u')

def add(filename):
	os.system('git add ' + filename)


def config(username, password, repo_url):
	os.system('git config remote.origin.url https://{}:{}@{}'.format(username, password, repo_url.split("//")[1]))



if __name__ == "__main__":
	if len(sys.argv) <= 1:
		sys.exit(1)
	message = sys.argv[1]
	commit(message)
