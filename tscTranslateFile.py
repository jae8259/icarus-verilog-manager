import re

from tscTranslator import read_hex_to_formatted_instruction

HEX_REGEX = r"memory\[\d+\].*=.*16'h(\d{1,4});\s*"


def add_tsc_comment(target: str) -> str:
    result = ""
    machine_codes = re.findall(HEX_REGEX, target)
    machine_codes = [code.zfill(4) for code in machine_codes]

    result = re.sub(
        HEX_REGEX,
        lambda match: match.group(0)
        + "  // TSC = "
        + read_hex_to_formatted_instruction(match.group(1).zfill(4)),
        target,
    )
    return result


def main():
    print(add_tsc_comment("memory[8]  = 16'h4204;"))


if __name__ == "__main__":
    main()
