# Installation instructions

## SSH

- Generate a SSH key pair and add the public key to the host machine.
- Disable password authentication and X11 forwarding in the SSH configuration file.

## Directories and Environment Variables

Choose where to store the services, secrets, and Docker Compose files. Then set the following environment variables in your shell configuration file (e.g., `~/.bashrc`, `~/.zshrc`):

- `SERVICES_DIR=`
- `SECRETS_DIR=`
- `DOCKERS_DIR=`

Finally, for them to be passed through `sudo`, adapt the `sudoers` file by adding the following line:

```bash
Defaults        env_keep += "SERVICES_DIR SECRETS_DIR DOCKERS_DIR"
```

## Install Docker

- `https://docs.docker.com/engine/install/debian/#install-using-the-repository`

## Build and run every Docker Compose file
