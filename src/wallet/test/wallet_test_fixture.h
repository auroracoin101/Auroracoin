// Copyright (c) 2009-2019 The Bitcoin Core developers
// Copyright (c) 2014-2019 The DigiByte Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef AURORACOIN_WALLET_TEST_WALLET_TEST_FIXTURE_H
#define AURORACOIN_WALLET_TEST_WALLET_TEST_FIXTURE_H

#include <test/test_auroracoin.h>

#include <interfaces/chain.h>
#include <interfaces/wallet.h>
#include <wallet/wallet.h>

#include <memory>

/** Testing setup and teardown for wallet.
 */
struct WalletTestingSetup: public TestingSetup {
    explicit WalletTestingSetup(const std::string& chainName = CBaseChainParams::MAIN);
    ~WalletTestingSetup();

    std::unique_ptr<interfaces::Chain> m_chain = interfaces::MakeChain();
    CWallet m_wallet;
};

#endif // AURORACOIN_WALLET_TEST_WALLET_TEST_FIXTURE_H
