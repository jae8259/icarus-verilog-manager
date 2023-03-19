file_path="$1"
dir_path="$(dirname "$file_path")"
file_name="$(basename "$file_path")"
file_base="${file_name%.*}"

if grep -q "endmodule" "$file_path"; then
    gsed -i "/endmodule/i initial begin \$dumpfile(\"$file_base\") ;\$dumpvars(0, \'$file_base\') ; end" "$file_path";
    echo "Dump added to $file_path"
else
    echo "No endmodule found in $file_path"
fi