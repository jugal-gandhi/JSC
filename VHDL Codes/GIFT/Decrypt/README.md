# GIFT-64 Decryption Core — `giftdecrypt.vhd`

## Entity Interface

| Port | Direction | Width | Function |
|---|---|---|---|
| `clk` | in | 1 | System clock |
| `reset` | in | 1 | Synchronous active-high reset |
| `enable_decrypt` | in | 1 | Enable for the ciphertext input register |
| `decrypt_in` | in | 64 | Ciphertext block |
| `decrypt_out` | out | 8 | Plaintext, released 8 bits per clock cycle |
| `decrypt_key` | in | 128 | Master key |

As with the encryption core, `decrypt_out` streams the 64-bit plaintext as eight sequential bytes (`bit8_out` / `loadouput` processes), not as one parallel word.

## Submodules Instantiated

- `key_gen` (×1) — key-schedule update, structurally identical to the inline key-update logic in `gift64.vhd`, but factored into a standalone module here.
- `key_ram` (×1) — 28-entry × 128-bit RAM storing every round key.
- `rc_ram` (×1) — 28-entry × 6-bit RAM storing every round constant.
- `lfsr` (×1) — 6-bit round-constant generator (decrypt-specific variant; see below).
- `inverse_perm` (×1) — inverse 64-bit bit permutation.
- `inverse_sbox` (×16) — one per 4-bit nibble.

## Architectural Difference from the Encryption Core

The encryption core (`gift64.vhd`) computes the round key and round constant for the *current* round only, on the fly, each cycle. The decryption core instead **pre-computes and stores all 28 round keys and round constants in `key_ram`/`rc_ram` before round processing starts**, then reads them back in reverse order during the round loop (via the down-counting `address` signal). This is because GIFT decryption consumes round keys in the reverse of the order the encryption schedule generates them; storing the full sequence in RAM and indexing backward avoids re-deriving the schedule in reverse algebraically. This asymmetry is real in the source, not a documentation inconsistency — the two cores are not structural mirrors of each other.

## Internal Datapath, Stage by Stage

### 1. Ciphertext loading (`loadinput` process)
On `enable_decrypt='1'`, `ld_reg='1'` loads `decrypt_in` into `in_reg`. When `ld_reg='0'`, `in_reg` instead reloads from `output`, the current round's S-box output — the round-to-round feedback path.

### 2. Address counter for key/constant RAM (`counter_1` process)
A dedicated counter `count_1` (0–27) increments or decrements depending on `upcount`, wrapping at both ends (27→0 going up, 0→27 going down). The current value drives `address`, which indexes both `key_ram` and `rc_ram`. This counter runs independently of the main round counter (`count_2`) and its direction is what implements the reversed key/constant read order described above.

### 3. Round-key precomputation and storage
`key_gen` updates `round_key` using the identical rotate expression found in the encryption core's `key_generation` process. `key_ram` captures each successive value at the address given by `count_1`, with `en_ram`/`rw` (write-enable) controlled by the FSM below.

### 4. Round-constant precomputation and storage
`lfsr` (decrypt variant) advances the 6-bit round-constant register on `ld_rc='1'`; unlike the encryption core's LFSR, this variant has no separate `enable` port — `ld_rc` alone gates both the advance and the reset-to-zero behavior. `rc_ram` stores each value analogously to `key_ram`.

### 5. Round-key addition (`roundkey_addition` process)
Unlike the encryption core, this process has no `add_rk` gating condition — it executes unconditionally, XORing `k1` into the odd bit and `k0` into the even bit of each of the 16 nibbles of `in_reg`, producing `out_reg`. The remaining two bits per nibble pass through unmodified, as in the encryption core.

