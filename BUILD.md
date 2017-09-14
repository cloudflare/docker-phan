# Building and Testing

A convenience `build` script is included that has the ability to build the Phan
images and run basic tests against the resulting image tags. This script is
created to (eventually) be used by continuous integration, but you can run the
script locally to build your own images. Be sure to check out the environment
variables that can be tweaked at the top of the script file.

## Image

### Builder

The Phan images are built using a builder Docker container based on the `alpine`
image. This builder image lives in the `builder` sub-directory of the project
and uses a `mkimage-phan.bash` script to generate a `rootfs.tar.gz` file that is
layered over a new Alpine Linux container.

### Options

The build script takes a glob of `options` files as an argument. Each of these
files lives in a folder that describes the version of Phan to be built. Each
line of the `options` file are the options that will be applied to the resulting
image. By default, we use the glob `versions/**/options`.

### Example

To build all the images simply run:

```sh
./build
```

Pass version files to the `build` script to build specific versions:

```sh
./build versions/edge/options
```

With `parallel` available you can speed up building a bit:

```sh
parallel -m ./build ::: versions/**/options
```

## Testing

The test for images is very simple, as Phan already runs their own comprensive
test suite. We test that the arguments are passed through to `phan` inside the
container, that Phan is operating in the expected location (and that file are
linked into the container correctly), and that lines from stdout are printed.

Use the `test` sub-command of the `build` utility to run tests on currently
built images.

### Example

Run tests for a single image:

```sh
./build test versions/edge/options
```

Run all tests:

```sh
./build test
```

Run tests in parallel with the `parallel` utility

```sh
parallel ./build test ::: versions/**/options
```

## Pushing

The `build` script also has the capability to push built images to the Docker
registry, but it hasn’t yet been tested.
