@echo off
rem This script is useful when checking out all of the dependencies of this project.
rem The idea is that you check out all the dependencies, and then use a diff/merge tool
rem such as Beyond Compare to synchronize the two directory trees.

setlocal
set GOPATH=%CD%\repositories_for_sync

rem This is the final node in the dependency graph, so you only need to 'go get' this.
go get github.com/IMQS/imqsauth

endlocal
