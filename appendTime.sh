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
