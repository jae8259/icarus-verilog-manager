import re
from pathlib import Path

from tscTranslator import read_hex_to_formatted_instruction

HEX_REGEX = r"^(.*?)memory\[.*\].*=.*16'h([0-9A-Fa-f]{1,4});\s*$"


def add_comment_on_file(target_path: Path, save_path: Path):
    content = ""
    with open(target_path, "r") as verilog_file:
        content = verilog_file.read()
    content = add_tsc_comment(content)

    with open(save_path, "w") as comment_verilog_file:
        comment_verilog_file.write(content)


def add_tsc_comment(target: str) -> str:
    result = ""
    pattern = re.compile(HEX_REGEX, re.MULTILINE)

    result = re.sub(
        pattern,
        lambda match: match.group(1)
        + match.group(0).strip()
        + "  // TSC = "
        + read_hex_to_formatted_instruction(match.group(2).zfill(4)),
        target,
    )
    return result


def main():
    add_comment_on_file("./resource/memory.v", "./resource/memory2.v")


if __name__ == "__main__":
    main()
