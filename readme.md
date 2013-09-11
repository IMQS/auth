IMQS Authentication Builder
===========================

This is an umbrella project to host the IMQS authentication/authorization system.

We use git sub-modules to reference the dependencies that are available via git.

Some of the dependencies are available only via mercurial. We make copies of these
source files, and store them verbatim. One could also use git-hg, but we choose not
to, so that our development/CI environment has one less tool that we need to worry
about.

## Building

Make sure you have all submodules cloned. A full clone from scratch would look like this:

	git clone git@github.com:IMQS/auth.git
	cd auth
	git submodule init
	git submodule update

To build imqsauth.exe, run

	env
	go install github.com/IMQS/imqsauth

The 'env' script sets your only GOPATH to be the current directory,
which forces the build to happen right here. If you're on Unix, then
you'll have to do `export GOPATH=$PWD` instead of `env`.

You should now have `bin/imqsauth.exe`

## Testing
Look inside imqs-build.rb to see the various tests that are run by the CI system.

## Running
To run imqsauth and create a local postgres database, do

	bin\imqsauth -c example-local.conf createdb

You will need to have the appropriate postgres login setup on your database. See the 
`example-local.conf` file for those details.

Next, reset the authorization groups 'admin' and 'enabled'

	bin\imqsauth -c example-local.conf resetauthgroups

Create a user called 'root'

	bin\imqsauth -c example-local.conf createuser root PASSWORD

Grant the 'root' user 'admin' and 'enabled' rights

	bin\imqsauth -c example-local.conf permgroupadd root admin
	bin\imqsauth -c example-local.conf permgroupadd root enabled

To create a regular user, you would do the same thing,
except leave out the `permgroupadd root admin` step.

To run the server:

	bin\imqsauth -c example-local.conf run

## Updating the git dependencies
All git-based dependencies use the regular git sub-module mechanism, so for example
if you want to update the `lib\pq` library, you do

	cd src\github.com\lib\pq
	git pull
	cd ..\..\..\..
	git add src\github.com\lib\pq
	git commit -m "Updated lib/pq"

## Updating the Mercurial dependencies
To update the mercurial dependencies, run

	env
	rmdir /s /q src\code.google.com
	go get code.google.com/p/go.crypto  
	go get code.google.com/p/winsvc
	rmdir /s /q src\code.google.com\p\go.crypto\.hg
	rmdir /s /q src\code.google.com\p\winsvc\.hg

The commands are illustrated here verbatim instead of in a batch file, so that you
are aware of exactly what you're doing. Since one does not need to update these
dependencies often, this is probably OK.