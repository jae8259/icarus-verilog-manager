Iveirlog Manager

# Dependency :

brew install gnu-sed
brew install icarus-verilog
brew install gtkwave

1. Initialize folder to iverilog project.
   `./ivm.sh init`
   This will make folder structure as below.
   ```
   |- modules
   |- results
   |- runs
   |- tests
   |- waveforms
   ```
   modules: verilog files without suffix `_tb`
   reuslts: files with extension `.txt`
   runs: compiled files. files without extension
   tests: verilog files with suffix `\_tb`
   waveforms: files with extension `.vcd`
2. You can organize files with the command `./ivm.sh run gather $0`. It will gather all files
3. 테스트벤치는 이름이 똑같아야 됨
