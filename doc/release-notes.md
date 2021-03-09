*After branching off for a major version release of Auroracoin, use this
template to create the initial release notes draft.*

*The release notes draft is a temporary file that can be added to by anyone. See
[/doc/developer-notes.md#release-notes](/doc/developer-notes.md#release-notes)
for the process.*

*Create the draft, named* "*version* Release Notes Draft"
*(e.g. "0.20.0 Release Notes Draft"), as a collaborative wiki in:*

https://github.com/aurarad/Auroracoin/wiki/

*Before the final release, move the notes back to this git repository.*

*version* Release Notes Draft
===============================

Auroracoin version 0.18.1 is now available from:

  <https://bitcoincore.org/bin/bitcoin-core-0.18.1/>

This is a new minor version release, including new features, various bug
fixes and performance improvements, as well as updated translations.

Please report bugs using the issue tracker at GitHub:

  <https://github.com/auraras/Auroracoin/issues>

To receive security and update notifications, please subscribe to:

  <https://bitcoincore.org/en/list/announcements/join/>

How to Upgrade
==============

If you are running an older version, shut it down. Wait until it has
completely shut down (which might take a few minutes for older
versions), then run the installer (on Windows) or just copy over
`/Applications/Auroracoin-Qt` (on Mac) or `auroracoind`/`auroracoin-qt` (on
Linux).

The first time you run version 0.15.0 or newer, your chainstate database
will be converted to a new format, which will take anywhere from a few
minutes to half an hour, depending on the speed of your machine.

Note that the block database format also changed in version 0.8.0 and
there is no automatic upgrade code from before version 0.8 to version
0.15.0 or later. Upgrading directly from 0.7.x and earlier without
redownloading the blockchain is not supported.  However, as usual, old
wallet versions are still supported.

Compatibility
==============

Auroracoin is supported and extensively tested on operating systems
using the Linux kernel, macOS 10.10+, and Windows 7 and newer. It is not
recommended to use Auroracoin on unsupported systems.

Auroracoin should also work on most other Unix-like systems but is not
as frequently tested on them.

From 0.17.0 onwards, macOS <10.10 is no longer supported. 0.17.0 is
built using Qt 5.9.x, which doesn't support versions of macOS older than
10.10. Additionally, Auroracoin does not yet change appearance when
macOS "dark mode" is activated.

Network
-------

- When fetching a transaction announced by multiple peers, previous versions of
  Auroracoin would sequentially attempt to download the transaction from each
  announcing peer until the transaction is received, in the order that those
  peers' announcements were received.  In this release, the download logic has
  changed to randomize the fetch order across peers and to prefer sending
  download requests to outbound peers over inbound peers. This fixes an issue
  where inbound peers can prevent a node from getting a transaction.

New RPCs
--------

- A new `setwalletflag` RPC sets/unsets flags for an existing wallet.

Updated RPCs
------------

- Several RPCs have been updated to include an "avoid_reuse" flag, used
  to control whether already used addresses should be left out or
  included in the operation.  These include:

    - createwallet
    - getbalance
    - getbalances
    - sendtoaddress

  In addition, `sendtoaddress` has been changed to avoid partial spends
  when `avoid_reuse` is enabled (if not already enabled via the
  `-avoidpartialspends` command line flag), as it would otherwise risk
  using up the "wrong" UTXO for an address reuse case.

  The listunspent RPC has also been updated to now include a "reused"
  bool, for nodes with "avoid_reuse" enabled.

- The `getblockstats` RPC is faster for fee calculation by using
  BlockUndo data. Also , `-txindex` is no longer required and
  `getblockstats` works for all non-pruned blocks.

- `createwallet` can now create encrypted wallets if a non-empty
  passphrase is specified.

- The `utxoupdatepsbt` RPC method has been updated to take a
  `descriptors` argument. When provided, input and output scripts and
  keys will be filled in when known, and P2SH-witness inputs will be
  filled in from the UTXO set when a descriptor is provided that shows
  they're spending segwit outputs.

  See the RPC help text for full details.

- The -maxtxfee setting no longer has any effect on non-wallet RPCs.

  The `sendrawtransaction` and `testmempoolaccept` RPC methods previously
  accepted an `allowhighfees` parameter to fail the mempool acceptance in case
  the transaction's fee would exceed the value of the command line argument
  `-maxtxfee`. To uncouple the RPCs from the global option, they now have a
  hardcoded default for the maximum transaction fee, that can be changed for
  both RPCs on a per-call basis with the `maxfeerate` parameter. The
  `allowhighfees` boolean option has been removed and replaced by the
  `maxfeerate` numeric option.

- In getmempoolancestors, getmempooldescendants, getmempoolentry and
  getrawmempool RPCs, to be consistent with the returned value and other
  RPCs such as getrawtransaction, vsize has been added and size is now
  deprecated. size will only be returned if bitcoind is started with
  `-deprecatedrpc=size`.

- The RPC `getwalletinfo` response now includes the `scanning` key with
  an object if there is a scanning in progress or `false` otherwise.
  Currently the object has the scanning duration and progress.

- `createwallet` now returns a warning if an empty string is used as an
  encryption password, and does not encrypt the wallet, instead of
  raising an error.  This makes it easier to disable encryption but also
  specify other options when using the `bitcoin-cli` tool.

- `getmempoolentry` now provides a `weight` field containing the
  transaction weight as defined in BIP 141.

Deprecated or removed RPCs
--------------------------

- The `totalFee` option of the `bumpfee` RPC has been deprecated and will be
  removed in 0.20.  To continue using this option start with
  `-deprecatedrpc=totalFee`.  See the `bumpfee` RPC help text for more details.

P2P changes
-----------

- BIP 61 reject messages were deprecated in v0.18. They are now disabled
  by default, but can be enabled by setting the `-enablebip61` command
  line option.  BIP 61 reject messages will be removed entirely in a
  future version of Bitcoin Core.

- The default value for the -peerbloomfilters configuration option (and,
  thus, NODE_BLOOM support) has been changed to false.  This resolves
  well-known DoS vectors in Bitcoin Core, especially for nodes with
  spinning disks. It is not anticipated that this will result in a
  significant lack of availability of NODE_BLOOM-enabled nodes in the
  coming years, however, clients which rely on the availability of
  NODE_BLOOM-supporting nodes on the P2P network should consider the
  process of migrating to a more modern (and less trustful and
  privacy-violating) alternative over the coming years.

Miscellaneous CLI Changes
-------------------------
- The `testnet` field in `bitcoin-cli -getinfo` has been renamed to
  `chain` and now returns the current network name as defined in BIP70
  (main, test, regtest).

Low-level changes
=================

RPC
---

- Soft fork reporting in the `getblockchaininfo` return object has been
  updated. For full details, see the RPC help text. In summary:

  - The `bip9_softforks` sub-object is no longer returned
  - The `softforks` sub-object now returns an object keyed by soft fork name,
    rather than an array
  - Each softfork object in the `softforks` object contains a `type`
    value which is either `buried` (for soft fork deployments where the
    activation height is hard-coded into the client implementation), or
    `bip9` (for soft fork deployments where activation is controlled by
    BIP 9 signaling).

- `getblocktemplate` no longer returns a `rules` array containing `CSV`
  and `segwit` (the BIP 9 deployments that are currently in active
  state).

Tests
-----

- The regression test chain, that can be enabled by the `-regtest` command line
  flag, now requires transactions to not violate standard policy by default.
  Making the default the same as for mainnet, makes it easier to test mainnet
  behavior on regtest. Be reminded that the testnet still allows non-standard
  txs by default and that the policy can be locally adjusted with the
  `-acceptnonstdtxn` command line flag for both test chains.

Configuration
-------------

- On platforms supporting `thread_local`, log lines can be prefixed with
  the name of the thread that caused the log. To enable this behavior,
  use `-logthreadnames=1`.

Network
-------

- When creating a transaction with a fee above `-maxtxfee` (default 0.1
  BTC), the RPC commands `walletcreatefundedpsbt` and
  `fundrawtransaction` will now fail instead of rounding down the fee.
  Beware that the `feeRate` argument is specified in BTC per kilobyte,
  not satoshi per byte.

- A new wallet flag `avoid_reuse` has been added (default off). When
  enabled, a wallet will distinguish between used and unused addresses,
  and default to not use the former in coin selection.

  Rescanning the blockchain is required, to correctly mark previously
  used destinations.

  Together with "avoid partial spends" (present as of Bitcoin v0.17),
  this addresses a serious privacy issue where a malicious user can
  track spends by peppering a previously paid to address with near-dust
  outputs, which would then be inadvertently included in future
  payments.

Build system changes
--------------------

- Python >=3.5 is now required by all aspects of the project. This
  includes the build systems, test framework and linters. The previously
  supported minimum (3.4), was E OL in March 2019. See #14954 for more
  details.

- The minimum supported miniUPnPc API version is set to 10. This keeps
  compatibility with Ubuntu 16.04 LTS and Debian 8 `libminiupnpc-dev`
  packages. Please note, on Debian this package is still vulnerable to
  [CVE-2017-8798](https://security-tracker.debian.org/tracker/CVE-2017-8798)
  (in jessie only) and
  [CVE-2017-1000494](https://security-tracker.debian.org/tracker/CVE-2017-1000494)
  (both in jessie and in stretch).



Known issues
============

Wallet GUI
----------

For advanced users who have both (1) enabled coin control features, and
(2) are using multiple wallets loaded at the same time: The coin control
input selection dialog can erroneously retain wrong-wallet state when
switching wallets using the dropdown menu. For now, it is recommended
not to use coin control features with multiple wallets loaded.

0.18.1 change log
=================

### P2P protocol and network code
- #15990 Add tests and documentation for blocksonly (MarcoFalke)
- #16021 Avoid logging transaction decode errors to stderr (MarcoFalke)
- #16405 fix: tor: Call `event_base_loopbreak` from the event's callback (promag)
- #16412 Make poll in InterruptibleRecv only filter for POLLIN events (tecnovert)

### Wallet
- #15913 Add -ignorepartialspends to list of ignored wallet options (luke-jr)

### RPC and other APIs
- #15991 Bugfix: fix pruneblockchain returned prune height (jonasschnelli)
- #15899 Document iswitness flag and fix bug in converttopsbt (MarcoFalke)
- #16026 Ensure that uncompressed public keys in a multisig always returns a legacy address (achow101)
- #14039 Disallow extended encoding for non-witness transactions (sipa)
- #16210 add 2nd arg to signrawtransactionwithkey examples (dooglus)
- #16250 signrawtransactionwithkey: report error when missing redeemScript/witnessScript (ajtowns)

### GUI
- #16044 fix the bug of OPEN CONFIGURATION FILE on Mac (shannon1916)
- #15957 Show "No wallets available" in open menu instead of nothing (meshcollider)
- #16118 Enable open wallet menu on setWalletController (promag)
- #16135 Set progressDialog to nullptr (promag)
- #16231 Fix open wallet menu initialization order (promag).
- #16254 Set `AA_EnableHighDpiScaling` attribute early (hebasto).
- #16122 Enable console line edit on setClientModel (promag).
- #16348 Assert QMetaObject::invokeMethod result (promag)

### Build system
- #15985 Add test for GCC bug 90348 (sipa)
- #15947 Install bitcoin-wallet manpage (domob1812)
- #15983 build with -fstack-reuse=none (MarcoFalke)

### Tests and QA
- #15826 Pure python EC (sipa)
- #15893 Add test for superfluous witness record in deserialization (instagibbs)
- #14818 Bugfix: test/functional/rpc_psbt: Remove check for specific error message that depends on uncertain assumptions (luke-jr)
- #15831 Add test that addmultisigaddress fails for watchonly addresses (MarcoFalke)

### Documentation
- #15890 Remove text about txes always relayed from -whitelist (harding)

### Miscellaneous
- #16095 Catch by reference not value in wallettool (kristapsk)
- #16205 Replace fprintf with tfm::format (MarcoFalke)

Credits
=======

Thanks to everyone who directly contributed to this release:

- Andrew Chow
- Anthony Towns
- Chris Moore
- Daniel Kraft
- David A. Harding
- fanquake
- Gregory Sanders
- Hennadii Stepanov
- John Newbery
- Jonas Schnelli
- João Barbosa
- Kristaps Kaupe
- Luke Dashjr
- MarcoFalke
- MeshCollider
- Pieter Wuille
- shannon1916
- tecnovert
- Wladimir J. van der Laan

As well as everyone that helped translating on [Transifex](https://www.transifex.com/bitcoin/bitcoin/).