require "fileutils"

out_dir = "../out"

oldGoPath = ENV["GOPATH"]
ENV["GOPATH"] = Dir.pwd

at_exit {
	ENV["GOPATH"] = oldGoPath
}

def exec_or_die( cmd, current_dir = nil )
	orgDir = Dir.pwd
	Dir.chdir(current_dir) if current_dir != nil
	
	res = `#{cmd}`
	
	Dir.chdir(orgDir)

	if $?.exitstatus != 0
		print(res)
		exit(false)
	end
end

case ARGV[0]
	when "build" then
		# 'build' exists solely for CI integration. We can't use "prepare" in that case, because "../out/bin" doesn't exist on a CI build.
		exec_or_die( "go install github.com/IMQS/imqsauth" )
	when "prepare" then
		exec_or_die( "go install github.com/IMQS/imqsauth" )
		FileUtils.cp( "bin/imqsauth.exe", out_dir + '/bin/' )
	when "test_unit" then
		# The very first test that executes against the postgres backend must run with
		# just 1 CPU. This is to ensure that if migrations need to run, then they do so
		# before anything else runs.
		exec_or_die( "go test github.com/IMQS/authaus -test.cpu 1 -backend_postgres -run TestAuth" )

		# At present the tests behave no differently when run with -race and without,
		# but it's a likely thing to do in future. ie.. make some stress tests run only with -race off,
		# because -race uses 10x the memory and is 10x slower.
		exec_or_die( "go test -race github.com/IMQS/authaus -test.cpu 2 -run TestAuth" )
		exec_or_die( "go test -race github.com/IMQS/authaus -test.cpu 2 -backend_postgres -run TestAuth" )
        exec_or_die( "go test -race github.com/IMQS/authaus -test.cpu 2 -backend_ldap -run TestIntegratedLdap" )
		exec_or_die( "go test -race github.com/IMQS/imqsauth/imqsauth -test.cpu 2" )
		exec_or_die( "go test github.com/IMQS/authaus -test.cpu 2 -run TestAuth" )
		exec_or_die( "go test github.com/IMQS/authaus -test.cpu 2 -backend_postgres -run TestAuth" )
        exec_or_die( "go test github.com/IMQS/authaus -test.cpu 2 -backend_ldap -run TestIntegratedLdap" )
		exec_or_die( "go test github.com/IMQS/imqsauth/imqsauth -test.cpu 2" )
		exec_or_die( "ruby src/github.com/IMQS/imqsauth/resttest.rb" )
	when "test_integration" then
		# TODO: try logging into our IMQS domain (or whatever's appropriate for a CI box)
end

