# simplestore

The goal of this project is to have a multi-tennant storage service for projects.

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
    $ git clone git@github.com:arealities/servant.git
    $ cabal sandbox init
    $ cabal sandbox add-source servant/servant
    $ cabal sandbox add-source servant/servant-server
    $ cabal install --only-dependencies
    $ cabal build

Windows tip: if you try to do this on windows, you might get an error message
saying `(g)cc` is missing. Install `MingW`, or if you have `msysgit`, just add
`c:\msysgit\bin` to your path:

    set PATH = c:\msysgit\bin;%PATH%

Also, if you use `GHC` on windows, get the latest installer from https://www.haskell.org/platform/windows.html, as the `chocolatey installer` is not up to date.

# Testing


    $ cabal run &
    [1] 1872
    $ Preprocessing executable 'Arealities-SalesBackend' for
    Arealities-SalesBackend-0.0.1.0...
    Running Arealities-SalesBackend...
    $ curl http://localhost:8081/admin/builddatabase
    "database test.db created."
    $ curl http://localhost:8081/tenants -X POST -d '{"tenantId":1,"tenantName":"Arealities"}' -H "Content-Type: application/json"
    {"tenantName":"Arealities","tenantId":1}
    $ curl http://localhost:8081/tenants/1/projects -X POST -d '{"projectId":1,"projectTenantId":1,"projectDescription":"Blah","projectContent"
    :"some content"}' -H "Content-Type: application/json"
    {"projectTenantId":1,"projectContent":"some content","projectId":1,"projectDescription":"Blah"}
    $ curl http://localhost:8081/tenants/1/projects
    [{"tentantId":1,"projectId":1,"description":"Blah"}]
    $ curl http://localhost:8081/tenants
    [{"tenantName":"Arealities","tenantId":1}]
    $ fg
    cabal run
    ^C

# License

As usual it's WTFPL.
