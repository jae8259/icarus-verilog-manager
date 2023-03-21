#!/bin/bash
function appendDump() {
    file_path="$1"
    dir_path="$(dirname "$file_path")"
    file_name="$(basename "$file_path")"
    file_base="${file_name%.*}"
    module_name=$(echo "$file_base" | tr '[:upper:]' '[:lower:]')

    if grep -q "endmodule" "$file_path"; then
        gsed -i "/endmodule/i initial begin \$dumpfile(\"waveforms/$file_base.vcd\") ;\$dumpvars(0, $module_name) ; end" "$file_path"
        echo "Dump added to $file_path"
    else
        echo "No endmodule found in $file_path"
    fi
}

function appendTime() {
    file_path=$1
    dir_path=$(dirname "$file_path")
    file_name=$(basename "$file_path")
    file_base="${file_name%.*}"
    test_time=$2

    if grep -q "endmodule" "$file_path"; then
        gsed -i "/endmodule/i initial begin #($test_time) \$finish; end" $file_path
        echo "Simulation added to $file_path"
    else
        echo "No endmodule found in $file_path"
    fi
}

function gatherFiles() {
    if [ $# -eq 0 ]; then
        # No command-line arguments provided, run all commands except wildcard
        for cmd in results tests waveforms; do
            if [ "$cmd" != "*" ]; then
                "$0" gather "$cmd"
            fi
        done
    else
        # Command-line argument provided, run specified command
        case "$1" in
        waveforms)
            mv -f *.vcd ./waveforms 2>/dev/null
            echo "Moved waveforms"
            ;;
        *)
            echo "Command not found"
            exit 1
            ;;
        esac
    fi
}

function runIverilog() {
    file_name=$(basename -- "$1")
    dir_name=$(dirname -- "$1")
    error_log_path=errors/${file_name%.*}.log
    iverilog -y ${dir_name} -o runs/${file_name%.*} ${1} 2>$error_log_path &
    wait
    if [ -s $error_log_path ]; then
        echo "Error: Icarus Verilog failed"
        cat $error_log_path
    else
        echo "Compiled ${1}"
        vvp runs/${file_name%.*}
    fi
}

case "$1" in
init)
    mkdir {runs,errors,waveforms} 2>/dev/null
    echo "Initiate as iverilog project"
    ;;
gather)
    if [ -n "$2" ]; then
        gatherFiles "$2"
    else
        gatherFiles 2>/dev/null
        echo "Moved files"
    fi
    ;;
run)
    shift # shift past the "run" command
    # set default time value
    test_time=""
    # check for optional "-t" flag
    if [ "$1" == "-t" ]; then
        test_time="$2"
        shift # shift past the "-t" flag
        shift # shift past the time value argument
    fi
    file_path="$1"
    if [ ! -e "$file_path" ]; then
        echo "ivm run: $file_path: No such file or directory"
        exit 1
    fi

    cp "$file_path" "$file_path.bak" &
    wait

    appendDump "$file_path" 1>/dev/null
    if [ ! -z $test_time ]; then
        appendTime "$file_path" "$test_time" 1>/dev/null
    fi
    runIverilog "$file_path"

    # restore original content
    cp "$file_path.bak" "$file_path" &
    wait
    rm $file_path.bak
    ;;

open)
    open -a gtkwave.app $2
    ;;

*)
    echo "Command not found"
    exit 1
    ;;
esac
