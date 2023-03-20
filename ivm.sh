#!/bin/bash
function appendDump(){
    file_path="$1"
    dir_path="$(dirname "$file_path")"
    file_name="$(basename "$file_path")"
    file_base="${file_name%.*}"
    module_name=$(echo "$file_base" | tr '[:upper:]' '[:lower:]')

    if grep -q "endmodule" "$file_path"; then
        # TODO: better dumpfile directory
        gsed -i "/endmodule/i initial begin \$dumpfile(\"waveforms/$module_name.vcd\") ;\$dumpvars(0, $module_name) ; end" "$file_path";
        echo "Dump added to $file_path"
    else
        echo "No endmodule found in $file_path"
    fi
}

function appendTime(){
    file_path=$1
    dir_path=$(dirname "$file_path")
    file_name=$(basename "$file_path")
    file_base="${file_name%.*}"
    test_time=$2

    if grep -q "endmodule" "$file_path"; then
        gsed -i "/endmodule/i initial begin #($test_time) \$finish; end" $file_path;
        echo "Simulation added to $file_path"
    else
        echo "No endmodule found in $file_path"
    fi
}

function gatherFiles(){
    if [ $# -eq 0 ]; then
  # No command-line arguments provided, run all commands except wildcard
    for cmd in modules results tests waveforms; do
        if [ "$cmd" != "*" ]; then
            "$0" gather "$cmd"
        fi
    done
    else
    # Command-line argument provided, run specified command
        case "$1" in
            modules)
                find . -type f \( -name '*.v' -o -name '*.sv' \) \
                | grep -v '_tb' -v '_TB' \
                | xargs -I{} mv {} ./modules 2>/dev/null
                echo "Moved modules"
                ;;
            results)
                find . -type f -name '*_result.txt' \
                -exec mv {} ./results \; 2>/dev/null
                echo "Moved results"
                ;;
            tests)
                find . -type f \( -name '*.v' -o -name '*.sv' \) \
                | grep -e '_tb' -e '_TB' \
                | xargs -I{} mv {} ./modules 2>/dev/null
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

function runIverilog(){
    filename=$(basename -- "$1")
    dirname=$(dirname -- "$1")
    iverilog -y ${dirname} -o run/${filename%.*} ${1}
    echo "Compiled ${1}" &
    vvp run/${filename%.*}
}

case "$1" in
    init)
        mkdir {modules,results,runs,tests,waveforms} 2>/dev/null
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
            echo "ivm rum: $file_path: No such file or directory"
            exit 1
        fi

        cp "$file_path" "$file_path.bak"

        appendDump "$file_path" 1>/dev/null
        if [ ! -z $test_time ]; then
            appendTime "$file_path" 1>/dev/null "$test_time"
        fi
        runIverilog "$file_path"

        # restore original content
        cp "$file_path.bak" "$file_path"
        rm $file_path.bak &
        ;;

    open) 
        open -a gtkwave.app $2
        ;;
        
    *)
        echo "Command not found"
        exit 1
        ;;
esac
