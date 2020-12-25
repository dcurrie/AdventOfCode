

# The handshake used by the card and the door involves an operation that
# transforms a subject number. To transform a subject number, start with
# the value 1. Then, a number of times called the loop size, perform the
# following steps:
#
# Set the value to itself multiplied by the subject number.
# Set the value to the remainder after dividing the value by 20201227.
#
# The card always uses a specific, secret loop size when it transforms a
# subject number. The door always uses a different, secret loop size.
#
# So, transform(subject) = subject^loopsize mod 20201227

# The cryptographic handshake works like this:
#
# The card transforms the subject number of 7 according to the card's secret loop size. The result is called the card's public key.
# The door transforms the subject number of 7 according to the door's secret loop size. The result is called the door's public key.
# The card and door use the wireless RFID signal to transmit the two public keys (your puzzle input) to the other device. Now, the card has the door's public key, and the door has the card's public key. Because you can eavesdrop on the signal, you have both public keys, but neither device's loop size.
# The card transforms the subject number of the door's public key according to the card's loop size. The result is the encryption key.
# The door transforms the subject number of the card's public key according to the door's loop size. The result is the same encryption key as the card calculated.

# use the two public keys to determine each device's loop size

proc modular_pow(base_in, exponent_in, modulus: int): int =
    if modulus == 1:
        return 0
    # Assert :: (modulus - 1) * (modulus - 1) does not overflow base
    result = 1
    var base = base_in mod modulus
    var exponent = exponent_in
    while exponent > 0:
        if (exponent mod 2 == 1):
            result = (result * base) mod modulus
        exponent = exponent div 2
        base = (base * base) mod modulus

proc part1(key1, key2: int): (int,int) =
    var lp1 = 0
    var lp2 = 0
    var ept = 1
    var val = 7
    while lp1 == 0 or lp2 == 0:
        ept += 1
        val = (val * 7) mod 20201227
        if val == key1: lp1 = ept
        if val == key2: lp2 = ept
    result = (modular_pow(key2,lp1,20201227), modular_pow(key1,lp2,20201227))

echo("Part 1 ex: ", part1(5764801, 17807724))
echo("Part 1   : ", part1(9789649, 3647239))
