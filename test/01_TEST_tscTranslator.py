import sys
import unittest

sys.path.append(".")
import tscTranslator


class tscTranslatorTest(unittest.TestCase):
    def setUp(self) -> None:
        self.machine_code = "4204"

    def test_map_to_binary(self):
        answer = "0100001000000100"
        self.assertEqual(answer, tscTranslator.map_to_binary(self.machine_code))

    def test_translate_binary_to_tsc(self):
        answer = "ADI $2, $0, 4"
        machine_code = tscTranslator.map_to_binary(self.machine_code)
        self.assertEqual(answer, tscTranslator.translate_binary_to_tsc(machine_code))


if __name__ == "__main__":
    unittest.main()
