DigiByte Core version 0.17.1 is now available from:

  <https://digibytecore.org/bin/digibyte-core-0.17.1/>

This is a new major version release, including new features, various bugfixes
and performance improvements, as well as updated translations.

Please report bugs using the issue tracker at GitHub:

  <https://github.com/digibyte/digibyte/issues>

To receive security and update notifications, please subscribe to:

  <https://digibytecore.org/en/list/announcements/join/>

How to Upgrade
==============


Performance Improvements
--------------

Validation speed and network propagation performance have been greatly
improved, leading to much shorter sync and initial block download times.

- The script signature cache has been reimplemented as a "cuckoo cache",
  allowing for more signatures to be cached and faster lookups.
- Assumed-valid blocks have been introduced which allows script validation to
  be skipped for ancestors of known-good blocks, without changing the security
  model. See below for more details.
- In some cases, compact blocks are now relayed before being fully validated as
  per BIP152.
- P2P networking has been refactored with a focus on concurrency and
  throughput. Network operations are no longer bottlenecked by validation. As a
  result, block fetching is several times faster than previous releases in many
  cases.
- The UTXO cache now claims unused mempool memory. This speeds up initial block
  download as UTXO lookups are a major bottleneck there, and there is no use for
  the mempool at that stage.


Manual Pruning
--------------

DigiByte Core has supported automatically pruning the blockchain since 0.11. Pruning
the blockchain allows for significant storage space savings as the vast majority of
the downloaded data can be discarded after processing so very little of it remains
on the disk.

Manual block pruning can now be enabled by setting `-prune=1`. Once that is set,
the RPC command `pruneblockchain` can be used to prune the blockchain up to the
specified height or timestamp.

`getinfo` Deprecated
--------------------

The `getinfo` RPC command has been deprecated. Each field in the RPC call
has been moved to another command's output with that command also giving
additional information that `getinfo` did not provide. The following table
shows where each field has been moved to:

|`getinfo` field   | Moved to                                  |
|------------------|-------------------------------------------|
`"version"`	   | `getnetworkinfo()["version"]`
`"protocolversion"`| `getnetworkinfo()["protocolversion"]`
`"walletversion"`  | `getwalletinfo()["walletversion"]`
`"balance"`	   | `getwalletinfo()["balance"]`
`"blocks"`	   | `getblockchaininfo()["blocks"]`
`"timeoffset"`	   | `getnetworkinfo()["timeoffset"]`
`"connections"`	   | `getnetworkinfo()["connections"]`
`"proxy"`	   | `getnetworkinfo()["networks"][0]["proxy"]`
`"difficulty"`	   | `getblockchaininfo()["difficulty"]`
`"testnet"`	   | `getblockchaininfo()["chain"] == "test"`
`"keypoololdest"`  | `getwalletinfo()["keypoololdest"]`
`"keypoolsize"`	   | `getwalletinfo()["keypoolsize"]`
`"unlocked_until"` | `getwalletinfo()["unlocked_until"]`
`"paytxfee"`	   | `getwalletinfo()["paytxfee"]`
`"relayfee"`	   | `getnetworkinfo()["relayfee"]`
`"errors"`	   | `getnetworkinfo()["warnings"]`

ZMQ On Windows
--------------

