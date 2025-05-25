# Installation instructions

## SSH key pair generation

- Generate a SSH key pair and add the public key to the host machine.

## Host setup

Push `install.sh` to the host machine and execute it.

## Push secrets

```bash
$SECRETS_DIR/push_secrets.sh
```

## Run all services

Go in every directory, follow eventual instructions in the respective `README.md` file and run `sudo docker compose up -d`.
