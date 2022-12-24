# edk2-docker

Dockerized [edk2](https://github.com/tianocore/edk2)
geared towards building individual EFI images.

If you want to get your toes wet with EFI, you have a few options:
- gnu-efi
  - For some reason, picks apart ELF files and puts them in a PE wrapper
    - If we're sticking with GNU, couldn't we have used mingw?
    - Presents tons of limitations with what objcopy can do
      - Useful patch submissions for the future, but why not use the tools we have?
        - I don't feel like getting a letter from my employer, doing 10 cartwheels, washing Richard Stallman's feel, and going on a few side-quests at the moment
  - Trash codebase
    - Many occurences of return values not being checked and other low-hanging fruit
  - Lacks completeness
- Using `clang` to build images
  - This mitigates some issues with the PE format, but I'm still wanting libraries
- edk2
  - top-tier, but how do I integrate this into my codebase without forking and writing source in-tree?
    - If I want to write an EFI NES emulator I have to bring in all this other stuff?
      - -> We are here

To be clear, we are still bringing in the whole edk2 codebase.
Using Docker does a few things:
- Anyone who wants to replicate projects based off of this Docker can do so without worry of edk2 version
  - Pull the docker image and build
- Makes it easy to bring into existing build systems
- Eliminates (abstracts) having to bring in a bunch of edk2 sources

## Requirements

While not required to use this Docker image, [scuba](https://github.com/JonathonReinhart/scuba)
is required to follow along with the following usage example.
```sh
pip3 install scuba
```

Obviously, you should also have docker installed.

## Usage

### Set the scuba Default Image

Edit (create) `.scuba.yml` to set the default image to this docker image:
```yml
image: matthewtingum/edk2-build:0.1
```

### Mounting sources

When building with edk2 in-tree, package sources are expected to be found within a subdirectory
of the edk2 root. We will mount our package(s) in the edk2 root directory of the Docker image.
Here is an example of using `scuba` to mount package sources in the edk2 root with `scuba`.
Add this to `.scuba.yml`:
```yml
volumes:
  /edk2/HelloWorldPkg: /home/user/Documents/edk2-docker/HelloWorldPkg
  # Note that the host path is a full path to the package sources on *my* machine
```

**This example uses a path from my computer.**
**You will need to change it to build on your own machine.**

### Prepping a Build directory

Likewise, the build directory should be a Docker mount under the root directory of edk2.
Add this to `.scuba.yml`
```yml
volumes:
  /edk2/Build: /home/user/Documents/edk2-docker/Build
  # Note that the host path is a full path to the build directory on *my* machine
```

**This example uses a path from my computer.**
**You will need to change it to build on your own machine.**

Note that this directory *must* exist in tree.
`mkdir` the directory if it does not exist.

In the `dsc` file of your source package, you can now simply refer to this directory as `Build`.
```
OUTPUT_DIRECTORY               = Build
```

### Prepping a Conf directory

Configure a local Conf directory as you would in edk2.
This example uses the templates as-is from edk2.
Mount the host Conf directory to `/edk2/Conf` in the docker image with `scuba`.
Add this to `.scuba.yml`:
```yml
volumes:
  /edk2/Conf: /home/user/Documents/edk2-docker/Conf
  # Note that the host path is a full path to the conf directory on *my* machine
```

Look at what the Dockerfile does.
```sh
RUN cp /edk2/BaseTools/Conf/build_rule.template /edk2/Conf/build_rule.txt
RUN cp /edk2/BaseTools/Conf/tools_def.template /edk2/Conf/tools_def.txt
RUN cp /edk2/BaseTools/Conf/target.template /edk2/Conf/target.txt
```

This repo uses the edk2 templates without modification.
The templates can be found in the `edk2` repository.
You *will* however have to put these on host yourself.
This is a known issue and will be visible in the repository issues after initial commit.
(Probably #1)

### Adding a build command

Once again, edit `.scuba.yml`.
This time add an alias for `build` corresponding to the command you wish to execute
within the docker container:
```yml
aliases:
  build:
    script:
    - build -p HelloWorldPkg/HelloWorldPkg.dsc -t GCC5 -a X64
```

## Example usage TLDR

If you choose not to read the README and just want to build `HelloWorldPkg`
and start hacking on that, this is the section you want to read.
If you do not understand the edk2 framework you will find yourself in trouble
when trying to do more advanced things.
Good luck.

**Change your paths in the .scuba.yml file.**
There are paths that need to change that point to your filesystem.
Try reading `README.md`...

```sh
scuba build
```
