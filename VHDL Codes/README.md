# GIFT-64 VHDL Reference Implementation — Overview

## Purpose

This repository contains a baseline (non-obfuscated) VHDL implementation of the GIFT-64-128 lightweight block cipher, separated into an encryption core and a decryption core. The two cores share the cipher's algebraic structure (4-bit S-box, 64-bit bit permutation, 128-bit key schedule, 6-bit LFSR-based round-constant generator) but differ in control-path organization and round-key delivery.

## Repository Layout

```
VHDL Codes/
├── Encrypt/
│   ├── gift64.vhd        Top-level encryption core (datapath + FSM controller)
│   ├── sbox.vhd           Forward 4-bit GIFT S-box (combinational)
│   ├── perm.vhd            Forward 64-bit bit permutation layer
│   ├── lfsr.vhd             6-bit round-constant generator
└── Decrypt/
    ├── giftdecrypt.vhd      Top-level decryption core (datapath + FSM controller)
    ├── inverse_sbox.vhd  Inverse 4-bit GIFT S-box (combinational)
    ├── inverse_perm.vhd  Inverse 64-bit bit permutation layer
    ├── key_gen.vhd            Key-schedule update module (used standalone in decryption)
    ├── key_ram.vhd           Round-key storage RAM (28 entries × 128 bits)
    ├── rc_ram.vhd              Round-constant storage RAM (28 entries × 6 bits)
    ├── lfsr.vhd                    6-bit round-constant generator (decrypt variant)
```

## Core Parameters

| Parameter | Value |
|---|---|
| Block size | 64 bits |
| Key size | 128 bits |
| Round count | 28 |
| S-box width | 4 bits (16 parallel instances per round) |
| Round-constant generator | 6-bit Fibonacci LFSR, XNOR feedback |
| Key-schedule update | 32-bit rotate of the active key word, per round |