Previously the ZeroMQ notification system was unavailable on Windows
due to various issues with ZMQ. These have been fixed upstream and
now ZMQ can be used on Windows. Please see [this document](https://github.com/digibyte/digibyte/blob/master/doc/zmq.md) for
help with using ZMQ in general.

Nested RPC Commands in Debug Console
------------------------------------

The ability to nest RPC commands has been added to the debug console. This
allows users to have the output of a command become the input to another
command without running the commands separately.

The nested RPC commands use bracket syntax (i.e. `getwalletinfo()`) and can
be nested (i.e. `getblock(getblockhash(1))`). Simple queries can be
done with square brackets where object values are accessed with either an 
array index or a non-quoted string (i.e. `listunspent()[0][txid]`). Both
commas and spaces can be used to separate parameters in both the bracket syntax
and normal RPC command syntax.

Network Activity Toggle
-----------------------

A RPC command and GUI toggle have been added to enable or disable all p2p
network activity. The network status icon in the bottom right hand corner 
is now the GUI toggle. Clicking the icon will either enable or disable all
p2p network activity. If network activity is disabled, the icon will 
be grayed out with an X on top of it.

Additionally the `setnetworkactive` RPC command has been added which does
the same thing as the GUI icon. The command takes one boolean parameter,
`true` enables networking and `false` disables it.

Out-of-sync Modal Info Layer
----------------------------

When DigiByte Core is out-of-sync on startup, a semi-transparent information
layer will be shown over top of the normal display. This layer contains
details about the current sync progress and estimates the amount of time
remaining to finish syncing. This layer can also be hidden and subsequently
unhidden by clicking on the progress bar at the bottom of the window.

Support for JSON-RPC Named Arguments
------------------------------------

Commands sent over the JSON-RPC interface and through the `digibyte-cli` binary
can now use named arguments. This follows the [JSON-RPC specification](http://www.jsonrpc.org/specification)
for passing parameters by-name with an object.

`digibyte-cli` has been updated to support this by parsing `name=value` arguments
when the `-named` option is given.

Some examples:

    src/digibyte-cli -named help command="help"
    src/digibyte-cli -named getblockhash height=0
    src/digibyte-cli -named getblock blockhash=000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
    src/digibyte-cli -named sendtoaddress address="(snip)" amount="1.0" subtractfeefromamount=true

The order of arguments doesn't matter in this case. Named arguments are also
useful to leave out arguments that should stay at their default value. The
rarely-used arguments `comment` and `comment_to` to `sendtoaddress`, for example, can
be left out. However, this is not yet implemented for many RPC calls, this is
expected to land in a later release.

The RPC server remains fully backwards compatible with positional arguments.

Opt into RBF When Sending
-------------------------

A new startup option, `-walletrbf`, has been added to allow users to have all
transactions sent opt into RBF support. The default value for this option is
currently `false`, so transactions will not opt into RBF by default. The new
`bumpfee` RPC can be used to replace transactions that opt into RBF.

Sensitive Data Is No Longer Stored In Debug Console History
-----------------------------------------------------------

The debug console maintains a history of previously entered commands that can be
accessed by pressing the Up-arrow key so that users can easily reuse previously
entered commands. Commands which have sensitive information such as passphrases and
private keys will now have a `(...)` in place of the parameters when accessed through
the history.

Retaining the Mempool Across Restarts
-------------------------------------

The mempool will be saved to the data directory prior to shutdown
to a `mempool.dat` file. This file preserves the mempool so that when the node
restarts the mempool can be filled with transactions without waiting for new transactions
to be created. This will also preserve any changes made to a transaction through
commands such as `prioritisetransaction` so that those changes will not be lost.

Final Alert
-----------

The Alert System was [disabled and deprecated](https://digibyte.org/en/alert/2016-11-01-alert-retirement) in DigiByte Core 0.12.1 and removed in 0.13.0. 
The Alert System was retired with a maximum sequence final alert which causes any nodes
supporting the Alert System to display a static hard-coded "Alert Key Compromised" message which also
prevents any other alerts from overriding it. This final alert is hard-coded into this release
so that all old nodes receive the final alert.

GUI Changes
-----------

 - After resetting the options by clicking the `Reset Options` button 
   in the options dialog or with the `-resetguioptions` startup option, 
   the user will be prompted to choose the data directory again. This 
   is to ensure that custom data directories will be kept after the 
   option reset which clears the custom data directory set via the choose 
   datadir dialog.

 - Multiple peers can now be selected in the list of peers in the debug 
   window. This allows for users to ban or disconnect multiple peers 
   simultaneously instead of banning them one at a time.

 - An indicator has been added to the bottom right hand corner of the main
   window to indicate whether the wallet being used is a HD wallet. This
   icon will be grayed out with an X on top of it if the wallet is not a
   HD wallet.

Low-level RPC changes
----------------------

 - `importprunedfunds` only accepts two required arguments. Some versions accept
   an optional third arg, which was always ignored. Make sure to never pass more
   than two arguments.

 - The first boolean argument to `getaddednodeinfo` has been removed. This is 
   an incompatible change.

 - RPC command `getmininginfo` loses the "testnet" field in favor of the more
   generic "chain" (which has been present for years).

 - A new RPC command `preciousblock` has been added which marks a block as
   precious. A precious block will be treated as if it were received earlier
   than a competing block.

 - A new RPC command `importmulti` has been added which receives an array of 
   JSON objects representing the intention of importing a public key, a 
   private key, an address and script/p2sh

 - Use of `getrawtransaction` for retrieving confirmed transactions with unspent
   outputs has been deprecated. For now this will still work, but in the future
   it may change to only be able to retrieve information about transactions in
   the mempool or if `txindex` is enabled.

 - A new RPC command `getmemoryinfo` has been added which will return information
   about the memory usage of DigiByte Core. This was added in conjunction with
   optimizations to memory management. See [Pull #8753](https://github.com/digibyte/digibyte/pull/8753)
   for more information.

 - A new RPC command `bumpfee` has been added which allows replacing an
   unconfirmed wallet transaction that signaled RBF (see the `-walletrbf`
   startup option above) with a new transaction that pays a higher fee, and
   should be more likely to get confirmed quickly.

HTTP REST Changes
-----------------

 - UTXO set query (`GET /rest/getutxos/<checkmempool>/<txid>-<n>/<txid>-<n>
   /.../<txid>-<n>.<bin|hex|json>`) responses were changed to return status 
   code `HTTP_BAD_REQUEST` (400) instead of `HTTP_INTERNAL_SERVER_ERROR` (500)
   when requests contain invalid parameters.

Minimum Fee Rate Policies
-------------------------

Since the changes in 0.12 to automatically limit the size of the mempool and improve the performance of block creation in mining code it has not been important for relay nodes or miners to set `-minrelaytxfee`. With this release the following concepts that were tied to this option have been separated out:
- incremental relay fee used for calculating BIP 125 replacement and mempool limiting. (1000 satoshis/kB)
- calculation of threshold for a dust output. (effectively 3 * 1000 satoshis/kB)
- minimum fee rate of a package of transactions to be included in a block created by the mining code. If miners wish to set this minimum they can use the new `-blockmintxfee` option.  (defaults to 1000 satoshis/kB)

The `-minrelaytxfee` option continues to exist but is recommended to be left unset.
=======
If you are running an older version, shut it down. Wait until it has completely
shut down (which might take a few minutes for older versions), then run the
installer (on Windows) or just copy over `/Applications/DigiByte-Qt` (on Mac)
or `digibyted`/`digibyte-qt` (on Linux).

If your node has a txindex, the txindex db will be migrated the first time you run 0.17.0 or newer, which may take up to a few hours. Your node will not be functional until this migration completes.

The first time you run version 0.15.0 or newer, your chainstate database will be converted to a
new format, which will take anywhere from a few minutes to half an hour,
depending on the speed of your machine.

Note that the block database format also changed in version 0.8.0 and there is no
automatic upgrade code from before version 0.8 to version 0.15.0 or higher. Upgrading
directly from 0.7.x and earlier without re-downloading the blockchain is not supported.
However, as usual, old wallet versions are still supported.

Downgrading warning
-------------------

Wallets created in 0.16 and later are not compatible with versions prior to 0.16
and will not work if you try to use newly created wallets in older versions. Existing
wallets that were created with older versions are not affected by this.

Compatibility
==============

Auroracoin is supported and extensively tested on operating systems using
the Linux kernel, macOS 10.10+, and Windows 7 and newer.  It is not recommended
to use Bitcoin Core on unsupported systems.

Auroracoin should also work on most other Unix-like systems but is not
frequently tested on them.

====
Wallet changes
---------------


### Segwit Wallet

DigiByte Core 0.16.0 introduces full support for segwit in the wallet and user interfaces. A new `-addresstype` argument has been added, which supports `legacy`, `p2sh-segwit` (default), and `bech32` addresses. It controls what kind of addresses are produced by `getnewaddress`, `getaccountaddress`, and `createmultisigaddress`. A `-changetype` argument has also been added, with the same options, and by default equal to `-addresstype`, to control which kind of change is used.

A new `address_type` parameter has been added to the `getnewaddress` and `addmultisigaddress` RPCs to specify which type of address to generate.
A `change_type` argument has been added to the `fundrawtransaction` RPC to override the `-changetype` argument for specific transactions.

- All segwit addresses created through `getnewaddress` or `*multisig` RPCs explicitly get their redeemscripts added to the wallet file. This means that downgrading after creating a segwit address will work, as long as the wallet file is up to date.
- All segwit keys in the wallet get an implicit redeemscript added, without it being written to the file. This means recovery of an old backup will work, as long as you use new software.
- All keypool keys that are seen used in transactions explicitly get their redeemscripts added to the wallet files. This means that downgrading after recovering from a backup that includes a segwit address will work

Note that some RPCs do not yet support segwit addresses. Notably, `signmessage`/`verifymessage` doesn't support segwit addresses, nor does `importmulti` at this time. `dumpwallet`/`importwallet` work, but will (in comments) list the corresponding P2PKH addresses for all keys, even those only used in segwit addresses. Support for segwit in those RPCs will continue to be added in future versions.

P2WPKH change outputs are now used by default if any destination in the transaction is a P2WPKH or P2WSH output. This is done to ensure the change output is as indistinguishable from the other outputs as possible in either case.

### BIP173 (Bech32) Address support ("bc1..." addresses)

Full support for native segwit addresses (BIP173 / Bech32) has now been added.
This includes the ability to send to BIP173 addresses (including non-v0 ones), and generating these
addresses (including as default new addresses, see above).

A checkbox has been added to the GUI to select whether a Bech32 address or P2SH-wrapped address should be generated when using segwit addresses. When launched with `-addresstype=bech32` it is checked by default. When launched with `-addresstype=legacy` it is unchecked and disabled.

### HD-wallets by default

Due to a backward-incompatible change in the wallet database, wallets created
with version 0.16.0 will be rejected by previous versions. Also, version 0.16.0
will only create hierarchical deterministic (HD) wallets.

### Replace-By-Fee by default in GUI

The send screen now uses BIP125 RBF by default, regardless of `-walletrbf`.
There is a checkbox to mark the transaction as final.

The RPC default remains unchanged: to use RBF, launch with `-walletrbf=1` or
use the `replaceable` argument for individual transactions.

### Wallets directory configuration (`-walletdir`)

DigiByte Core now has more flexibility in where the wallets directory can be
located. Previously wallet database files were stored at the top level of the
digibyte data directory. The behavior is now:

- For new installations (where the data directory doesn't already exist),
  wallets will now be stored in a new `wallets/` subdirectory inside the data
  directory by default.
- For existing nodes (where the data directory already exists), wallets will be
  stored in the data directory root by default. If a `wallets/` subdirectory
  already exists in the data directory root, then wallets will be stored in the
  `wallets/` subdirectory by default.
- The location of the wallets directory can be overridden by specifying a
  `-walletdir=<path>` option where `<path>` can be an absolute path to a
  directory or directory symlink.

Care should be taken when choosing the wallets directory location, as if it
becomes unavailable during operation, funds may be lost.

Build: Minimum GCC bumped to 4.8.x
------------------------------------
The minimum version of the GCC compiler required to compile DigiByte Core is now 4.8. No effort will be
made to support older versions of GCC. See discussion in issue #11732 for more information.
The minimum version for the Clang compiler is still 3.3. Other minimum dependency versions can be found in `doc/dependencies.md` in the repository.

Support for signalling pruned nodes (BIP159)
---------------------------------------------
Pruned nodes can now signal BIP159's NODE_NETWORK_LIMITED using service bits, in preparation for
full BIP159 support in later versions. This would allow pruned nodes to serve the most recent blocks. However, the current change does not yet include support for connecting to these pruned peers.

Performance: SHA256 assembly enabled by default
-------------------------------------------------
The SHA256 hashing optimizations for architectures supporting SSE4, which lead to ~50% speedups in SHA256 on supported hardware (~5% faster synchronization and block validation), have now been enabled by default. In previous versions they were enabled using the `--enable-experimental-asm` flag when building, but are now the default and no longer deemed experimental.

GUI changes
-----------
- Uses of "µDGB" in the GUI now also show the more colloquial term "bits", specified in BIP176.
- The option to reuse a previous address has now been removed. This was justified by the need to "resend" an invoice, but now that we have the request history, that need should be gone.
- Support for searching by TXID has been added, rather than just address and label.
- A "Use available balance" option has been added to the send coins dialog, to add the remaining available wallet balance to a transaction output.
- A toggle for unblinding the password fields on the password dialog has been added.
=======

From 0.17.0 onwards, macOS <10.10 is no longer supported.  0.17.0 is
built using Qt 5.9.x, which doesn't support versions of macOS older than
10.10.  Additionally, Bitcoin Core does not yet change appearance when
macOS "dark mode" is activated.

In addition to previously-supported CPU platforms, this release's
pre-compiled distribution also provides binaries for the RISC-V
platform.

Notable changes
===============

Mining
------

- Calls to `getblocktemplate` will fail if the segwit rule is not specified.
  Calling `getblocktemplate` without segwit specified is almost certainly
  a misconfiguration since doing so results in lower rewards for the miner.
  Failed calls will produce an error message describing how to enable the
  segwit rule.

Configuration option changes
----------------------------

- A warning is printed if an unrecognized section name is used in the
  configuration file.  Recognized sections are `[test]`, `[main]`, and
  `[regtest]`.

- Four new options are available for configuring the maximum number of
  messages that ZMQ will queue in memory (the "high water mark") before
  dropping additional messages.  The default value is 1,000, the same as
  was used for previous releases.  See the [ZMQ
  documentation](https://github.com/aurarad/Auroracoin/blob/master/doc/zmq.md#usage)
  for details.

- The `enablebip61` option (introduced in Bitcoin Core 0.17.0) is
  used to toggle sending of BIP 61 reject messages. Reject messages have no use
  case on the P2P network and are only logged for debugging by most network
  nodes. The option will now by default be off for improved privacy and security
  as well as reduced upload usage. The option can explicitly be turned on for
  local-network debugging purposes.

- The `rpcallowip` option can no longer be used to automatically listen
  on all network interfaces.  Instead, the `rpcbind` parameter must also
  be used to specify the IP addresses to listen on.  Listening for RPC
  commands over a public network connection is insecure and should be
  disabled, so a warning is now printed if a user selects such a
  configuration.  If you need to expose RPC in order to use a tool
  like Docker, ensure you only bind RPC to your localhost, e.g. `docker
  run [...] -p 127.0.0.1:8332:8332` (this is an extra `:8332` over the
  normal Docker port specification).

- The `rpcpassword` option now causes a startup error if the password
  set in the configuration file contains a hash character (#), as it's
  ambiguous whether the hash character is meant for the password or as a
  comment.

GUI changes
-----------

- Block storage can be limited under Preferences, in the Main tab. Undoing this setting requires downloading the full blockchain again. This mode is incompatible with -txindex and -rescan.

RPC changes
------------

Example item for a notable change.

0.16.x change log
------------------

(to be filled in at release time)
=======
RPC changes
------------

- The `importmulti` RPC now returns an additional `warnings` field for
  each request with an array of strings explaining when fields are being
  ignored or are inconsistent, if there are any.

- The `getaddressinfo` RPC now returns an additional `solvable` boolean
  field when Bitcoin Core knows enough about the address's scriptPubKey,
  optional redeemScript, and optional witnessScript in order for the
  wallet to be able to generate an unsigned input spending funds sent to
  that address.

- The `getaddressinfo`, `listunspent`, and `scantxoutset` RPCs now
  return an additional `desc` field that contains an output descriptor
  containing all key paths and signing information for the address
  (except for the private key).  The `desc` field is only returned for
  `getaddressinfo` and `listunspent` when the address is solvable.

- The `importprivkey` RPC will preserve previously-set labels for
  addresses or public keys corresponding to the private key being
  imported.  For example, if you imported a watch-only address with the
  label "cold wallet" in earlier releases of Bitcoin Core, subsequently
  importing the private key would default to resetting the address's
  label to the default empty-string label ("").  In this release, the
  previous label of "cold wallet" will be retained.  If you optionally
  specify any label besides the default when calling `importprivkey`,
  the new label will be applied to the address.

- See the [Mining](#mining) section for changes to `getblocktemplate`.

### Low-level changes

- The `createrawtransaction` RPC will now accept an array or dictionary (kept for compatibility) for the `outputs` parameter. This means the order of transaction outputs can be specified by the client.
- The `fundrawtransaction` RPC will reject the previously deprecated `reserveChangeKey` option.
- `sendmany` now shuffles outputs to improve privacy, so any previously expected behavior with regards to output ordering can no longer be relied upon.
- The new RPC `testmempoolaccept` can be used to test acceptance of a transaction to the mempool without adding it.
- JSON transaction decomposition now includes a `weight` field which provides
  the transaction's exact weight. This is included in REST /rest/tx/ and
  /rest/block/ endpoints when in json mode. This is also included in `getblock`
  (with verbosity=2), `listsinceblock`, `listtransactions`, and
  `getrawtransaction` RPC commands.
- New `fees` field introduced in `getrawmempool`, `getmempoolancestors`, `getmempooldescendants` and
   `getmempoolentry` when verbosity is set to `true` with sub-fields `ancestor`, `base`, `modified`
   and `descendant` denominated in BTC. This new field deprecates previous fee fields, such as
   `fee`, `modifiedfee`, `ancestorfee` and `descendantfee`.
- The new RPC `getzmqnotifications` returns information about active ZMQ
  notifications.

External wallet files
---------------------

The `-wallet=<path>` option now accepts full paths instead of requiring wallets
to be located in the -walletdir directory.

Newly created wallet format
---------------------------

If `-wallet=<path>` is specified with a path that does not exist, it will now
create a wallet directory at the specified location (containing a wallet.dat
data file, a db.log file, and database/log.?????????? files) instead of just
creating a data file at the path and storing log files in the parent
directory. This should make backing up wallets more straightforward than
before because the specified wallet path can just be directly archived without
having to look in the parent directory for transaction log files.

For backwards compatibility, wallet paths that are names of existing data files
in the `-walletdir` directory will continue to be accepted and interpreted the
same as before.

Low-level RPC changes
---------------------

- When digibyte is not started with any `-wallet=<path>` options, the name of
  the default wallet returned by `getwalletinfo` and `listwallets` RPCs is
  now the empty string `""` instead of `"wallet.dat"`. If digibyte is started
  with any `-wallet=<path>` options, there is no change in behavior, and the
  name of any wallet is just its `<path>` string.
- Passing an empty string (`""`) as the `address_type` parameter to
  `getnewaddress`, `getrawchangeaddress`, `addmultisigaddress`,
  `fundrawtransaction` RPCs is now an error. Previously, this would fall back
  to using the default address type. It is still possible to pass null or leave
  the parameter unset to use the default address type.

- Bare multisig outputs to our keys are no longer automatically treated as
  incoming payments. As this feature was only available for multisig outputs for
  which you had all private keys in your wallet, there was generally no use for
  them compared to single-key schemes. Furthermore, no address format for such
  outputs is defined, and wallet software can't easily send to it. These outputs
  will no longer show up in `listtransactions`, `listunspent`, or contribute to
  your balance, unless they are explicitly watched (using `importaddress` or
  `importmulti` with hex script argument). `signrawtransaction*` also still
  works for them.

### Logging

- The log timestamp format is now ISO 8601 (e.g. "2018-02-28T12:34:56Z").

- When running digibyted with `-debug` but without `-daemon`, logging to stdout
  is now the default behavior. Setting `-printtoconsole=1` no longer implicitly
  disables logging to debug.log. Instead, logging to file can be explicitly disabled
  by setting `-debuglogfile=0`.

Miner block size removed
------------------------

The `-blockmaxsize` option for miners to limit their blocks' sizes was
deprecated in V0.15.1, and has now been removed. Miners should use the
`-blockmaxweight` option if they want to limit the weight of their blocks'
weights.

Python Support
--------------

Support for Python 2 has been discontinued for all test files and tools.
=======
`listtransactions` label support
--------------------------------

The `listtransactions` RPC `account` parameter which was deprecated in 0.17.0
and renamed to `dummy` has been un-deprecated and renamed again to `label`.

When digibyte is configured with the `-deprecatedrpc=accounts` setting, specifying
a label/account/dummy argument will return both outgoing and incoming
transactions. Without the `-deprecatedrpc=accounts` setting, it will only return
incoming transactions (because it used to be possible to create transactions
spending from specific accounts, but this is no longer possible with labels).

When `-deprecatedrpc=accounts` is set, it's possible to pass the empty string ""
to list transactions that don't have any label. Without
`-deprecatedrpc=accounts`, passing the empty string is an error because returning
only non-labeled transactions is not generally useful behavior and can cause
confusion.

0.17.1 change log
=================

### P2P protocol and network code
- #14685 `9406502` Fix a deserialization overflow edge case (kazcw)
- #14728 `b901578` Fix uninitialized read when stringifying an addrLocal (kazcw)

### Wallet
- #14441 `5150acc` Restore ability to list incoming transactions by label (jnewbery)
- #13546 `91fa15a` Fix use of uninitialized value `bnb_used` in CWallet::CreateTransaction(…) (practicalswift)
- #14310 `bb90695` Ensure wallet is unlocked before signing (gustavonalle)
- #14690 `5782fdc` Throw error if CPubKey is invalid during PSBT keypath serialization (instagibbs)
- #14852 `2528443` backport: [tests] Add `wallet_balance.py` (MarcoFalke)
- #14196 `3362a95` psbt: always drop the unnecessary utxo and convert non-witness utxo to witness when necessary (achow101)
- #14588 `70ee1f8` Refactor PSBT signing logic to enforce invariant and fix signing bug (gwillen)
- #14424 `89a9a9d` Stop requiring imported pubkey to sign non-PKH schemes (sipa, MeshCollider)

### RPC and other APIs
- #14417 `fb9ad04` Fix listreceivedbyaddress not taking address as a string (etscrivner)
- #14596 `de5e48a` Bugfix: RPC: Add `address_type` named param for createmultisig (luke-jr)
- #14618 `9666dba` Make HTTP RPC debug logging more informative (practicalswift)
- #14197 `7bee414` [psbt] Convert non-witness UTXOs to witness if witness sig created (achow101)
- #14377 `a3fe125` Check that a separator is found for psbt inputs, outputs, and global map (achow101)
- #14356 `7a590d8` Fix converttopsbt permitsigdata arg, add basic test (instagibbs)
- #14453 `75b5d8c` Fix wallet unload during walletpassphrase timeout (promag)

### GUI
- #14403 `0242b5a` Revert "Force TLS1.0+ for SSL connections" (real-or-random)
- #14593 `df5131b` Explicitly disable "Dark Mode" appearance on macOS (fanquake)

### Build system
- #14647 `7edebed` Remove illegal spacing in darwin.mk (ch4ot1c)
- #14698 `ec71f06` Add digibyte-tx.exe into Windows installer (ken2812221)

### Tests and QA
- #13965 `29899ec` Fix extended functional tests fail (ken2812221)
- #14011 `9461f98` Disable wallet and address book Qt tests on macOS minimal platform (ryanofsky)
- #14180 `86fadee` Run all tests even if wallet is not compiled (MarcoFalke)
- #14122 `8bc1bad` Test `rpc_help.py` failed: Check whether ZMQ is enabled or not (Kvaciral)
- #14101 `96dc936` Use named args in validation acceptance tests (MarcoFalke)
- #14020 `24d796a` Add tests for RPC help (promag)
- #14052 `7ff32a6` Add some actual witness in `rpc_rawtransaction` (MarcoFalke)
- #14215 `b72fbab` Use correct python index slices in example test (sdaftuar)
- #14024 `06544fa` Add `TestNode::assert_debug_log` (MarcoFalke)
- #14658 `60f7a97` Add test to ensure node can generate all rpc help texts at runtime (MarcoFalke)
- #14632 `96f15e8` Fix a comment (fridokus)
- #14700 `f9db08e` Avoid race in `p2p_invalid_block` by waiting for the block request (MarcoFalke)
- #14845 `67225e2` Add `wallet_balance.py` (jnewbery)

### Documentation
- #14161 `5f51fd6` doc/descriptors.md tweaks (ryanofsky)
- #14276 `85aacc4` Add autogen.sh in ARM Cross-compilation (walterwhite81)
>>>>>>> 0.17

Documentation
-------------

- A new short
  [document](https://github.com/aurarad/Auroracoin/blob/master/doc/JSON-RPC-interface.md)
  about the JSON-RPC interface describes cases where the results of an
  RPC might contain inconsistencies between data sourced from different
  subsystems, such as wallet state and mempool state.  A note is added
  to the [REST interface documentation](https://github.com/aurarad/Auroracoin/blob/master/doc/REST-interface.md)
  indicating that the same rules apply.

- A new [document](https://github.com/aurarad/Auroracoin/blob/master/doc/auroracoin-conf.md)
  about the `auroracoin.conf` file describes how to use it to configure
  Auroracoin.

- A new document introduces Bitcoin Core's BIP174
  [Partially-Signed Bitcoin Transactions (PSBT)](https://github.com/aurarad/Auroracoin/blob/master/doc/psbt.md)
  interface, which is used to allow multiple programs to collaboratively
  work to create, sign, and broadcast new transactions.  This is useful
  for offline (cold storage) wallets, multisig wallets, coinjoin
  implementations, and many other cases where two or more programs need
  to interact to generate a complete transaction.

- The [output script descriptor](https://github.com/aurarad/Auroracoin/blob/master/doc/descriptors.md)
  documentation has been updated with information about new features in
  this still-developing language for describing the output scripts that
  a wallet or other program wants to receive notifications for, such as
  which addresses it wants to know received payments.  The language is
  currently used in the `scantxoutset` RPC and is expected to be adapted
  to other RPCs and to the underlying wallet structure.

Build system changes
--------------------

- A new `--disable-bip70` option may be passed to `./configure` to
  prevent Auroracoin-Qt from being built with support for the BIP70 payment
  protocol or from linking libssl.  As the payment protocol has exposed
  Auroracoin to libssl vulnerabilities in the past, builders who don't
  need BIP70 support are encouraged to use this option to reduce their
  exposure to future vulnerabilities.

Deprecated or removed RPCs
--------------------------

- The `signrawtransaction` RPC is removed after being deprecated and
  hidden behind a special configuration option in version 0.17.0.

- The 'account' API is removed after being deprecated in v0.17.  The
  'label' API was introduced in v0.17 as a replacement for accounts.
  See the [release notes from v0.17](https://github.com/aurarad/Auroracoin/blob/master/doc/release-notes/release-notes-0.17.0.md#label-and-account-apis-for-wallet)
  for a full description of the changes from the 'account' API to the
  'label' API.

- The `addwitnessaddress` RPC is removed after being deprecated in
  version 0.13.0.

- The wallet's `generate` RPC method is deprecated and will be fully
  removed in a subsequent major version.  This RPC is only used for
  testing, but its implementation reached across multiple subsystems
  (wallet and mining), so it is being deprecated to simplify the
  wallet-node interface.  Projects that are using `generate` for testing
  purposes should transition to using the `generatetoaddress` RPC, which
  does not require or use the wallet component. Calling
  `generatetoaddress` with an address returned by the `getnewaddress`
  RPC gives the same functionality as the old `generate` RPC.  To
  continue using `generate` in this version, restart bitcoind with the
  `-deprecatedrpc=generate` configuration option.

New RPCs
--------

- A new `getnodeaddresses` RPC returns peer addresses known to this
  node. It may be used to find nodes to connect to without using a DNS
  seeder.

- A new `listwalletdir` RPC returns a list of wallets in the wallet
  directory (either the default wallet directory or the directory
  configured by the `-walletdir` parameter).

Updated RPCs
------------

Note: some low-level RPC changes mainly useful for testing are described
in the Low-level Changes section below.

- The `getpeerinfo` RPC now returns an additional `minfeefilter` field
  set to the peer's BIP133 fee filter.  You can use this to detect that
  you have peers that are willing to accept transactions below the
  default minimum relay fee.

- The mempool RPCs, such as `getrawmempool` with `verbose=true`, now
  return an additional "bip125-replaceable" value indicating whether the
  transaction (or its unconfirmed ancestors) opts-in to asking nodes and
  miners to replace it with a higher-feerate transaction spending any of
  the same inputs.

- The `settxfee` RPC previously silently ignored attempts to set the fee
  below the allowed minimums.  It now prints a warning.  The special
  value of "0" may still be used to request the minimum value.

- The `getaddressinfo` RPC now provides an `ischange` field indicating
  whether the wallet used the address in a change output.

- The `importmulti` RPC has been updated to support P2WSH, P2WPKH,
  P2SH-P2WPKH, and P2SH-P2WSH. Requests for P2WSH and P2SH-P2WSH accept
  an additional `witnessscript` parameter.

Graphical User Interface (GUI)
------------------------------

- A new Window menu is added alongside the existing File, Settings, and
  Help menus.  Several items from the other menus that opened new
  windows have been moved to this new Window menu.

- In the Send tab, the checkbox for "pay only the required fee"
  has been removed.  Instead, the user can simply decrease the value in
  the Custom Feerate field all the way down to the node's configured
  minimum relay fee.

- In the Overview tab, the watch-only balance will be the only
  balance shown if the wallet was created using the `createwallet` RPC
  and the `disable_private_keys` parameter was set to true.

- The launch-on-startup option is no longer available on macOS if
  compiled with macosx min version greater than 10.11 (use
  CXXFLAGS="-mmacosx-version-min=10.11"
  CFLAGS="-mmacosx-version-min=10.11" for setting the deployment
  sdk version)

Low-level changes
=================

RPC
---

- The `submitblock` RPC previously returned the reason a rejected block
  was invalid the first time it processed that block but returned a
  generic "duplicate" rejection message on subsequent occasions it
  processed the same block.  It now always returns the fundamental
  reason for rejecting an invalid block and only returns "duplicate" for
  valid blocks it has already accepted.

- A new `submitheader` RPC allows submitting block headers independently
  from their block.  This is likely only useful for testing.

Configuration
-------------

- The `-usehd` configuration option was removed in version 0.16. From
  that version onwards, all new wallets created are hierarchical
  deterministic wallets. This release makes specifying `-usehd` an
  invalid configuration option.

Changes for particular platforms
--------------------------------

- On macOS, Bitcoin Core now opts out of application CPU throttling
  ("app nap") during initial blockchain download, when catching up from
  over 100 blocks behind the current chain tip, or when reindexing chain
  data.  This helps prevent these operations from taking an excessively
  long time because the operating system is attempting to conserve
  power.

Credits
=======

Thanks to everyone who directly contributed to this release:

(todo)
=======
(to be filled in at release time)
>>>>>>> ea2e39fd2004e83375c1703543e32a10e3b9d981
=======
- Andrew Chow
- Chun Kuan Lee
- David A. Harding
- Eric Scrivner
- fanquake
- fridokus
- Glenn Willen
- Gregory Sanders
- gustavonalle
- John Newbery
- Jon Layton
- Jonas Schnelli
- João Barbosa
- Kaz Wesley
- Kvaciral
- Luke Dashjr
- MarcoFalke
- MeshCollider
- Pieter Wuille
- practicalswift
- Russell Yanofsky
- Sjors Provoost
- Suhas Daftuar
- Tim Ruffing
- Walter
- Wladimir J. van der Laan
>>>>>>> 0.17

As well as everyone that helped translating on [Transifex](https://www.transifex.com/projects/p/digibyte/).
