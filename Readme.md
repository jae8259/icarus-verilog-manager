Iveirlog Manager

# Dependency :

brew install gnu-sed
brew install icarus-verilog
brew install gtkwave

1. Initialize folder to iverilog project.
   `./ivm.sh init`
   This will make folder structure as below.

   ```
   |- errors
   |- runs
   |- waveforms
   ```

   errors: store error logs
   runs: compiled verilog files
   waveforms: files with extension `.vcd`

2. You can organize files with the command `./ivm.sh run gather $0`. It will gather all files

3. 테스트벤치는 이름이 똑같아야 됨
