IMQS Authentication Builder
===========================

This is an umbrella project to host the IMQS authentication/authorization system.

All of the source code is stored inside this repo verbatim. The canonical source
control locations of the components should be obvious by browing the 'src' directory.

Forking the source code from the canonical repositories into this umbrella repository
is an unfortunate result of the 'go' tool having no way to express repository versions in 
import dependencies.

Hopefully once repository versions are expressible in Go's import tool, we can do away with
this gratuitous forkage.

## Building
To build imqsauth.exe, run

	env
	go install github.com/IMQS/imqsauth

The 'env' script sets your only GOPATH to be the current directory,
which forces the build to happen right here.

You should now have `bin/imqsauth.exe`

To run it and create a local postgres database, do

	bin\imqsauth -c example-local.conf createdb

You will need to have the appropriate postgres login setup on your database. See the 
`example-local.conf` file for those details.

Next, reset the imqsadmin user

	bin\imqsauth -c example-local.conf resetadmin

This will create the imqsadmin user

..... I see now that we're going to have to add the ability to grant admin rights
to any user, since we don't want to have to ask every client to add a special
'imqsadmin' user to their Active Directory. We should be able to promote any
user of our choosing to admin role, via the console.