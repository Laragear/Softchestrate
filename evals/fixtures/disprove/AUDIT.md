# Audit report for pricing.py

- F1 `pricing.py:9`: `split_bill` divides by zero when `people` is 0, raising an unhandled `ZeroDivisionError`.
- F2 `pricing.py:3`: `discount` applies the TEN code but a lower-case `ten` is also silently ignored, so customers get no discount for `ten`.
