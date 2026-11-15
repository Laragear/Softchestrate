import unittest
from orders import calc, total_with_tax


class OrdersTest(unittest.TestCase):
    def test_calc(self):
        self.assertEqual(calc([{"p": 10, "q": 2}], "vip"), 18.0)
        self.assertEqual(calc([{"p": 10, "q": 2}], "std"), 20)

    def test_tax(self):
        self.assertEqual(total_with_tax([{"p": 10, "q": 2}], "std", 0.5), 30.0)


if __name__ == "__main__":
    unittest.main()
