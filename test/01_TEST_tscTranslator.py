import sys
import unittest

sys.path.append(".")
import tscTranslator


class tscTranslatorTest(unittest.TestCase):
    def setUp(self) -> None:
        self.machine_codes = ["4204", "9015", "6303"]

    def test_map_to_binary(self):
        answers = ["0100001000000100", "1001000000010101", "0110001100000011"]
        test_answers = [
            tscTranslator.read_hex_as_binary(el) for el in self.machine_codes
        ]
        for answer, test_answer in zip(answers, test_answers):
            with self.subTest():
                self.assertEqual(answer, test_answer)

    def test_translate_binary_to_tsc(self):
        answers = ["ADI $2, $0, 4", "JMP 21", "LHI $3, $0, 3"]
        test_answers = [
            tscTranslator.translate_binary_to_tsc(
                (tscTranslator.read_hex_as_binary(el))
            )
            for el in self.machine_codes
        ]
        for answer, test_answer in zip(answers, test_answers):
            with self.subTest():
                self.assertEqual(answer, test_answer)

    def test_format_instruction(self):
        tests = ["ADI $2, $0, 4", "JMP 21", "LHI $3, $0, 3"]
        answers = ["ADI $2, $0, 4", "JMP 21", "LHI $3, 3"]
        test_answers = [tscTranslator.format_tsc_to_instruction(el) for el in tests]
        for answer, test_answer in zip(answers, test_answers):
            with self.subTest():
                self.assertEqual(answer, test_answer)

    def test_pipe(self):
        answers = ["ADI $2, $0, 4", "JMP 21", "LHI $3, 3"]
        test_answers = [
            tscTranslator.read_hex_as_formatted_instruction(el)
            for el in self.machine_codes
        ]
        for answer, test_answer in zip(answers, test_answers):
            with self.subTest():
                self.assertEqual(answer, test_answer)


if __name__ == "__main__":
    unittest.main()
