def calc(o, t):
    r = 0
    for i in o:
        r = r + i["p"] * i["q"]
    if t == "vip":
        r = r - r * 0.1
    return r


def unused_helper(x):
    return x * 2


def total_with_tax(o, t, tax):
    r = 0
    for i in o:
        r = r + i["p"] * i["q"]
    if t == "vip":
        r = r - r * 0.1
    return r + r * tax
