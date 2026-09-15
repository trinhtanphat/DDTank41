from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools" / "core_wrapper.py"
assert TOOL.exists(), "core_wrapper.py missing"
spec = importlib.util.spec_from_file_location("core_wrapper", TOOL)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

plain = b"CWS" + bytes(range(121)) + bytes(range(256)) * 4
prefix = bytes(range(21))
wrapped = mod.wrap_core(plain, prefix)
assert len(wrapped) == len(plain) + 18
assert wrapped[:21] == prefix
assert mod.unwrap_core(wrapped) == plain
print("CORE_WRAPPER_SMOKE=PASS")
