Docker Builder
==============

Wrapper script to build docker images.

Usage
-----

```
Usage:
  -h, --help                Display this help message
  -i, --image image         Docker image to build
  -d, --dir dir             Directory for build context

Optional:
  -f, --file Dockerfile     Name of the Dockerfile (defaults to 'Dockerfile')
  -t, --tag tag             Tags for docker image (ie. latest; repeat to add more tags)
  -s, --semantic version    Generate docker tags for version based on semantic convention (ie 1.2.3)
  -l, --label label         Labels to pass to docker build (ie label=value; optional, repeat to add more labels)

Arguments after '--' will be pass to the docker build step. This can be used to pass build args,
                            invalidate the cache, etc.
```

License
-------
Released under the [MIT license](https://opensource.org/licenses/MIT).

Author Information
------------------
Luis Gracia while at [The Rockefeller University](https://www.rockefeller.edu):
- lgracia [at] rockefeller.edu
- GitHub at [luisico](https://github.com/luisico)

Vineet Palan while at [The Rockefeller University](https://www.rockefeller.edu):
- GitHub at [vineetpalan](https://github.com/vineetpalan)
