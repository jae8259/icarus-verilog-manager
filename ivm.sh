#!/bin/bash
function appendDump(){
    file_path="$1"
    dir_path="$(dirname "$file_path")"
    file_name="$(basename "$file_path")"
    file_base="${file_name%.*}"

    if grep -q "endmodule" "$file_path"; then
        # TODO: better dumpfile directory
        gsed -i "/endmodule/i initial begin \$dumpfile(\"waveforms/$file_base.vcd\") ;\$dumpvars(0, $file_base) ; end" "$file_path";
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

case "$1" in
    init)
        mkdir {modules,results,runs,tests,waveforms} 2>/dev/null
        echo "Initiate as iverilog project"
        ;;
    gather)
        if [ -n "$2" ]; then
            ./gatherFiles.sh "$2"
        else
            ./gatherFiles.sh 2>/dev/null
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
        ./runIverilog.sh "$file_path"

        # restore original content
        cp "$file_path.bak" "$file_path"
        rm $file_path.bak &
        ;;
    *)
        echo "Command not found"
        exit 1
        ;;
esac
