#!/usr/bin/env python3
import os

rtl_dir = "rtl"
tb_dir  = "tb"
files_f = "files.f"

with open(files_f, "w") as f:
    # Write include dirs first
    f.write("+incdir+./rtl\n")
    f.write("+incdir+./tb\n\n")

    # Add RTL files first
    for root, _, files in os.walk(rtl_dir):
        for file in sorted(files):
            if file.endswith(".sv"):
                f.write(os.path.join(root, file) + "\n")

    # Add TB files next
    for root, _, files in os.walk(tb_dir):
        for file in sorted(files):
            if file.endswith(".sv"):
                f.write(os.path.join(root, file) + "\n")

print(f"[INFO] Generated {files_f}")
