# A template for running bitwarden_rs on Univention (4.2 and up)

Will be worked on every once in a while. Contributions welcome!

(Probably) opiniated recipe for running dockerised applications on Univention Corporate Server (UCS). The provided app is a Bitwarden server API implementation compatible with [upstream Bitwarden clients](https://bitwarden.com/#download)*, ideal for self-hosted deployment where running official resource-heavy service might not be ideal.

The upstream source of the app is a [Rust implementation of the Bitwarden API](https://github.com/dani-garcia/bitwarden_rs). The script in this repo uses the projects official Docker image and always gets the latest tagged version from the Docker Hub.

_*Note, that this project is not associated with the [Bitwarden](https://bitwarden.com/) project nor 8bit Solutions LLC._

## Getting logs

The app does not write a logfile of its own, instead the `docker logs` command should be used, e.g. like the following `docker logs -f bitwarden-rs`.
