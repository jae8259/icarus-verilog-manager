# Find patterns with memory[*] <= 16'h\d{1..4}

# Render digits to binary so 16bit string

# opcode = string[12:16]
# f
from typing import Dict

HEX = 16
BIN = 2
DEC = 10


def map_dec_to_filled_bin(target: int, fill: int):
    return bin(target)[2:].zfill(fill)


dec_to_opcode = lambda target: map_dec_to_filled_bin(target, 4)
dec_to_func_code = lambda target: map_dec_to_filled_bin(target, 6)

OPCODE_MAP: Dict[str, str] = {
    4: "ADI",
    5: "ORI",
    6: "LHI",
    7: "LWD",
    8: "SWD",
    0: "BNE",
    1: "BEQ",
    2: "BGZ",
    3: "BLZ",
    9: "JMP",
    10: "JAL",
}
OPCODE_MAP = {dec_to_opcode(key): value for key, value in OPCODE_MAP.items()}

FUNC_MAP: Dict[str, str] = {
    0: "ADD",
    1: "SUB",
    2: "AND",
    3: "ORR",
    4: "NOT",
    5: "TCP",
    6: "SHL",
    7: "SHR",
    25: "JPR",
    26: "JRL",
    28: "WWD",
    29: "HLT",
}
FUNC_MAP = {dec_to_func_code(key): value for key, value in FUNC_MAP.items()}


def map_to_binary(machine_code: str):
    return format(int(machine_code, HEX), "b").zfill(16)


def translate_binary_to_tsc(machine_code: str):
    result: str = ""
    match opcode := machine_code[0:4]:
        case "1111":
            result = translate_r_type(machine_code)
        case "1001" | "1010":
            result = translate_j_type(machine_code)
        case opcode if opcode in OPCODE_MAP.keys():
            result = translate_i_type(machine_code)
        case _:
            raise ValueError(f"Unvalid opcode Error: {opcode}")
    return result


def translate_r_type(machine_code: str):
    func_code = machine_code[10:]
    rs, rt, rd = machine_code[4:6], machine_code[6:8], machine_code[8:10]
    func_name: str = FUNC_MAP[func_code]

    return f"{func_name} ${int(rs, BIN)}, ${int(rt, BIN)}, ${int(rd, BIN)}"


def translate_i_type(machine_code: str):
    immediate = machine_code[8:]
    rs, rt = machine_code[4:6], machine_code[6:8]
    opcode = machine_code[0:4]
    func_name: str = OPCODE_MAP[opcode]

    return f"{func_name} ${int(rt, BIN)}, ${int(rs, BIN)}, {int(immediate, BIN)}"


def translate_j_type(machine_code: str):
    target_address = machine_code[4:]
    opcode = machine_code[0:4]
    func_name: str = OPCODE_MAP[opcode]

    return f"{func_name} {int(target_address, BIN)}"


def format_instruction(instruction: str):
    raise NotImplementedError
