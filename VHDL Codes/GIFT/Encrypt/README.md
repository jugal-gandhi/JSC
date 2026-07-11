# GIFT-64 Encryption Core — `gift64.vhd`

## Entity Interface

| Port | Direction | Width | Function |
|---|---|---|---|
| `clk` | in | 1 | System clock |
| `reset` | in | 1 | Synchronous active-high reset |
| `enin` | in | 1 | Enable for the plaintext input register |
| `enk` | in | 1 | Enable for the key register and round counter |
| `GIFT_input` | in | 64 | Plaintext block |
| `key_input` | in | 128 | Master key |
| `GIFT_output` | out | 8 | Ciphertext, released 8 bits per clock cycle |

`GIFT_output` streams the 64-bit ciphertext as eight sequential bytes rather than as a single parallel word. The `bit8_out` and `loadouput` processes handle this serialization after round processing completes.

## Submodules Instantiated

- `sbox` (×16) — one per 4-bit nibble of the 64-bit state.
- `perm` (×1) — full 64-bit bit permutation.
- `lfsr` (×1) — 6-bit round-constant generator.

## Internal Datapath, Stage by Stage

### 1. Plaintext loading (`load_input` process)
On `enin='1'`, `ld_in='1'` loads `GIFT_input` into `input_8bit`. When `ld_in='0'`, `input_8bit` instead reloads from `out_reg`, the output of the current round — this is the mechanism that feeds the round output back as the next round's input, rather than a separate round register.

### 2. Key loading and update (`key_generation` process)
On `enk='1'`, `ld_key='1'` loads `key_input` into the 128-bit `round_key` register. When `ld_key='0'`, the register instead updates by the expression:

```
round_key <= round_key(17 downto 16) & round_key(31 downto 18)
           & round_key(11 downto 0)  & round_key(15 downto 12)
           & round_key(127 downto 32);
```

This reassembles the low 32 bits of the key state with a 2-bit/12-bit/2-bit split-and-rotate pattern before concatenating the untouched upper 96 bits. The two round-key words consumed each round, `k0` and `k1`, are taken directly from `round_key(15 downto 0)` and `round_key(31 downto 16)`.

### 3. Substitution layer
`input_8bit` splits into sixteen 4-bit nibbles, each routed to its own `sbox` instance (`s0`–`s15`), producing `sbox_out`.

### 4. Permutation layer
`sbox_out` passes through the single `perm` instance, producing `p_out` (64-bit bit-level reordering; see `perm.vhd` below for the exact bit mapping).

### 5. Round-constant addition (`add_roundconst` process)
When `add_rc='1'`, six bits of `p_out` (bit 63 and bits 3, 7, 11, 15, 19, 23) are XORed with a constant `'1'` (bit 63) and with the six bits of `r_const` from the LFSR (`r0`–`r6`). When `add_rc='0'`, all six correction signals are forced to `'0'`, effectively disabling this stage. The results are reassembled into `rc_out` by the concurrent signal assignment following the process.

### 6. Round-key addition (`roundkey_addition` process)
When `add_rk='0'`, `out_reg` is forced to all zeros. When `add_rk='1'`, the process XORs `k1` into the odd-indexed bit of each nibble and `k0` into the even-indexed bit, for all 16 nibbles, via the loop:

```vhdl
for i in 15 downto 0 loop
  out_reg(4*i+1) <= rc_out(4*i+1) xor k1(i);
  out_reg(4*i)   <= rc_out(4*i)   xor k0(i);
end loop;
```

The remaining two bits of each nibble pass through from `rc_out` unmodified (explicit assignments for bits 2–3 of each nibble across all 16 nibbles).

### 7. Output serialization (`bit8_out` and `loadouput` processes)
Once `rounds_complete='1'`, `out_txt` left-shifts by 8 bits per clock cycle (padding with zeros), and `loadouput` latches the top byte of `out_txt` into `GIFT_output` whenever `done='1'`. This produces the byte-serial ciphertext output described above.

## Control Path

### Round counter (`counter` process)
A free-running counter `count` increments on every clock cycle where `enk='1'`, wrapping from 39 back to 0. It does not count rounds 1:1; it counts clock cycles across the full load/round/output sequence, and the FSM below reads specific count values as state-transition triggers.

### FSM states

| State | Entered when | Key control outputs | Function |
|---|---|---|---|
| `st0` | `count=0` (idle) | all control signals low | Idle/reset-held state |
| `st1` | any transition out of `st0` | `ld_in=1`, `ld_key=1`, `ld_rc=1` | Loads plaintext, key, and clears round-constant register |
| `st2` | unconditional from `st1`; held while `count<30` | `en_sbpm=1`, `ld_rc=1`, `add_rc=1`, `add_rk=1` | Active round processing (S-box, permutation, round-constant and round-key addition all enabled) |
| `st3` | `count=30`; held while `count<39` | `rounds_complete=1`, `done=1` | Output-serialization state |

The transition back to `st0` occurs at `count=39`, closing the load → round → output cycle.

**Reproducibility note:** the counter thresholds (30, 39) are hard-coded and are not derived from the stated 28-round cipher specification inside the file. A reader cannot confirm from this file alone that 28 GIFT rounds execute between `count=0` and `count=30`; that mapping needs to be verified against the LFSR round-constant sequence length or documented separately.

## Submodules

### `sbox.vhd` — Forward S-box
Purely combinational, gated by `enable`. Each of the four output bits is defined as a sum-of-products (AND/OR/NOT) expression over the four input bits, implementing the GIFT S-box lookup table directly in gate-level Boolean logic rather than as a `case`/lookup-table construct. `enable='0'` forces the output to `"0000"`.

### `perm.vhd` — Forward bit permutation
Purely combinational, gated by `enable`. Implements the 64-bit GIFT bit permutation as 64 individual signal assignments of the form `temp(destination_index) <= perm_in(source_index)`. `enable='0'` forces the output to all zeros.

### `lfsr.vhd` — Round-constant generator
A 6-bit Fibonacci-style LFSR with XNOR feedback (`temp := y(5) xnor y(4)`), advancing one bit per clock cycle when `enable='1'` and `ld_rc='1'`. When `ld_rc='0'`, the register is held at `"000000"` rather than freezing at its last value — this is a reset-to-zero, not a hold.

*The authors thank J. Apoorva for her contribution to developing this baseline VHDL implementation.*

