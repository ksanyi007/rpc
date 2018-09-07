# Requirements

- Linux
- Docker
- perf: The Linux performance testing utility

The server and client components are run in a container for a consistent and
stable environment regarding system libraries and compiler versions.

# Usage

## Generate binary test data

Run:
```
cd data
./gen.sh
```

This will generate 1MiB files for the binary binary entries for each line in
the data.csv.

# Build the Docker images

Run `./build.sh`, this will create the Docker images the tests are run in.

# Configuration

The `./test.sh` has a few variables to tune how the tests are performed:
- REPEATS: how many times is a single test repeated
- SERVER: the IP address of the machine the server will be listening on
- START: the index of the first record to process
- END: the index of the last record to process

# Running the tests

Run `./test.sh`.

This will prompt before each server change to start the corresponding server by
running `./run.sh <rpc type> <language> server` on the machine designated as
the server.

The results of the tests will be output to the current directory in separate
log files.
