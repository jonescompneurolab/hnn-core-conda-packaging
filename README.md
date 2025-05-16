# hnn-core-conda-packaging

This repo has all the code and metadata you need to **build** the Conda packages for HNN-Core. These
packages (`hnn-core-all` and `hnn-core`) should be remade and uploaded every time there is a new
version release. Note that currently, this is still a very "manual" process. This is for developers
building our Conda package -- if you are just trying to *install* the HNN-Core Conda package, then
please see our [Installation Guide
here](https://jonescompneurolab.github.io/hnn-core/stable/install.html).

This repo is based off of discussion in https://github.com/jonescompneurolab/hnn-core/issues/950 .

# Summary

### Packages

This gives you what you need to build two distinct packages:

- `hnn-core`: A Conda package providing the "minimal" version of HNN-Core, that is, ONLY the API. No GUI, no parallelism, nothin'! This is what has been uploaded to produce https://anaconda.org/jonescompneurolab/hnn-core .
- `hnn-core-all`: A Conda package providing a "maximal" version of HNN-Core, with ALL user-facing features enabled (i.e. those for `gui`, `opt`, and both MPI and Joblib `parallelism`, but not `docs` or `testing`). This is what has been uploaded to produce https://anaconda.org/jonescompneurolab/hnn-core-all .

### Supported platforms

The below keywords are how the Conda package building system refers to these platforms (see the table at https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#preprocessing-selectors ). Definition: when I say "platform", I mean combination of OS and CPU architecture.

- `osx-arm64` (MacOS on Apple Silicon)
- `osx-64` (MacOS on x86_64)
- `linux-64` (Linux on x86_64) (can be *used* on Windows via WSL, but not necessarily *built* using WSL.)
- Linux on ARM is *not* supported yet. This can be added easily, but I don't have hardware to test it on.

### Supported Python versions

Currently, these packages are ONLY built for Python 3.12 specifically. Since these packages require the user to have Anaconda, the user always has access to 3.12 specifically. We can expand to other versions in the future if we need to, but one version should be sufficient for now. There are several reasons to not support multiple Python versions (especially because of the use of NEURON wheel files, see the section on `build.sh` below for details).

# How to use this repo to build and upload the packages

1. Install Anaconda.

2. Install your system dependencies for the `nrnivmodl` part of HNN-Core's install:
    - For MacOS, you must install Xcode Command-Line Tools using the command `xcode-select --install`. You MUST restart your computer after this, if they were not already installed.
    - For Linux, you must install the fundamental compilation/building tools for your distro. For example, on Ubuntu, the `build-essential` package is probably sufficient, using `sudo apt-get install build-essential`.

3. Clone this repo.

4. Enter your `base` environment, NOT a custom environment! All conda package building must be done in the `base` environment, see https://docs.conda.io/projects/conda-build/en/latest/install-conda-build.html for details.

5. Run the script `00-install-build-deps.sh` using `./00-install-build-deps.sh` or however you like. This installs the builder packages.

6. Begin by building the `hnn-core-all` package-file for your local platform, using the following sub-steps:
    1. `cd` into `hnn-core-all`. This subdirectory contains everything you should need for building the `hnn-core-all` package-file on your local platform.
    2. Run the local script `01-build-pkg.sh` using `./01-build-pkg.sh` or however you like. This will take a couple minutes, and this is where any problems will arise, since this is the actual package build step. See details below in the [Details and caveats for building](#details-and-caveats-for-building) section.
    3. Assuming the last step was successful, there should now be some new files and folders located in a directory you can access with `cd $CONDA_PREFIX/conda-bld`. There should be a directory that is one of the above platform keywords of your local platform, e.g. `osx-arm64`. Inside that directory will be the "package-file" I keep mentioning, which will be have a name that ends in `.conda` like `<pkg name>-<pkg version>-<python version>_<build number>.conda`. For example, in my case, there is now a file there at `$CONDA_PREFIX/conda-bld/osx-arm64/hnn-core-all-0.4.1-py312_0.conda`. This is the "package-file" that all this work is for.
    4. TIP: if you ever want to clean your build environment (e.g. after a bad build didn't finish), run `conda build purge-all`.
    5. TIP: I can attest, it *is* possible to break your Conda install *as a whole* by doing certain actions. E.g., renaming a package `*.conda` file to a different name, then trying to install it locally. This seems to break some kind of Conda-wide metadata configuration and makes it impossible to install packages into existing environments. So uhh don't do that (or else the easiest way to deal with it is to just fully delete and reinstall Conda entirely).

7. Next, create a new environment and install your locally-built package using something like the following:

```
conda create -y -q -n test python=3.12
conda activate test
conda install hnn-core-all -c local -c conda-forge  # Run this line exactly how it is!
```

8. Test it!
    1. Then, run some test sims like with `hnn-gui` or whatever, and MAKE SURE to test that MPI parallelism works. Also test that Optimization works, by, for example, making sure that this script https://github.com/jonescompneurolab/hnn-core/blob/master/examples/howto/optimize_evoked.py at least successfully starts running the second iteration. You could also copy and run the tests locally, such as by downloading https://github.com/jonescompneurolab/hnn-core/tree/master/hnn_core/tests , installing `pip install pytest`, then running `pytest .`
    2. If possible, try running the new package-file on another computer of the same platform. See [How to install your built package](#how-to-install-your-built-package) below for how to do that (it's a little weird).

9. Finally, once you're satisfied that the package works, it's time to upload it. You will be uploading it from the command line, similar to how we've uploaded to PyPI in the past.
    1. If you haven't already, make an account on [anaconda.org](https://anaconda.org), and get your user account added to the [jonescompneurolab Organization](https://anaconda.org/jonescompneurolab) for permissions (ask @asoplata for access). WARNING: Note that you need an account on "anaconda dot ORG", not "dot COM" or "dot CLOUD"! Anaconda has many websites and you need to use [anaconda.org](https://anaconda.org). The different websites do not necessarily talk to each other!
    2. In your terminal run the command `anaconda login`. Note that this uses `anaconda` and not just `conda`! Also, if it complains that it doesn't have the command, you may need to `conda install anaconda-client`.
    3. You should now be ready to upload. Remember that "package-file" I specifically mentioned before? You need to upload that, but for the Organization, not your personal account. The example command I used to upload it is this:
```
anaconda upload --user jonescompneurolab $CONDA_PREFIX/conda-bld/osx-arm64/hnn-core-all-0.4.1-py312_0.conda
```
Note that you will probably have to change the platform-specific directory name, and the exact filename, if you are reading this. Fortunately, in contrast to PyPI and `conda-forge`, uploads to [anaconda.org](https://anaconda.org) are NOT immutable, and CAN be changed. If you need to replace the package-file because of a mistake or any reason, you can Anaconda's existing version with a different local one, using a command like below (the only difference is the additional `--force` argument):
```
anaconda upload --force --user jonescompneurolab $CONDA_PREFIX/conda-bld/osx-arm64/hnn-core-all-0.4.1-py312_0.conda
```

10. Almost done: just to be safe, you should also test that the online version of the file works too. Depending on how soon Anaconda provides the newly uploaded package (usually instantly), do the following:
```
conda create -y -q -n test python=3.12
conda activate test
conda install hnn-core-all -c jonescompneurolab -c conda-forge  # Run this line exactly how it is!
```
Assuming all your testing works, you should be done with package delivery of `hnn-core-all` for your local platform.

11. Now, you get to do it all over again! Assuming you have built `hnn-core-all` for one of the three [Supported platforms](#supported-platforms), you should now do it for the remaining ones. Currently, this requires you to use a computer that HAS that platform. However, in the future, using CI runners (e.g. via Github Actions) will enable a way to do that without requiring you to have physical access to such a platform.

12. Now, you get to do it all over again, AGAIN! Repeat the above steps, except doing them for the package in the `./hnn-core` subdirectory, rather than the `./hnn-core-all` subdirectory. Since `hnn-core` is a subset of `hnn-core-all`, there should be no bugs in the build process for `hnn-core` that aren't first discovered when building `hnn-core-all`. You will instead be dealing with a similarly named package-file, for example like `$CONDA_PREFIX/conda-bld/linux-64/hnn-core-0.4.1-py312_0.conda`.

# How to install your built package

### Local install:

Assuming you have built your package into the default `conda build` building directory (i.e. `$CONDA_PREFIX/conda-bld`) by using the scripts provided in this repo, your newly-built package(s) should be there. However, Conda's package management has some strong opinions, and one of those is that you don't install the package by just passing in the file name. Instead, it treats locally-built packages using the "channel name" `local` (see https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/channels.html ). This means that to install your local package, Conda needs not just the package-file itself, but also *metadata* about it in nearby files that it knows about; you have to provide this by telling it to use the `local` "channel" in addition to its `default` channel. Additionally, because HNN-Core depends on versions of OpenMPI only available on `conda-forge` (and we build it with them), you are REQUIRED to also provide the `conda-forge` channel as well. Thus, the way you install your locally-built package is the following command:

```
conda install <package-name> -c local -c conda-forge
```

where `<package-name>` is either `hnn-core-all` or `hnn-core`. Once you've done that, you're ready to test it however you like.

### Install from another computer:

Actually testing that a package-file you built on one computer works on a different computer of the same platform is requires only a few extra steps.

1. First, download the `<stuff>.conda` file from the other computer to your local one. For example, its location on the other computer might be `$CONDA_PREFIX/conda-bld/linux-64/hnn-core-0.4.1-py312_0.conda`. On your local computer download it to the corresponding directory at `$CONDA_PREFIX/conda-bld/<platform>`. For example, I might have to first `mkdir -p $CONDA_PREFIX/conda-bld/linux-64` to create the directory path, and then I would copy the actual `<stuff>.conda` file into that directory.

2. Next, you need to "index" the directory that you put the new `<platform>/<stuff>.conda` into, so that Conda knows about and can both find it and treat it as part of your `local` channel. For this, you can run `conda index $CONDA_PREFIX/conda-bld`. You may have to `conda install conda-index` if you haven't run `./00-install-build-deps.sh` locally.

3. Once you've done that, you should be able to install the downloaded package using `conda install <package-name> -c local -c conda-forge` just like above in the local case.

### Install from the cloud:

Once you've uploaded the package-file to the `anaconda.org` cloud, you can easily download it for testing by replacing our prior use of the `local` channel with the channel of our Organization on anaconda.org, which is the same name as our Github Org (`jonescompneurolab`). That is, you can do the following:

```
conda install <package-name> -c jonescompneurolab -c conda-forge
```

where `<package-name>` is either `hnn-core-all` or `hnn-core`.

# Details and caveats for building

Let's walk through what's going on if you're using `./hnn-core-all/01-build-pkg.sh` to try to build the more complex package, `hnn-core-all`.

In `01-build-pkg.sh`, the "top-level" package building script, there's really only one line of execution: essentially `conda-build recipe -c defaults -c conda-forge`. Linux requires an extra argument (only if you are building on a system where your main partition is encrypted...which it should be if it's your personal computer!), details on that are documented in comments in the script. The only other caveat here is that we *need* to indicate we want to use BOTH the `defaults` and `conda-forge` channels. As of 20250513, if you try to only use `conda-forge`, there is a file conflict between two dependency packages we need (see [Future work](#future-work)).

Now let's enter the crunchy center: the subdirectory `./hnn-core-all/recipe`. This can be named anything, but in general is referred to as the recipe. Everything currently in here except for `env_scripts` MUST be named a certain way, because the the Conda build system expects it to be (see https://docs.conda.io/projects/conda-build/en/latest/concepts/recipe.html ). I'll refer to the contents of all of these files inside `recipe` as the recipe.

If you start looking at the docs ( https://docs.conda.io/projects/conda-build/en/latest/resources/index.html ) or the tutorials (e.g. https://docs.conda.io/projects/conda-build/en/latest/user-guide/tutorials/build-pkgs-skeleton.html ), it's very easy to get overwhelmed. I already am. Many parts can be difficult to understand, especially if you asking "can I do X" or "what is the best way to do Y". An arguably better way to learn what you can do and HOW to do a certain thing (using `meta.yaml` and/or build scripts and/or anything else) is to check out yet another huge source of documentation, that of `conda-forge`: [https://conda-forge.org/docs/maintainer/knowledge_base/](https://conda-forge.org/docs/maintainer/knowledge_base/) . If you're reading this, especially if you are trying to improve our recipes, I *strongly* recommend you use the Github `Code Search` link on https://conda-forge.org/docs/maintainer/knowledge_base/ to look at the `recipe` of other packages to see how they do things. IMO this is much easier to understand than the Conda-build docs, but part of that is just because there is so much complexity in the system.

### `meta.yaml`

At minimum, all Conda package recipes must have at least a `meta.yaml` file (see  https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html ). Think of this as extremely similar to the classic Python package `setup.py` or, more equivalently, the modern `pyproject.toml`, but for the Conda packaging "ecosystem", INSTEAD of the PyPI packaging ecosystem.

For the below, I will paste consecutive lines taken exactly from the current version of our `meta.yaml` file below, and then provide some commentary in the text after each code block. Let's start with the top of the file:

```yaml
{% set name = "hnn-core" %}
{% set version = "0.4.1" %}
{% set build_number = 0 %}

{% set python_inclusive_min = "3.12" %}
{% set python_exclusive_max = "3.13" %}
```

First, all the fancy stuff inside `{% ... %}`: this is called "Jinja Templating" (see both https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#templating-with-jinja and https://en.wikipedia.org/wiki/Jinja_(template_engine) ), and essentially allows you to create and access some "programmability" inside your config file here. Note that the variables we create with Jinja are NOT required to be used elsewhere in the build process (meaning you can make your own), but conversely you CAN use Jinja to access build system stuff. We don't need anything fancy ourselves, however. The `inclusive/exclusive` vars are ones I made up for example, and are used later. Note that the `name` variable is NOT!!! the name of the package! Instead, it is ONLY a variable called `name` used in this file! (Remember, we are building the `hnn-core-all` package, NOT the `hnn-core` package in this file!).

```yaml
package:
  name: "hnn-core-all"
  version: "{{ version }}"

source:
  url: "https://pypi.org/packages/source/{{ name[0] }}/{{ name }}/hnn_core-{{ version }}.tar.gz"
  sha256: 50c8ec5eea289b23e38b8f2be5643d117c13552a179d5eb7efd3d64224c9e537
```

Here, you can clearly see that there is a `package: name: "hnn-core-all"` key-value. This is the one that "matters" and decides the name of the package.

For `source`: Even though the Conda packaging ecosystem tries to be as independent from the PyPI ecosystem (more on that soon), it is common for the source code of the root package to be downloaded from PyPI. We could also use Git or other methods as well, but using straight from PyPI is preferred. Note that currently, the URL of our PyPI distributable uses a combination of `hnn-core` (with a hyphen) as the package name, but the distributable filename itself uses `hnn_core` (with an underscore). This is partly a result of the filename output by our PyPI package release process (see https://github.com/jonescompneurolab/hnn-core/wiki/How-to-make-a-release ).

```yaml
build:
  skip: true  # [py<312 or py>313 or win or aarch64]
  entry_points:
    - hnn-gui=hnn_core.gui.gui:launch
  number: {{ build_number }}
```

Sit down for this part. Firstly, check out this:  https://conda-forge.org/docs/maintainer/understanding_conda_forge/life_cycle/ . We currently use the simplest way to distribute our Conda packages, which is described in the previous link: we use `conda-build` locally to create packages, repeat the process locally on all the platforms we want to support (which requires that we *own a computer* on that platform), then we manually upload each of them separately to anaconda.org. This means we don't need to do *as much* programming specific to each platform ( https://docs.conda.io/projects/conda-build/en/latest/resources/variants.html ), nor do we have to create a `conda_build_config.yaml` (see same link) and tell it what our `target_platform` is. Currently, our "target platform" is "whatever the platform is that we're building on". This keeps things simple (we know exactly what we're building), but requires us to manually build the package on a physical computer that has that platform.

The professional way to build our packages would be using CI runners like how `conda-forge` does it (see https://conda-forge.org/docs/maintainer/understanding_conda_forge/feedstocks/#package-building-diagram ). In that case, we would ONLY provide recipe scripts/metadata, and then different scripts would build our package independently for each platform that we desire. Eventually, this will be really nice to have, but probably requires a large amount of work, and is greatly complicated by our dependency on NEURON (I'll address that later). *Most* of the "target platform" documentation on the conda and conda-forge website sources are about how to control these complex systems. We do need to provide platform-specific builds (specifically because of NEURON, and maybe MPI too), but for now, building on local hardware is the simplest solution.

IF we were using CI (aka the cloud) to build our packages, then the `skip:` line is the first place we would begin controlling *which* platforms (or Python versions, etc.) the system builds for or *avoids* building for. It does this by using "preprocessing selectors" (see https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#preprocessing-selectors ) which are *defined in the comment on the `skip` line*. Currently, this ensures that the package will NOT attempt to be built (and likely fail) if you are trying to build it on native Windows or on Linux on ARM64 (aka `aarch64`). It's arguably unnecessary, but it doesn't hurt anything, and it also provides a working example of if we need to use preprocessing selectors in the future (e.g. such as if `osx` versus `linux` need different dependencies).

```yaml
requirements:
  host:
    - python >={{ python_inclusive_min }},<{{ python_exclusive_max }}
    - find-libpython
    - mpi4py
    - ncurses >=6.5,<7.0a0
    - numpy >=1.19,<2
    - openmpi >=5.0.5,<6.0a0
    - pip
    - readline >=8.2,<9.0a0
    - setuptools >=40.8.0
  run:
    - python >={{ python_inclusive_min }},<{{ python_exclusive_max }}
    - find-libpython
    - h5io
    - ipykernel
    - ipympl
    - ipython
    - ipywidgets >8.0.0
    - joblib
    - matplotlib-base >=3.5.3
    - mpi4py
    - ncurses >=6.5,<7.0a0
    - numpy >=1.19,<2
    - openmpi >=5.0.5,<6.0a0
    - psutil
    - readline >=8.2,<9.0a0
    - scikit-learn
    - scipy
    - voila
```

The `requirements` section lists our Conda dependencies, including our Python version (see  https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html#requirements-section ). `host` doubles as listing the dependencies for our package `build` requirements, which are different the requirements needed to fully `run` the software. (The `host/build/run` usage is another example of how Conda build is philosophically targeted at *servers* providing Anaconda packages). The most important thing about this section is that this is **fully independent of `pip` aka PyPI**! These are required CONDA packages, NOT `pip` packages! This is because, again, you need to be thinking from the perspective that we are in the Conda ecosystem.

Just to make things more confusing, these conda package dependencies can be from any conda channel. Recall from `./hnn-core-all/01-build-pkg.sh` that at build-time, we explicitly tell `conda-build` to use both the channels `defaults` and `conda-forge`. This is necessary because we need to use the more-recent version of some packages (e.g. `openmpi>5`), which are only available on `conda-forge`. However, if we exclusively use `conda-forge`, then other packages end up running into filename-clashing issues. So, currently, at build-time, we tell Conda to use both of these channels to find us a solution to our dependency tree that still uses the version constraints that we need for the above.

I will mention that there are certain version constraints above that are NOT found in `hnn-core`'s `setup.py` dependencies. You may be wondering where they come from, and the answer is the un-compressed recipe dependency list from https://anaconda.org/conda-forge/neuron . They appear to be necessary to install and use NEURON in our build process. However...

You may have noticed something: NEURON is not in this list! Not only that, but the NEURON conda package link I just wrote also is not present! That's because NEURON is a very special case, and we'll discuss that soon when we get to the `recipe/build.sh` build script.

```yaml
test:
  imports:
    - hnn_core
  commands:
    - pip check
    - hnn-gui --help
  requires:
    - pip
```

From here on, the `meta.yaml` is pretty self-explanatory. These are some, but not all, of the tests that are run automatically after package-building. These were created originally by the use of `grayskull` to automatically build the skeleton of the conda package directly from our PyPI package directions, but that only needs to be done the first time you're creating a package (see https://docs.conda.io/projects/conda-build/en/latest/user-guide/tutorials/build-pkgs-skeleton.html ).

The remainder of the tests are in the specially-named file `recipe/run_test.py`. This special filename (see https://docs.conda.io/projects/conda-build/en/latest/concepts/recipe.html ) is also automatically run using the test install of the package after it is built. That file doesn't really need explaining.

```yaml
about:
  home: https://hnn.brown.edu
  license: BSD 3-Clause
  license_file: LICENSE
  license_family: BSD
  license_url: https://github.com/jonescompneurolab/hnn-core/blob/master/LICENSE
  summary: HNN-Core install (all features) for cortical simulation with NEURON
  description: |
    This package provides the API and all features of the Human Neocortical Neurosolver (HNN-Core),
    which enables biophysical simulations of cortical columns and their EEG/MEG-related electric
    currents using NEURON. Note that this package MUST be installed with the conda-forge channel as
    well, such as using "conda install hnn-core-all -c jonescompneurolab -c conda-forge".
  dev_url: https://github.com/jonescompneurolab/hnn-core
  doc_url: https://jonescompneurolab.github.io/hnn-core/stable/index.html

extra:
  recipe-maintainers:
    - asoplata
```

This is also pretty self-explanatory. Pretty much the same thing as the metadata for `hnn-core/setup.py`. And now we're done going through `meta.yaml`!

### `run_test.py`

As I said above, this is a specially-named python script that includes tests to run automatically as part of the package building process. Self-explanatory.

### `build.sh`

This is specially-named "build script" file (see https://docs.conda.io/projects/conda-build/en/latest/concepts/recipe.html ). To be pedantic/pedagogical, the *overall* Conda build process looks like this:

1. `conda-build` creates and enters a test environment, usually something with a really weird name like `/opt/anaconda3/conda-bld/hnn-core_1747425893143/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold`. The placeholders are supposed to be there, since they have to do with making sure everything works inside the system's file-path-character-limit.
2. Conda then installs your `build` or `host` `requirement` dependencies into that environment.
3. Then the `build.sh` script is run. (If you're building on native Windows, the equivalent is a `bld.bat` file, but we don't build on native Windows, since we can provide the Linux version of the package for use via WSL).
4. Conda then tests the install, using both the tests mentioned in `meta.yaml` and running our `run_test.py` script. It's possible (I'm not sure) that the tests are actually run in a *second* test environment where the built package has been installed, in part to test its installation.
5. You end up with both a "package-file" described before (e.g. in `$CONDA_PREFIX/conda-bld/<platform>/<stuff>.conda`), and its metadata is registered in your `local` Conda channel.

So, our `build.sh` is where the magic happens. Note that this is run *after* our `build/host` Conda dependencies have been installed. In theory this script can do anything, but for our packages, this file does 4 things, in order, and based on which platform you are currently on:

1. Copies the `conda activate/deactivate` environment-variable-setting scripts from `env_scripts`, depending on if you're in Linux or Mac.
2. Manually downloads a **specific** NEURON-Python *wheel* file that is specific to the platform, NEURON version, and Python version.
3. The line `${PYTHON} -m pip install --no-deps ${NRN_WHL_URL}` installs the NEURON wheel file we just downloaded, but using *no PyPI- or `pip`-specific dependencies* (hence `--no-deps`). Instead, it has to install correctly only using the Conda dependencies we have installed.
4. Then, `${PYTHON} -m pip install . -vv --no-deps --no-build-isolation` **installs `hnn-core`**. This uses the copy downloaded from `meta.yaml`'s `source: url: <tarball>.tar.gz`). Again, this is also installed using ONLY the Conda dependencies, and NOT using PyPI-specific dependencies.

There's some important things to note about this build script:

1. We have to do it this really annoying way because Conda creates an extremely isolated test environment. Part of this isolation is that Conda appears to *disable PyPI dependency resolution*. This means that we cannot use the `pip` installer's integration with the PyPI index to find, match, etc. packages on the PyPI index. We CAN provide `pip` with an Internet-accessible wheel file like what we do for NEURON, and it will install that. But the Conda test environment will *not* simply let us `pip install NEURON`. Because NEURON provides many wheels ( https://pypi.org/project/NEURON/#files ) that are platform-specific, that means our install process needs to be platform-specific as well.

2. "But Austin", you say, "Why not use the `conda-forge` NEURON package https://anaconda.org/conda-forge/neuron ? Good question. The main reason is that this only provides builds for `linux-64` and `osx-64` platforms, but *not* `osx-arm64`. A smaller reason is that the version (v8.2.4) is slightly out of date compared to current stable (v8.2.6), and we can access the latter using the wheels. These NEURON conda packages are built by https://github.com/conda-forge/neuron-feedstock , but compiling/building NEURON using Conda dependencies is much more complex than our current HNN-Core Conda package process. It's kind of a much larger superset of the complexity in this current repo. This and #1 are the reasons why NEURON is not listed in our `meta.yaml`'s `requirements`.

3. Because our build script is essentially running `pip install hnn-core`, this means that we are running our full install program inside the environment that ends up in the package. Importantly, since `hnn-core` compiles NEURON `mod` files as part of its install process (see https://github.com/jonescompneurolab/hnn-core/blob/master/setup.py#L41-L74 ), *those resulting compiled files are included in our Conda package*. Ironically, because we have to provide platform-specific builds for other reasons, this isn't really a problem. But it needs to be noted: for a user, the Conda package install method for HNN-Core will NOT compile the `mod` files in fresh way, UNLIKE our `pip` install method. Instead, the Conda package is "shipping" compiled versions of the `mod` files. This could eventually lead to issues with binary compatibilities, but the worst-case scenario, we can still direct a user to install the older `pip` way.

4. Because of #3, since `pip install hnn-core` requires the successful running of `nrnivmodl` to compile our `mod` files, that means that anyone building our Conda packages has to have the pre-requisites for `nrnivmodl`. On MacOS, this means they need to have already installed Xcode Command-Line Tools. On Linux, they need to have installed `make` and whatever their basic system compilation suite package is, such as using `sudo apt-get install build-essential` on Ubuntu.

### Scripts in `env_script`

These are replacement `conda activate/deactivate` scripts for the old `echo "export OLD_DYLD_FALLBACK_LIBRARY_PATH=\$DYLD_FALLBACK_LIBRARY_PATH" >> etc/conda/activate.d/env_vars.sh` etc. lines that are needed for MPI installation. These are *automatically installed* through the Conda install process (we install them in our `build.sh`), which means that if a user installs our Conda packages, they no longer need to worry about changing their environment variables! Hooray.

# Future work

If you've read this far, then you've probably realized there's **significant** room for improvements.

- Top priority: Removing the need to build locally. Ideally, we should make movements towards how `conda-forge` does it by building the actual package-files using CI runners: see the diagram at https://conda-forge.org/docs/maintainer/understanding_conda_forge/feedstocks/ . We could start by doing this using Github Actions. I don't know where the final package-files would end up (maybe as Releases? or just copied into the repo itself?).
- Relatedly, if we did start building our packages-files from CI, I would be wary and of any automatic pushes to `anaconda.org` directly, at least until provide more consistent testing. Part of this testing should be `hnn-core`'s actual tests themselves! Currently, using `hnn-core`'s tests on an install that is NOT a local-source-install is difficult, and would probably require code changes.
- Another future goal is to transition to providing HNN-Core conda packages via the `conda-forge` community system, instead of pushing specific package-files directly to `anaconda.org` as we currently do. This requires more work: https://conda-forge.org/docs/maintainer/adding_pkgs/ . We would need to work with the `conda-forge` community and eventual become maintainers of a "feedstock" repo, after adapting our build process to do things the `conda-forge` way. Their way is very different than ours: the feedstock repo is just the recipe + metadata, and ALL building is done through CI orchestration. This is made more complicated due to our very weird, platform-and-architecture-specific NEURON wheel dependency.
- There is currently a "clobber" aka "file clash" if you try to build the package using ONLY the `conda-forge` channel in `01-build-pkg.sh` (as opposed to using both `defaults` and `conda-forge` like we currently do). By clobber, what I mean is that two different dependency packages both try to provide their own version of a certain shared library binary file; this leads to an error at pre-build-time. In other words, there is a problem with our dependency tree if we strictly use packages from the `conda-forge` channel. I've gotten around this for now by forcing our build to use BOTH the `defaults` and `conda-forge` channel, but it could result in other problems down the line, since we are mixing-and-matching packages from two very different channels. In general, the packages in `defaults` tend to be stable but much older, while the `conda-forge` packages tend to be much newer but also less stable (the classic software-package-management problem).
