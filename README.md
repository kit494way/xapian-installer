# xapian-installer

Installer of xapian-core and xapian-bindings for Python.

Xapian-core and xapian-bindings for Python are installed in the directory ${HOME}/xapian.

Only supports Python 3.6+.
Python environments created by `pyenv local` are not supprted.
Use venv, virtualenv or pyenv shell.

## Usage

Download the script and execute

```sh
$ curl -sS https://raw.githubusercontent.com/kit494way/xapian-installer/master/install.sh -o install.sh
$ chmod +x install.sh
$ ./install.sh
```

You can also execute with a version to install.

```sh
$ ./install.sh ${xapian_version}
```
