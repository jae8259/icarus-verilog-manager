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
        for cmd in tests waveforms; do
            if [ "$cmd" != "*" ]; then
                "$0" gather "$cmd"
            fi
        done
    else
        # Command-line argument provided, run specified command
        case "$1" in
        modules)
            find . -type f \( -name '*.v' -o -name '*.sv' \) |
                grep -v '_tb' -v '_TB' |
                xargs -I{} mv {} ./modules 2>/dev/null
            echo "Moved modules"
            ;;
        tests)
            find . -type f \( -name '*.v' -o -name '*.sv' \) |
                grep -e '_tb' -e '_TB' |
                xargs -I{} mv {} ./tests 2>/dev/null
            echo "Moved tests"
            ;;
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
    file_path=$1
    library_path=$2
    file_name=$(basename -- "$file_path")
    dir_name=$(dirname -- "$file_path")
    error_log_path=errors/${file_name%.*}.log

    if [ -z $library_path ]; then
        library_path="."
    fi

    iverilog -y ${library_path} -o runs/${file_name%.*} $file_path 2>$error_log_path &
    wait
    if [ -s $error_log_path ]; then
        echo "Error: Icarus Verilog failed"
        cat $error_log_path
    else
        echo "Compiled $file_path"
        vvp runs/${file_name%.*}
    fi
}

case "$1" in
init)
    mkdir {errors,modules,runs,tests,waveforms} 2>/dev/null
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
    library_path=""
    while getopts "t:y:" opt; do
        case $opt in
        t)
            test_time=$OPTARG
            ;;
        y)
            library_path=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        esac
    done

    shift $((OPTIND - 1))

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
    runIverilog "$file_path" "$library_path"

    # restore original content
    cp "$file_path.bak" "$file_path" &
    wait
    rm $file_path.bak
    ;;

open)
    open -a gtkwave.app $2
    ;;

*)
    echo "ivm : Command not found"
    exit 1
    ;;
esac
