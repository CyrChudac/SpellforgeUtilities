#!/usr/bin/env python3

import argparse
import re
from pathlib import Path

# Matches standalone require statements:
# require("module")
# require('module')
# require(module)
REQUIRE_PATTERN = re.compile(
    r"""^\s*require\s*\(\s*(['"]?)([\w.-]+)\1\s*\)\s*;?\s*(?:--.*)?$"""
)

def join_lua(input_file: Path, output_file: Path, search_paths: list[Path]):
    included = set()
    root = input_file.parent
 
    def resolve_module(module: str, current_dir: Path) -> Path:
        relative = Path(*module.split("."))
 
        candidates = [
            directory / f"{relative}.lua"
            for directory in [current_dir, *search_paths]
        ]
 
        for candidate in candidates:
            if candidate.is_file():
                return candidate.resolve()
 
        raise FileNotFoundError(
            f"Cannot resolve module '{module}' "
            f"required from '{current_dir}'"
        )
 
    def expand(file: Path) -> str:
        file = file.resolve()
 
        if file in included:
            return ""
 
        # Mark before processing to prevent circular recursion.
        included.add(file)
 
        result = [f"-- BEGIN {file}\n"]
 
        with file.open("r", encoding="utf-8-sig") as source:
            for line in source:
                match = REQUIRE_PATTERN.fullmatch(line.rstrip("\r\n"))
 
                if match:
                    module = match.group(2)
                    module_file = resolve_module(module, file.parent)
                    result.append(expand(module_file))
                else:
                    result.append(line)
 
        result.append(f"\n-- END {file}\n")
        return "".join(result)
 
    combined = expand(input_file)
 
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(combined, encoding="utf-8")
 
    print(f"Output: {output_file}")
    print(f"Files included: {len(included)}")
 
 
def main():
    parser = argparse.ArgumentParser(
        description="Join Lua files by recursively inlining require statements."
    )
 
    parser.add_argument("input", type=Path, help="Entry Lua file")
    parser.add_argument("output", type=Path, help="Output Lua file")
    parser.add_argument(
        "-I", "--include",
        type=Path,
        action="append",
        default=[],
        help="Additional module search directory (repeatable)"
    )
 
    args = parser.parse_args()
 
    input_file = args.input.resolve()
 
    if not input_file.is_file():
        parser.error(f"Input file not found: {input_file}")
 
    search_paths = [
        input_file.parent,
        *(path.resolve() for path in args.include)
    ]
 
    join_lua(input_file, args.output.resolve(), search_paths)
 
 
if __name__ == "__main__":
    main()