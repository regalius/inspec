# InSpec Habitat Plugin

## Summary

This plugin allows you to do the following:
  1. Add Habitat configuration to a profile
  2. Create/Upload a Habitat package from an InSpec profile

Creating a [Habitat](https://www.habitat.sh/) package from an InSpec
profile allows you to execute that profile as a service (via a
Habitat Supervisor) on any Linux based platform.

When running as a service, an InSpec report will be created on the server in
JSON format (by default at `/hab/svc/YOUR_SERVICE/logs/inspec_log.txt`). CLI
output is also viewable in the Supervisor logs by default. You can also
configure this service to report to [Chef
Automate](https://www.chef.io/automate/).

See below for usage instructions.

## Plugin Usage

### Adding Habitat Configuration to an InSpec Profile

Run the following command:

```
inspec habitat profile setup PATH
```

This will create the following files:
  - habitat/plan.sh (Instructs Habitat on how to build the package)
  - habitat/default.toml (Used to configure the running Habitat service)
  - habitat/hooks/run (Shell script to execute this profile as a service)
  - habitat/config/inspec_exec_config.json (TOML for `inspec exec` CLI options)

### Creating a Habitat Package

> This command requires Habitat to be installed and configured see
[here](https://www.habitat.sh/docs/install-habitat/) for instructions on how to
do that

Run the following command:

```
inspec habitat profile create PATH
```

This command will:
  - Create a Habitat artifact (`.hart` file).

> NOTE: If you are fetching packages from Chef Automate see
[below](#Integrating-with-Chef-Automate).

### Uploading a Habitat Package

> This command requires Habitat to be installed and configured see
[here](https://www.habitat.sh/docs/install-habitat/) for instructions on how to
do that

Run the following command:

```
inspec habitat profile upload PATH
```

This command will:
  - Create a Habitat artifact (`.hart` file).
  - Upload the Habitat artifact to [bldr.habitat.sh](bldr.habitat.sh).


> NOTE: If you are fetching packages from Chef Automate see
[below](#Integrating-with-Chef-Automate).

## Habitat Package Usage

> These commands require Habitat to be installed and configured see
[here](https://www.habitat.sh/docs/install-habitat/) for instructions on how to
do that

After creating the Habitat package, see here for usage:

[https://www.habitat.sh/docs/using-habitat/#Using-Habitat-Packages](https://www.habitat.sh/docs/using-habitat/#Using-Habitat-Packages)


From a HART file:

```
# See Habitat docs for more info. The below is for testing only.
hab pkg install PATH_TO_CREATED_HART_FILE
hab sup run YOUR_ORIGIN/inspec-profile-YOUR_PROFILE_NAME
```

From the public Habitat Builder Depot:

```
# See Habitat docs for more info. The below is for testing only.
hab pkg install YOUR_ORIGIN/inspec-profile-YOUR_PROFILE_NAME
hab sup run YOUR_ORIGIN/inspec-profile-YOUR_PROFILE_NAME
```

## Integrating with Chef Automate

### Fetching Profiles from Chef Automate During Build

Chef Automate requires authentication to fetch profiles from.

Run the following commands prior to creating/uploading your Habitat package:

```
# Remove -k if you are not using a self-signed certificate
inspec compliance login -k --user USER --token API_TOKEN https://AUTOMATE_FQDN
export HAB_STUDIO_SECRET_COMPLIANCE_CREDS=$(cat ~/.inspec/compliance/config.json)
```

### Sending InSpec Reports to Chef Automate

After running your Habitat package as a service you can configure it to report
to Chef Automate via a [configuration update](https://www.habitat.sh/docs/using-habitat/#config-updates).

For example, create a TOML file (config.toml) that matches the below:

```
[automate]
url = 'https://chef-automate.test'
token = 'TOKEN'
user = 'admin'
```

Then apply it like so:

```
# The '1' here is the config version (increment this with each change)
hab config apply inspec-profile-PROFILE_NAME.default 1 /path/to/config.toml
```

This will apply the configuration to all services in the service group. For
more info on service groups see the
[Habitat docs](https://www.habitat.sh/docs/using-habitat/#service-groups)

## Testing

TODO
