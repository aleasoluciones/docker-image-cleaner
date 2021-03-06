# docker-image-cleaner [![Build Status](https://travis-ci.org/aebm/docker-image-cleaner.svg)](https://travis-ci.org/aebm/docker-image-cleaner)
From all the pulled docker images remove keep only the N most recent images pulled

## Installation
* Clone repo
* It is adviced to use a virtualenv
* To setup a virtualenv

  ```bash
  $ virtualenv --clear --always-copy VIRTUALENV_NAME
  ```

* Install dependencies

  ```bash
  $ VIRTUALENV_NAME/bin/pip install -r requirements.txt
  ```

* Run it with the same privileges as the docker client

  ```bash
  $ VIRTUALENV_NAME/bin/python di_cleaner.py --help
  ```
  
* Another way

  ```bash
  $ source VIRTUALENV_NAME/bin/activate
  $ ./di_cleaner --help
  ```

## Examples
* Run and show what images it is going to delete without deleting them

  ```bash
  $ VIRTUALENV_NAME/bin/python di_cleaner.py --verbose --noop
  ```
  
* Run with debug on

  ```bash
  $ VIRTUALENV_NAME/bin/python di_cleaner.py --debug
  ```
  
* Delete all images except the 10 most recent ones
  
  ```bash
  $ VIRTUALENV_NAME/bin/python di_cleaner.py --images-to-keep 10
  ```
  
* If you want to preserve the \<none\> images

  ```bash
  $ VIRTUALENV_NAME/bin/python di_cleaner.py --keep-none-images
  ```

## Mac OSX
Start up your docker-machine. 
You need to setup the environment of your docker-machine in your shell 

```bash
$ eval "$(docker-machine env default)"
```

Note, **default** is your virtual machine name

Now you can run all examples.
  
## Tests
Run
```bash
$ VIRTUALENV_NAME/bin/python -m unittest discover
```

## Use docker image

Build the image as ${IMAGE_NAME}
```
docker build  -t ${IMAGE_NAME} .
```

Execute the program connected to the host socket

```
docker run -v /var/run/docker.sock:/var/run/docker.sock --rm -it ${IMAGE_NAME} --help
```
