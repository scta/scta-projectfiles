#!/usr/bin/env python3
"""Validate an Expression Description File against the pinned EDF schema."""

import argparse
import hashlib
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

SCHEMA_COMMIT = "02d8df7ff71950c72a796b588d597378b9472914"
RNG_URL = (
    "https://raw.githubusercontent.com/scta/edf-schema/"
    f"{SCHEMA_COMMIT}/src/projectfile.rng"
)
RNG_SHA256 = "2d1a53f8450526225f01d6fd7754c27c085cd6420baa96c289a1296a6e6609d1"
RNG_PI = (
    "https://raw.githubusercontent.com/scta/edf-schema/master/src/projectfile.rng"
)
SCH_PI = (
    "https://raw.githubusercontent.com/scta/edf-schema/master/src/projectfile.sch"
)


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="+", type=Path, help="EDF XML files to validate")
    parser.add_argument(
        "--schema",
        type=Path,
        help="Use a local Relax NG schema instead of the pinned authoritative schema",
    )
    parser.add_argument(
        "--skip-relaxng",
        action="store_true",
        help="Skip Relax NG validation (useful only for unit tests)",
    )
    return parser.parse_args()


def load_xml(path):
    try:
        return ET.parse(path)
    except (ET.ParseError, OSError) as error:
        raise ValueError(f"{path}: not well-formed XML: {error}") from error


def require_processing_instructions(path):
    source = path.read_text(encoding="utf-8")
    missing = [
        expected
        for expected in (RNG_PI, SCH_PI)
        if expected not in source
    ]
    if missing:
        raise ValueError(
            f"{path}: missing required XML model processing instruction(s): "
            + ", ".join(missing)
        )


def require_unique_attributes(path, tree):
    root = tree.getroot()
    for attribute in ("id", "filestem"):
        seen = set()
        duplicates = set()
        for element in root.iter():
            value = element.get(attribute)
            if value is None:
                continue
            if value in seen:
                duplicates.add(value)
            seen.add(value)
        if duplicates:
            values = ", ".join(sorted(duplicates))
            raise ValueError(f"{path}: duplicate {attribute} value(s): {values}")


def download_pinned_schema():
    with urllib.request.urlopen(RNG_URL, timeout=30) as response:
        contents = response.read()
    digest = hashlib.sha256(contents).hexdigest()
    if digest != RNG_SHA256:
        raise ValueError(
            "Downloaded EDF schema checksum did not match the pinned revision: "
            f"expected {RNG_SHA256}, got {digest}"
        )
    schema_file = tempfile.NamedTemporaryFile(suffix=".rng", delete=False)
    schema_file.write(contents)
    schema_file.close()
    return Path(schema_file.name)


def validate_relaxng(path, schema):
    xmllint = shutil.which("xmllint")
    if xmllint is None:
        raise ValueError("xmllint is required for Relax NG validation but was not found")
    result = subprocess.run(
        [xmllint, "--noout", "--relaxng", str(schema), str(path)],
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        details = (result.stderr or result.stdout).strip()
        raise ValueError(f"{path}: Relax NG validation failed:\n{details}")


def validate_file(path, schema, skip_relaxng):
    if not path.is_file():
        raise ValueError(f"{path}: file does not exist")
    require_processing_instructions(path)
    tree = load_xml(path)
    require_unique_attributes(path, tree)
    if not skip_relaxng:
        validate_relaxng(path, schema)


def main():
    args = parse_args()
    downloaded_schema = None
    try:
        schema = args.schema
        if not args.skip_relaxng and schema is None:
            downloaded_schema = download_pinned_schema()
            schema = downloaded_schema
        for path in args.files:
            validate_file(path, schema, args.skip_relaxng)
            print(f"Validated {path}")
    except ValueError as error:
        print(error, file=sys.stderr)
        return 1
    finally:
        if downloaded_schema is not None:
            downloaded_schema.unlink(missing_ok=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
