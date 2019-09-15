# FWRISC-S Setup

Before proceeding, please ensure that the tools listed on the [Tools](fwrisc_tools.md) page are installed and configured.

## Clone the FWRISC Git Repository

First things first: you must clone the FWRISC Git repository:

```
% git clone http://github.com/mballance/fwrisc-s.git
```


## Fetch Dependent Packages
FWRISC depends on several external packages. These packages are fetched using [IVPM](http://github.com/mballance/ivpm), an IP and Verification Package Manager. In most cases, the fetch-package operation 
must only performed once after cloning the repository. To fetch dependent packages, do the following:

```
% cd fwrisc/scripts
% ./ivpm.py update
```

Check the console for any error messages before proceeding.

## Environment Setup
In addition to configuring environment variables for the tools listed on the [Tools](fwrisc_tools.md) page, you must source a setup script for FWRISC. Do the following:

```
% cd fwrisc
% source etc/fwrisc_env.sh
```

After doing so, `runtest.pl` should be present in your path and the PACKAGES_DIR environment variable will be set.

