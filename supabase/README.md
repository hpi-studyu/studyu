# Supabase CLI for StudyU

This guide describes how to run the [Supabase CLI](https://supabase.com/docs/guides/cli)
for StudyU for development purposes. It assumes that you have already cloned the StudyU
repository and are familiar with the process of how to run command line instructions.

**It is strongly advised that the following instructions should only be followed for developing
and testing the StudyU platform and __not__ for running live studies with actual participants.
The setup should only be run on a local machine and the containers from the Supabase CLI is not
meant to be exposed to a network or the Internet, as no means of security measurements are
implemented.**

Interested in running a study in a live and secure setting with StudyU? Head to the
[Contact page](https://www.studyu.health/contact) of our website and send us a message. We are
looking forward to support your research.

## Getting Started

1. Install [Docker](https://www.docker.com/).
1. Follow the Supabase CLI [Getting Started](https://supabase.com/docs/guides/cli/getting-started) installation instructions.
1. Open a command line and `cd` to the root directory of the studyu repository.
1. Prepare the local environment by executing `cp flutter_common/lib/envs/.env.local.example flutter_common/lib/envs/.env.local`
1. Run `supabase start`.

This will spin up a local environment of Supabase for development. Run `supabase stop` to stop the
Supabase stack.

## Connect to the local Supabase Instance

Run `melos run local:designer_v2` or `melos run local:app` to launch the respective StudyU
component with the self-hosted environment of the Supabase CLI.  The database will come seeded
with testing data. You can log into the StudyU Designer by using the credentials
`user1@studyu.health` and `user1pass`.

Open [Supabase Studio](http://localhost:54323) to access the graphical interface of Supabase to
manage the local instance.

## What's more?

Run `supabase db reset` to revert to the default database state. Find out more commands and
features of the Supabase CLI on the [CLI reference](https://supabase.com/docs/reference/cli/introduction)
pages.
