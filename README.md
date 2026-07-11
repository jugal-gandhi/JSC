<div align="center">

# Reference Implementation Repository

### Functional Obfuscation of Lightweight Crypto Cores for Improved Security against IP Piracy

**Jugal Gandhi · Diksha Shekhawat · M. Santosh · Jaya Dofe · Jai Gopal Pandey**

![Language](https://img.shields.io/badge/language-VHDL-1abc9c?style=flat-square) ![Status](https://img.shields.io/badge/status-baseline%20release-blue?style=flat-square) ![License](https://img.shields.io/badge/license-academic%20use-lightgrey?style=flat-square) ![Funding](https://img.shields.io/badge/funded%20by-ANRF%20Core%20Research%20Grant-9b59b6?style=flat-square) ![views](https://komarev.com/ghpvc/?username=jugal-gandhi&repo=JSC&style=flat-square&label=views&color=2ecc71)

</div>

---

## Overview

This repository provides the reference VHDL implementation of the original lightweight block cipher architecture used as the baseline during this work. The contents are provided solely as a reference implementation to assist readers in understanding the baseline architecture discussed in the paper. The proposed obfuscation-integrated architectures described in the manuscript were developed from these reference implementations, with additional functional obfuscation modules and security logic layered on top.

---

## Repository Contents

```
GitHub/
├── README.md                       Repository overview (this file)
└── VHDL Codes/
    ├── README.md                   GIFT-64 reference implementation overview
    └── GIFT/
        ├── README.md                Cipher-level summary and test-vector notes
        ├── Encrypt/
        │   ├── README.md            Encryption core documentation
        │   ├── gift64.vhd           Top-level encryption core (datapath + FSM controller)
        │   ├── sbox.vhd             Forward 4-bit GIFT S-box (combinational)
        │   ├── perm.vhd             Forward 64-bit bit permutation layer
        │   └── lfsr.vhd             6-bit round-constant generator
        └── Decrypt/
            ├── README.md            Decryption core documentation
            ├── giftdecrypt.vhd      Top-level decryption core (datapath + FSM controller)
            ├── inverse_sbox.vhd     Inverse 4-bit GIFT S-box (combinational)
            ├── inverse_perm.vhd     Inverse 64-bit bit permutation layer
            ├── key_gen.vhd          Key-schedule update module
            ├── key_ram.vhd          Round-key storage RAM (28 entries x 128 bits)
            ├── rc_ram.vhd           Round-constant storage RAM (28 entries x 6 bits)
            └── lfsr.vhd             6-bit round-constant generator (decrypt variant)
```

---

## Purpose of this Repository
This repository has been created to:
- provide a reference implementation of the original architecture,
- support the architectural descriptions presented in the manuscript,
- serve as a reference for readers interested in the baseline hardware implementation.
---

## Planned Updates
This repository represents the initial public release accompanying the manuscript submission. Additional material may be added over time, including:
- implementation notes,
- architectural documentation,
- module descriptions,
- usage instructions,
- supplementary material,
- and other resources that improve understanding of the published work.

Repository updates will be released periodically as appropriate.

---

## Citation

```bibtex
@article{gandhi2026functional,
  title   = {Functional Obfuscation of Lightweight Crypto Cores for Improved Security against IP Piracy},
  authors = {Jugal Gandhi, Diksha Shekhawat, M. Santosh, Jaya Dofe, and Jai Gopal Pandey},
  year    = {2026}
}
```

---

## Disclaimer

*This repository accompanies the manuscript and is provided to support the architectural descriptions presented in the paper. This repository should not be interpreted as the complete implementation of the obfuscation methodology presented in the paper. The source code serves as the baseline architecture for this work and is intended solely for academic purposes. All rights remain with the respective authors and their affiliated institutions.*

<div align="center">

---

*This is an active repository accompanying a manuscript currently under peer review; content and structure may change before final publication.*
</div>
