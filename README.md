# docker-phan

An installation of PHP7 and [Phan][phan] in a super tiny [Alpine Linux][alpine]
Docker image. The image is just 17 MB and runs interactively on the files
outside your container, making it easy to statically analyze PHP code.

## Motivations

Phan requires PHP7 and specific PHP extensions to be installed. PHP7 isn’t
packaged yet for many Linux distributions and users would still need to compile
and enable the extra PHP extensions.

By packaging Phan inside a Docker image, we can separate the runtime and
configuration of the tool from your application’s environment and requirements.

## Getting docker-phan

The easiest way to use `docker-phan` is to create a shell function for “phan”
that makes makes it nearly transparent that phan is running inside Docker.

```sh
phan() { docker run -v $PWD:/mnt/src --rm -u "$(id -u):$(id -g)" cloudflare/phan:latest $@; return $? }
```

(You may replace “latest” with a tagged Phan release to use a specific version
of Phan.)

## Running docker-phan
> If you’re just getting started with Phan, you should follow Phan’s excellent
[Tutorial for Analyzing A Large Sloopy Code Base][phan-tutorial] to setup the
initial configuration for your project.

All of Phan’s command line flags can be passed to `docker-phan`.

## Example

To create an “analysis.txt” in the current directory for farther processing

``` sh
phan -po analysis.txt
```

## Building

Docker images are built with the `build` script based on the awesome building
and testing framework put into place by the [`docker-alpine`][docker-alpine]
contributors. See [BUILD.md][build-docs] for more information.

## License

[BSD 2-Clause License][bsd-2-clause]

[phan]: https://github.com/etsy/phan
[alpine]: http://www.alpinelinux.org/
[phan-tutorial]: https://github.com/etsy/phan/wiki/Tutorial-for-Analyzing-a-Large-Sloppy-Code-Base
[docker-alpine]: https://github.com/gliderlabs/docker-alpine
[build-docs]: BUILD.md
[bsd-2-clause]: https://tldrlegal.com/license/bsd-2-clause-license-(freebsd)#summary
