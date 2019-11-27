// Copyright (c) 2011-2014 The DigiByte Core developers
// Copyright (c) 2014-2019 The Auroracoin Developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef AURORACOIN_QT_AURORACOINADDRESSVALIDATOR_H
#define AURORACOIN_QT_AURORACOINADDRESSVALIDATOR_H

#include <QValidator>

/** Base58 entry widget validator, checks for valid characters and
 * removes some whitespace.
 */
class AuroracoinAddressEntryValidator : public QValidator
{
    Q_OBJECT

public:
    explicit AuroracoinAddressEntryValidator(QObject *parent);

    State validate(QString &input, int &pos) const;
};

/** Auroracoin address widget validator, checks for a valid auroracoin address.
 */
class AuroracoinAddressCheckValidator : public QValidator
{
    Q_OBJECT

public:
    explicit AuroracoinAddressCheckValidator(QObject *parent);

    State validate(QString &input, int &pos) const;
};

#endif // AURORACOIN_QT_AURORACOINADDRESSVALIDATOR_H
