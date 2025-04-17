# Viterbi Decoder (Hard Decision) for Convolutional Codes

This project implements a Viterbi Decoder using hard decision decoding for a convolutionally encoded binary data stream. The decoder is tailored for a constraint length 3 convolutional encoder with generator polynomials:

- **g1 = 110**
- **g2 = 111**

## 🧠 Problem Overview

Given a sequence of received 2-bit encoded symbols, the decoder:
- Builds a trellis based on the state transitions and encoder outputs.
- Uses the **Viterbi algorithm** to trace the most likely input bit sequence based on **minimum Hamming distance**.
- Supports path metric calculation and traceback to recover the original input message.

## ✅ Example

**Received encoded sequence (hard decision):**
01 11 01 11 01 01 11

pgsql
Copy
Edit

**Decoded input sequence:**
0 1 0 0 1 0 0
