# simplestore

The goal of this project is to have a multi-tenant storage service for projects.

I know things like mongo-db exist, but I would like to figure out if I can use
this as a base for a more extensive server-side app.

As I am learning Haskell as I'm doing this, this might not work out at all &
this project might fail miserably. Please don't consider using this in production
just yet. No guarantees whatsoever from my part regarding both functionality and
continuity.

# Install & build

As the current release of servant has a small - but rather critical for me -
bug, I'm using servant from the master - ! YAY ! -, so here are the install
instructions:

    $ git clone git@github.com:arealities/simplestore.git
    $ cd simplestore
    $ cabal sandbox init
    $ cabal install --only-dependencies
    $ cabal build

Windows tip: if you try to do this on windows, you might get an error message
saying `(g)cc` is missing. Install `MingW`, or if you have `msysgit`, just add
`c:\msysgit\bin` to your path:

    set PATH = c:\msysgit\bin;%PATH%

Also, if you use `GHC` on windows, get the latest installer from https://www.haskell.org/platform/windows.html, as the `chocolatey installer` is not up to date.

# Testing

    $ cabal run -- -h
    Preprocessing executable 'simplestore' for SimpleStore-0.0.1.0...
    Running simplestore...
    SimpleStorage by arealities.com

    Usage: simplestore.exe COMMAND
      A simple multi-tenant storage accessible over HTTP. Run with -h to view
      available commands

    Available options:
      -h,--help                Show this help text

    Available commands:
      server                   Start a webserver
      resetdb                  Reset the database
      mkuser                   Add one or more users
      rmuser                   Remove users
      passwd                   Change password for users

    $ cabal run -- resetdb -h
    Preprocessing executable 'simplestore' for SimpleStore-0.0.1.0...
    Running simplestore...
    Usage: simplestore.exe resetdb [-f|--force]
      Reset the database

    Available options:
      -f,--force               Force execution of the reset (required)

    $ cabal run -- resetdb
    Preprocessing executable 'simplestore' for SimpleStore-0.0.1.0...
    Running simplestore...
    Use the --force option if you want this to work

    $ cabal run -- resetdb -f
    Preprocessing executable 'simplestore' for SimpleStore-0.0.1.0...
    Running simplestore...
    database simplestore.db created.

    $ cabal run -- server &
    [1] 9392

    $ Preprocessing executable 'simplestore' for SimpleStore-0.0.1.0...
    Running simplestore...
    Running webserver on port 8081

    $ curl http://localhost:8081/auth/token -X POST -H "Content-type: application/json"   -d '{"username":"tom","password":"pass"}' -v
    * Adding handle: conn: 0x5ee9c0
    * Adding handle: send: 0
    * Adding handle: recv: 0
    * Curl_addHandleToPipeline: length: 1
    * - Conn 0 (0x5ee9c0) send_pipe: 1, recv_pipe: 0
    * About to connect() to localhost port 8081 (#0)
    *   Trying ::1...
    * Connection refused
    *   Trying 127.0.0.1...
    * Connected to localhost (127.0.0.1) port 8081 (#0)
    > POST /auth/token HTTP/1.1
    > User-Agent: curl/7.30.0
    > Host: localhost:8081
    > Accept: */*
    > Content-type: application/json
    > Content-Length: 36
    >
    * upload completely sent off: 36 out of 36 bytes
    < HTTP/1.1 201 Created
    < Transfer-Encoding: chunked
    < Date: Tue, 01 Dec 2015 13:29:24 GMT
    * Server Warp/3.1.9 is not blacklisted
    < Server: Warp/3.1.9
    < Content-Type: application/json
    <
    {"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJTdXBlckFkbWluIjp0cnVlLCJpc3MiOiJGb28iLCJQcm9qZWN0Q2xhaW0gUHJvamVjdEVkaXRvciBBbGxQcm9qZWN0c
    yI6dHJ1ZSwiSWRlbnRpdHlDbGFpbSAxIjp0cnVlLCJUZW5hbnRDbGFpbSBUZW5hbnRBZG1pbiBBbGxUZW5hbnRzIjp0cnVlfQ.DFJtvEPo0aP2H3QfDo844KKBzj44dHShBBg_HN3MXF
    Y"}* Connection #0 to host localhost left intact
