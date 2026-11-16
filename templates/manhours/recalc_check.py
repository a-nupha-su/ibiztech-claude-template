"""
Recalculate all formulas of an .xlsx using LibreOffice headless (on a temporary copy),
then report formula error cells as JSON. The input file is never modified.

    python3 recalc_check.py FILE.xlsx      exit 0 = total_errors 0 · 1 = errors found · 2 = could not run
"""

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import openpyxl

def find_soffice():
    for binary in ["soffice", "libreoffice"]:
        soffice = shutil.which(binary)
        if soffice:
            return soffice
    if sys.platform == "darwin" and Path("/Applications/LibreOffice.app/Contents/MacOS/soffice").exists():
        return "/Applications/LibreOffice.app/Contents/MacOS/soffice"
    return None

def convert(soffice, src, workdir):
    profile_dir = workdir / "profile"
    out_dir = workdir / "out"
    out_dir.mkdir(parents=True, exist_ok=True)
    abs_input_path = src.resolve()
    cmd = [
        soffice,
        f"-env:UserInstallation=file://{profile_dir}",
        "--headless",
        "--norestore",
        "--convert-to",
        "xlsx:Calc MS Excel 2007 XML",
        "--outdir",
        out_dir,
        str(abs_input_path)
    ]
    result = subprocess.run(cmd, timeout=180, capture_output=True, text=True)
    if result.returncode != 0 or not (out_dir / src.name).exists():
        print(json.dumps({"status": "error", "message": result.stderr or "conversion failed"}), file=sys.stdout)
        sys.exit(2)
    return out_dir / src.name

def count_formulas(path):
    wb = openpyxl.load_workbook(path, data_only=False)
    formula_count = 0
    for sheet in wb.worksheets:
        for row in sheet.iter_rows():
            for cell in row:
                if isinstance(cell.value, str) and cell.value.startswith("="):
                    formula_count += 1
    return formula_count

def scan_errors(path):
    wb = openpyxl.load_workbook(path, data_only=True)
    error_summary = {}
    for sheet in wb.worksheets:
        for row in sheet.iter_rows():
            for cell in row:
                if isinstance(cell.value, str) and cell.value in {
                    "#REF!", "#DIV/0!", "#VALUE!", "#NAME?", "#N/A", "#NUM!", "#NULL!",
                    "Err:502", "Err:504", "Err:508", "Err:509", "Err:511", "Err:522"
                }:
                    error_key = cell.value
                    if error_key not in error_summary:
                        error_summary[error_key] = {"count": 0, "locations": []}
                    error_summary[error_key]["count"] += 1
                    if len(error_summary[error_key]["locations"]) < 20:
                        error_summary[error_key]["locations"].append(f"{sheet.title}!{cell.coordinate}")
    return error_summary

def main():
    parser = argparse.ArgumentParser(description="Recalculate an .xlsx with LibreOffice and report formula errors.")
    parser.add_argument("FILE", type=Path, help="Input .xlsx file")
    args = parser.parse_args()

    soffice = find_soffice()
    if not soffice:
        print(json.dumps({"status": "error", "message": "LibreOffice (soffice) not found - install it first"}), file=sys.stdout)
        sys.exit(2)

    with tempfile.TemporaryDirectory() as tempdir:
        converted_path = convert(soffice, args.FILE, Path(tempdir))
        error_summary = scan_errors(converted_path)
    original_formula_count = count_formulas(args.FILE)
    total_errors = sum(error["count"] for error in error_summary.values())

    result = {
        "status": "success" if total_errors == 0 else "errors_found",
        "total_errors": total_errors,
        "total_formulas": original_formula_count,
        "error_summary": error_summary
    }

    print(json.dumps(result, ensure_ascii=False, indent=2), file=sys.stdout)
    return 0 if total_errors == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
