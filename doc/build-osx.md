# macOS Build Instructions and Notes

The commands in this guide should be executed in a Terminal application.
The built-in one is located in
```
/Applications/Utilities/Terminal.app
```

## Preparation
Install the macOS command line tools:

```shell
xcode-select --install
```

When the popup appears, click `Install`.

Then install [Homebrew](https://brew.sh).

## Dependencies
```shell
brew install automake libtool boost miniupnpc openssl pkg-config python qt@5 libevent qrencode
```

See [dependencies.md](dependencies.md) for a complete overview.

If you want to build the disk image with `make deploy` (.dmg / optional), you need RSVG:
```shell
brew install librsvg
```

## Berkeley DB
It is recommended to use Berkeley DB 5.3. If you have to build it yourself,
you can use [this](/contrib/install_db5.sh) script to install it
like so:

```shell
./contrib/install_db5.sh .
```

from the root of the repository.

**Note**: You only need Berkeley DB if the wallet is enabled (see [*Disable-wallet mode*](/doc/build-osx.md#disable-wallet-mode)).

## Build Auroracoin

1. Clone the Auroracoin source code:
    ```shell
    git clone https://github.com/aurarad/Auroracoin
    cd Auroracoin
    ```

2.  Build Auroracoin:

    Configure and build the headless Auroracoin binaries as well as the GUI (if Qt is found).

    You can disable the GUI build by passing `--without-gui` to configure.
    ```shell
    ./autogen.sh
    ./configure
    make
    ```

3.  It is recommended to build and run the unit tests:

    ```shell
    make check
    ```

4.  You can also create a  `.dmg` that contains the `.app` bundle (optional):
    ```shell
    make deploy
    ```

## `disable-wallet` mode
When the intention is to run only a P2P node without a wallet, Auroracoin may be
compiled in `disable-wallet` mode with:
```shell
./configure --disable-wallet
```
In this case there is no dependency on Berkeley DB 5.3.

Mining is also possible in disable-wallet mode using the `getblocktemplate` RPC call.

## Running
Auroracoin is now available at `./src/auroracoind`

Before running, you may create an empty configuration file:
```shell
mkdir -p "/Users/${USER}/Library/Application Support/Auroracoin"

touch "/Users/${USER}/Library/Application Support/Auroracoin/auroracoin.conf"

chmod 600 "/Users/${USER}/Library/Application Support/Auroracoin/auroracoin.conf"
```

The first time you run auroracoind, it will start downloading the blockchain. This process could
take many hours, or even days on slower than average systems.

You can monitor the download process by looking at the debug.log file:
```shell
tail -f $HOME/Library/Application\ Support/Auroracoin/debug.log
```
## Other commands:
```shell
./src/auroracoind -daemon      # Starts the auroracoin daemon.
./src/auroracoin-cli --help    # Outputs a list of command-line options.
./src/auroracoin-cli help      # Outputs a list of RPC commands when the daemon is running.
```

## Notes
* Tested on OS X 10.14 Mojave through macOS 11 Big Sur on 64-bit Intel
processors only.
* Building with downloaded Qt binaries is not officially supported. See the notes in [#7714](https://github.com/bitcoin/bitcoin/issues/7714).
