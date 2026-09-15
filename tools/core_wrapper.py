def unwrap_core(wrapped: bytes) -> bytes:
    if len(wrapped) < 142:
        raise ValueError("wrapped core too short")
    return b"CWS" + wrapped[-121:] + wrapped[21:-121]


def wrap_core(plain: bytes, prefix21: bytes) -> bytes:
    if len(prefix21) != 21:
        raise ValueError("prefix must be exactly 21 bytes")
    if len(plain) < 124 or plain[:3] != b"CWS":
        raise ValueError("plain core must be a CWS with at least 124 bytes")
    return prefix21 + plain[124:] + plain[3:124]