### 6. Round-constant removal
Six correction bits (`r0`–`r6`) are computed directly as concurrent signal assignments (not inside a gated process, unlike the encryption core's `add_roundconst` process) — this stage is always active in the decryption core, with no `add_rc` equivalent signal. `perm_in` is assembled from `out_reg` with these six bits substituted in, mirroring the position mapping used in the encryption core's `rc_out` assembly.

### 7. Inverse permutation
`inverse_perm` maps `perm_in` to `p_out`, undoing the forward permutation using the inverse index mapping (see `inverse_perm.vhd` below).

### 8. Inverse substitution
Sixteen `inverse_sbox` instances map `p_out` nibbles to the `output` signal, undoing the forward S-box.

### 9. Output serialization
Identical structure to the encryption core: `bit8_out` shifts `out_txt` by 8 bits per cycle once `rounds_complete='1'`, and `loadouput` latches the top byte into `decrypt_out` when `done='1'`.

## Control Path

### Round counter (`counter_2` process)
Free-running counter `count_2`, 0 to 68, wrapping back to 0. As with the encryption core's `count`, this counts clock cycles across the full sequence, not cipher rounds directly.

### FSM states

| State | Entered when | Key control outputs | Function |
|---|---|---|---|
| `st0` | reset / idle | all control signals low | Idle state |
| `st1` | unconditional from `st0` | `rw=1`, `ld_key=1`, `ld_rc=1`, `en_ram=1`, `en_keygen=1` | Loads the master key and begins writing the first round key/constant into RAM |
| `st2` | unconditional from `st1`; held while `count_2<29` | `ld_reg=1`, `upcount=1`, `rw=1`, `ld_rc=1`, `en_ram=1`, `en_count=1`, `en_keygen=1` | Loads ciphertext and continues writing all round keys/constants into RAM in ascending address order |
| `st3` | `count_2=29`; held while `count_2<31` | `ld_reg=1`, `en_count=1` | Transition/settle state between the write and read phases of the key/constant RAM |
| `st4` | `count_2=31`; held while `count_2<59` | `en_sbpm=1`, `en_ram=1`, `en_count=1` | Active round processing (inverse permutation and inverse substitution enabled); `upcount` is not asserted here, so `count_1` is decrementing — reading `key_ram`/`rc_ram` in reverse |
| `st5` | `count_2=59`; held while `count_2<68` | `en_ram=1`, `en_count=1`, `rounds_complete=1`, `done=1` | Output-serialization state |

The transition back to `st0` occurs at `count_2=68`.

**Reproducibility note:** as with the encryption core, the specific count thresholds (29, 31, 59, 68) are hard-coded and their correspondence to a 28-round GIFT schedule is not derived in-file from any parameter; it is asserted here from cipher-specification knowledge rather than shown by the code.

## Submodules

### `inverse_sbox.vhd`
Purely combinational, gated by `enable`. Implements the inverse GIFT S-box as sum-of-products Boolean expressions, structurally parallel to `sbox.vhd` but with inverted input/output correspondence. `enable='0'` forces the output to `"0000"`.

### `inverse_perm.vhd`
Purely combinational, gated by `enable`. Implements the inverse of the 64-bit bit permutation in `perm.vhd` as 64 individual signal assignments; the source/destination indices are the exact inverse mapping of `perm.vhd`. `enable='0'` forces the output to all zeros.

### `key_gen.vhd`
Standalone version of the key-update logic embedded inline in the encryption core. Same rotate expression, same load/update behavior, gated separately by `ld_key` and `en_key`.

### `key_ram.vhd`
Simple synchronous read/write memory, 28 entries of 128 bits, single address port shared between read and write (`cs`/`we`-gated). No dual-port or read-during-write protection is implemented; the FSM's `rw` signal is responsible for ensuring reads and writes never collide in the same cycle.

### `rc_ram.vhd`
Identical structure to `key_ram.vhd`, sized for 28 entries of 6 bits (round constants) instead of 128-bit round keys.

### `lfsr.vhd` (decrypt variant)
6-bit XNOR-feedback LFSR, structurally similar to the encryption core's LFSR but with `ld_rc` as the sole gating signal (no separate `enable` port), and with the register reset to `"000000"` whenever `ld_rc='0'`, matching the encryption variant's reset-to-zero-on-disable behavior.

*The authors thank J. Apoorva for her contribution to developing this baseline VHDL implementation.*
