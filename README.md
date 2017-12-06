Simple image test program for Barco NX4 led panels.

This is primarily a driver for the Texas Instruments [TLC5941](http://www.ti.com/lit/ds/symlink/tlc5941.pdf) which are used extensively on the Barco NX led panels.

Current status
-------------
#### Features
* Displays an image on the panel WITHOUT dot-correction.
* Uses SRAM instead of 576-1 multiplexers.
* Carefully conforms to TLC5941 timing diagram.
* Syncs XLAT and BLANK at the same time.

#### TODO
* Row synchronization, reset CPLD row counter to zero
* Investigate XERR, when synchronized it has a pulse once per 8 row frame.
* Start with display blanked before loading initial DC and GS data to remove flashing.
* Implement dot correction in romimage.v
* Don't store two dummy rows, just send zeroes.

### Credits
Derived from code developed by Richard Alpin (@DrTune) [BARCO NX-4 GROUP REVERSING ADVENTURE](https://hackaday.io/project/27799-barco-nx-4-group-reversing-adventure).
