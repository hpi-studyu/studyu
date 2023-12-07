# Run StudyU with the StudyU CLI

The StudyU modules can be run with Docker allowing StudyU to be very easy to operate.
This makes it possible to quickly deploy code changes to your own instance or to store
data in a self-hosted Supabase instance data, rather than relying on a public cloud service.

Supabase can be [self-hosted](https://supabase.com/docs/guides/self-hosting/docker) by design,
since they are open source. We provide a modified version of their docker setup, specifically
optimized to work with StudyU.

You will need to install Docker to be able to run the StudyU CLI.
Make sure you have [Docker](https://docker.com) installed and configured by
running `docker -v`.

For HPI VMs,
[this script](https://gist.github.com/johannesvedder/0fafcbeabe8e069f96085bfedaebd9d0)
can be used to install and setup docker.

All the following commands are meant to be run from the root of this repository,
unless otherwise specified.

## Quickstart with the StudyU CLI

To get started quickly, run the StudyU CLI. It will interactively guide you
through the setup process. The CLI is a wrapper around the docker-compose
commands described in the following sections. It is located in the root
directory of the repository and can be run with `./studyu`.

The CLI offers multiple commands to manage your StudyU instance. Run
`./studyu --help` to see all available commands.

### Configure

Create a configuration file with `./studyu config` and choose the components you
want to run. The following components are available:

- `supabase`: A self-hosted Supabase instance
- `studyu-app`: A self-hosted instance of the StudyU App
- `studyu-designer`: A self-hosted instance of the StudyU Designer

Have a look into the use cases below for more details on the different 
configurations.

There are two components that are added automatically to the list of default
components:

- `supabase-db`: The PostgreSQL database for Supabase
- `proxy`: Nginx reverse proxy to access the frontend of the components

### Start

Start the components with `./studyu start`. On the first run, you will need
to configure the components. For this just follow the instructions.

After making changes to environment files such as `supabase/.env` or
`flutter_common/lib/envs/.env.*`, a rebuild of the StudyU components might be
necessary. You can run `./studyu delete` for this. Be sure to only remove
the containers and images and not the volumes.

### Add the StudyU CLI to your PATH
The StudyU CLI can be added to your PATH to make it easier to run. This can be
done by adding the following line to your `.bashrc` or `.zshrc` file:

```shell
export PATH=$PATH:<path-to-studyu-repo>
```

Reload your shell with `source ~/.bashrc` or `source ~/.zshrc` and you can
run the StudyU CLI from anywhere with `studyu`.

## Overview

The StudyU CLI setup is designed to be flexible and easily adoptable for various
setups. Here we describe the most common use-cases. When running `./studyu config`,
you can choose which components you want to run, depending on your use-case.

### Use Case #1: Run a self-hosted Supabase instance together with StudyU

Choose this method if you want to run StudyU together with your own Supabase instance.
This might be useful if you want to run StudyU after you made changes to the
codebase and the database schema.

Choose the following components:

- `supabase`
- `studyu-app`
- `studyu-designer`

### Use Case #2: Run StudyU only

Choose this method if you made changes to the StudyU codebase that are not
related to the database schema. The StudyU instances will use the default
StudyU Supabase instance.

Choose the following components:

- `studyu-app`
- `studyu-designer`

## Backup the Database

StudyU stores its data with Supabase as a backend that in turn stores its data
in a PostgreSQL database. The data for this database is stored in a docker
volume and is persisted between restarts. All data related to Supabase Storage
is stored in a different docker volume.

For backup purposes you should not create a backup of the StudyU data volume,
but rather use specific postgres backup tools such as `pg_dump`.

Run the StudyU CLI with `./studyu backup` to backup the StudyU database.

**Backing up the Supabase Storage data is not yet supported.**

## Update

Run the StudyU CLI with `./studyu update` to update the repository.

