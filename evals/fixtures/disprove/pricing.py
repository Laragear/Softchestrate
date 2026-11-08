def discount(total, code):
    if code == "TEN":
        return total * 0.9
    return total


def split_bill(total, people):
    if people <= 0:
        raise ValueError("people must be positive")
    return total / people
