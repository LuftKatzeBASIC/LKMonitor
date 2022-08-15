```
##       ##    ##         ##     ##  #######  ##    ## #### ########  #######  ########  
##       ##   ##          ###   ### ##     ## ###   ##  ##     ##    ##     ## ##     ## 
##       ##  ##           #### #### ##     ## ####  ##  ##     ##    ##     ## ##     ## 
##       #####    ####### ## ### ## ##     ## ## ## ##  ##     ##    ##     ## ########  
##       ##  ##           ##     ## ##     ## ##  ####  ##     ##    ##     ## ##   ##   
##       ##   ##          ##     ## ##     ## ##   ###  ##     ##    ##     ## ##    ##  
######## ##    ##         ##     ##  #######  ##    ## ####    ##     #######  ##     ##
```

Resident Monitor for IBM PC/XT 5160

#### Tested on:
- qemu (i386) -fda (`st` returns 0x20 - Controller failure)
- emu8086 (100% works)
- PCjs (100% works)
- DosBOX (100% works)

## Commands
[] - optional param, {} - required param

- `?[XXXX]` show memory content.
- `>[XXXX]` add [XXXX] to address pointer (One if [XXXX] not provided.
- `<[XXXX]` subtract [XXXX] from address pointer (One if [XXXX] not provided).
- `ld{XXXX}` load sector {XXXX} from disk to current address.
- `st{XXXX}` store 512 bytes from current address on sector XXXX} of disk.
- `.{string}` store {string} at current address (Null-terminated). Accepts `*n` as 13,10 and `**` as `*`.
- `#[XXXX]`start executing code from [XXXX] (Current address if [XXXX] not provided).
- `={XXXX}` set address pointer to {XXXX}.
- `{XX...}` store {XX...} at current position.

## How to make image from source

### Linux
```
nasm ldr.asm -f bin -o ldr.bin
nasm mon.asm -f bin -o mon.bin
cat ldr.bin mon.bin > mon.img
```
### Windows / MS/DR/Free/PC DOS
```
nasm ldr.asm -f bin -o ldr.bin
nasm mon.asm -f bin -o mon.bin
type ldr.bin mon.bin > mon.img
```
