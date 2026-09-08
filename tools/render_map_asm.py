#!/usr/bin/env python3
"""Render the binary map assets under src/data/maps/ as annotated, assemblable .asm.

The .bin files are the source of truth for the bytes - a map editor reads and writes
them.  tools/map_formats.json is the source of truth for what those bytes mean.  This
script joins the two and emits the .asm that the ROM is actually built from, so the
documentation cannot drift from the data: there is only one artifact in the build path,
and `make check` fails if this script is wrong.

Unlike tools/extract_entity_lists.py, which reads the pristine ROM at hardcoded
offsets and can therefore never be re-run after a change, nothing here knows any ROM
address.  It reads a .bin and a schema, and it is safe to run on edited data.

Usage:
    render_map_asm.py --all              regenerate every asset's .asm
    render_map_asm.py --check            exit 1 if any checked-in .asm is stale
    render_map_asm.py --verify           exit 1 if asm -> bytes != the .bin
    render_map_asm.py -o OUT.asm IN.bin  render one file
"""

import argparse
import fnmatch
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCHEMA_PATH = os.path.join(ROOT, "tools", "map_formats.json")
CODE_COL = 47  # comments start here, matching the wider tables in src/code/


# --------------------------------------------------------------------------- schema

def globs(asset):
    """An asset's glob may be a single pattern or a list of them."""
    g = asset["glob"]
    return [g] if isinstance(g, str) else list(g)


def load_schema():
    with open(SCHEMA_PATH) as f:
        return json.load(f)


def scrape_enum(spec):
    """Read a contiguous run of `DEF NAME EQU $xx` lines out of an .asm constants file.

    Scoped by a from/to symbol span rather than a name prefix: constants.asm reuses the
    ENTITY_ prefix for several unrelated enums whose values would otherwise collide.
    """
    path = os.path.join(ROOT, spec["source"])
    with open(path) as f:
        lines = f.read().splitlines()

    pattern = re.compile(r"^DEF\s+([A-Z0-9_]+)\s+EQU\s+\$([0-9a-fA-F]+)")
    start = end = None
    for i, line in enumerate(lines):
        m = pattern.match(line)
        if not m:
            continue
        if m.group(1) == spec["from"]:
            start = i
        if m.group(1) == spec["to"]:
            end = i
    if start is None:
        sys.exit("%s: symbol %s not found" % (spec["source"], spec["from"]))
    if end is None:
        sys.exit("%s: symbol %s not found" % (spec["source"], spec["to"]))
    if end < start:
        sys.exit("%s: %s appears before %s" % (spec["source"], spec["to"], spec["from"]))

    by_value, by_name = {}, {}
    for line in lines[start:end + 1]:
        m = pattern.match(line)
        if not m:
            continue
        name, value = m.group(1), int(m.group(2), 16)
        if value in by_value:
            sys.exit("%s: value $%02x is both %s and %s - the enum span in "
                     "map_formats.json is picking up more than one enum"
                     % (spec["source"], value, by_value[value], name))
        by_value[value] = name
        by_name[name] = value
    return by_value, by_name


# ------------------------------------------------------------------- annotators

def annotate_reverse_index(records, spec, ctx):
    """Name the entries of another table that select each of these records.

    The boundary rectangles are shared - 59 records for 61 maps - and knowing which
    maps point at a rectangle is most of what makes the table readable. Reading it back
    out of the index table means that stays true after a map is repointed.
    """
    import glob as _glob
    asset = ctx["schema"]["assets"][spec["index_asset"]]
    paths = sorted(q for g in globs(asset) for q in _glob.glob(os.path.join(ROOT, g)))
    if not paths:
        return ["" for _ in records]
    index = open(paths[0], "rb").read()
    by_value = ctx["enums"][spec["enum"]][0] if spec.get("enum") else {}
    limit = spec.get("max_names", 2)
    out = []
    for i in range(len(records)):
        users = [j for j, v in enumerate(index) if v == i]
        if not users:
            out.append("unused")
            continue
        shown = [by_value.get(j, "$%02x" % j) for j in users[:limit]]
        note = ", ".join(shown)
        if len(users) > limit:
            note += " +%d more" % (len(users) - limit)
        out.append(note)
    return out


def annotate_reverse_pairs(records, spec, ctx):
    """For each record, name the record that is its exact reverse, or say it is one-way.

    Computed from the data rather than authored, so unlike a hand-written "#0 <-> #4"
    comment it cannot fall out of date when a door moves.
    """
    src = [tuple(rec[f] for f in spec["from"]) for rec in records]
    dst = [tuple(rec[f] for f in spec["to"]) for rec in records]
    out = []
    for i in range(len(records)):
        partner = next((j for j in range(len(records))
                        if j != i and src[j] == dst[i] and dst[j] == src[i]), None)
        out.append("<-> #$%02x" % partner if partner is not None else "one-way")
    return out


ANNOTATORS = {"reverse_pairs": annotate_reverse_pairs,
              "reverse_index": annotate_reverse_index}


# ---------------------------------------------------------------------------- render

def read_field(data, base, field):
    at = base + field["at"]
    if field["type"] == "u8":
        return data[at]
    if field["type"] == "u16":
        return data[at] | (data[at + 1] << 8)
    sys.exit("unknown field type %r" % field["type"])


def parse_key(k):
    return int(k, 16) if str(k).lower().startswith("0x") else int(k)


def format_value(value, field, enums, warnings, record_index):
    """Render one field, preferring a symbolic constant over a hex literal."""
    for k, name in (field.get("sentinels") or {}).items():
        if value == parse_key(k):
            return name
    if "enum" in field:
        name = enums[field["enum"]][0].get(value)
        if name is not None:
            return name
        warnings.append("record #$%02x: %s $%02x has no constant in the %s enum"
                        % (record_index, field["name"], value, field["enum"]))
        return "$%02x" % value
    return "$%04x" % value if field["type"] == "u16" else "$%02x" % value


def pad(code, comment):
    if not comment:
        return "    " + code
    text = "    " + code
    if len(text) < CODE_COL:
        text += " " * (CODE_COL - len(text))
    else:
        text += "  "
    return text + "; " + comment


def render_header(asset, name, bin_rel, record_count, schema):
    out = []
    out.append("; " + "=" * 66)
    out.append("; GENERATED FILE - do not edit by hand.")
    out.append(";")
    out.append("; Rendered from %s" % bin_rel)
    out.append("; by tools/render_map_asm.py, per the %s layout in tools/map_formats.json." % name)
    out.append(";")
    out.append("; The .bin is the editable source of truth for the bytes; this file is a")
    out.append("; generated view of it that happens to be what gets assembled. To change the")
    out.append("; data, edit the .bin (a map editor writes it). To change what a field MEANS,")
    out.append("; edit the schema. Either way, `make maps-docs` refreshes this file; hand edits")
    out.append("; are overwritten on the next build.")
    out.append(";")
    for line in as_lines(asset.get("doc", [])):
        out.append("; " + line if line else ";")
    if asset.get("annotate"):
        out.append(";")
        out.append("; The note on each record is COMPUTED from the table, not authored, so it")
        out.append("; cannot go stale. Do not hand-correct it - fix the data or the generator.")
    out.append(";")
    size_note = asset.get("record_size_constant")
    out.append("; Record layout - %d bytes%s:"
               % (asset["record_size"], ", " + size_note if size_note else ""))
    for spec in asset["lines"]:
        first = spec["fields"][0]
        names = ", ".join(f["name"] for f in spec["fields"])
        out.append(";   +%-3d %s  %s%s"
                   % (first["at"], spec["emit"], names,
                      "   - " + spec["comment"] if spec.get("comment") else ""))
    out.append(";")
    out.append("; %d record%s." % (record_count, "" if record_count == 1 else "s"))
    out.append("; " + "=" * 66)
    out.append("")
    return out


def as_lines(doc):
    if doc is None:
        return []
    return doc if isinstance(doc, list) else [doc]


def render(data, asset, enums, bin_rel, asset_name, schema):
    size = asset["record_size"]
    term = asset.get("terminator")
    warnings = []

    body = data
    trailing = b""
    if term is not None:
        idx = None
        for i in range(0, len(body) - 1 + 1, size):
            if i < len(body) and body[i] == term["value"]:
                idx = i
                break
        if idx is None:
            warnings.append("no %s found - the list is unterminated, which the game "
                            "would read straight past" % term["constant"])
        else:
            trailing = body[idx:]
            body = body[:idx]
            if len(trailing) > 1:
                warnings.append("%d bytes follow the terminator and are unreachable"
                                % (len(trailing) - 1))

    if len(body) % size:
        warnings.append("%d trailing byte(s) do not form a whole %d-byte record; "
                        "emitted as raw bytes" % (len(body) % size, size))

    count = len(body) // size
    out = render_header(asset, asset_name, bin_rel, count, schema)

    # annotators need every record up front, so decode the whole table once
    fields = [f for spec in asset["lines"] for f in spec["fields"]]
    records = [{f["name"]: read_field(data, r * size, f) for f in fields}
               for r in range(count)]
    notes = [[] for _ in range(count)]
    ann = asset.get("annotate")
    if ann:
        ctx = {"schema": schema, "enums": enums}
        for i, note in enumerate(ANNOTATORS[ann["kind"]](records, ann, ctx)):
            notes[i].append(note)

    index_enum = asset.get("index_enum")

    for r in range(count):
        base = r * size
        summary = ["#$%02x" % r] if asset.get("index_comment") else []
        if index_enum:
            name = enums[index_enum][0].get(r)
            if name:
                summary.append(name)
        summary += notes[r]
        for spec in asset["lines"]:
            for field in spec["fields"]:
                dec = field.get("decode")
                if dec:
                    shift = schema["decoders"][dec]["shift"]
                    summary.append("%s block $%02x"
                                   % (field["name"], read_field(data, base, field) >> shift))
        if asset.get("zero_comment") and not any(records[r].values()):
            summary.append(asset["zero_comment"])
        for n, spec in enumerate(asset["lines"]):
            values = [format_value(read_field(data, base, f), f, enums, warnings, r)
                      for f in spec["fields"]]
            if spec.get("macro"):
                code = "%s %s" % (spec["emit"], ", ".join(values))
            else:
                code = "%-4s %s" % (spec["emit"], ", ".join(values))
            out.append(pad(code, "  ".join(summary) if n == 0 else ""))
        # a record that is one line reads better as a solid block than double spaced
        if len(asset["lines"]) > 1:
            out.append("")

    tail = len(body) - (len(body) % size)
    if tail != len(body):
        out.append(pad("db   " + ", ".join("$%02x" % b for b in body[tail:]),
                       "INCOMPLETE RECORD"))
        out.append("")

    if trailing:
        out.append(pad("db   " + term["constant"], None))
        if len(trailing) > 1:
            out.append(pad("db   " + ", ".join("$%02x" % b for b in trailing[1:]),
                           "unreachable, past the terminator"))

    text = "\n".join(out).rstrip("\n") + "\n"
    return text, warnings


# ----------------------------------------------------------------------- parse back

def resolve(token, names, raw):
    token = token.strip()
    if token.startswith("$"):
        return int(token[1:], 16)
    if token in names:
        return names[token]
    sys.exit("parse_back: unknown token %r in %r" % (token, raw))


def parse_back(text, enums, schema=None):
    """Re-assemble the db/dw values in a rendered .asm, so a render can be proved
    byte-exact without needing rgbasm on the box.

    Deliberately strict: it accepts only db/dw lines whose tokens are hex literals or
    constants it can resolve. So a successful parse is also proof that the generated
    file contains nothing rgbasm could trip over.
    """
    names = {}
    for by_value, by_name in enums.values():
        names.update(by_name)
    # terminators, sentinels and macro widths are all declared in the schema
    macros = {}
    for asset in (schema or {}).get("assets", {}).values():
        term = asset.get("terminator")
        if term and "constant" in term:
            names[term["constant"]] = term["value"]
        for spec in asset.get("lines", []):
            for f in spec["fields"]:
                for k, name in (f.get("sentinels") or {}).items():
                    names[name] = parse_key(k)
            if spec.get("macro"):
                macros[spec["emit"]] = [2 if f["type"] == "u16" else 1
                                        for f in spec["fields"]]

    out = bytearray()
    for raw in text.splitlines():
        line = raw.split(";")[0].strip()
        if not line:
            continue
        m = re.match(r"^(db|dw)\s+(.*)$", line)
        if not m:
            head = line.split(None, 1)
            if head and head[0] in macros:
                widths = macros[head[0]]
                toks = [t.strip() for t in (head[1] if len(head) > 1 else "").split(",")]
                if len(toks) != len(widths):
                    sys.exit("parse_back: %s takes %d args, got %d in %r"
                             % (head[0], len(widths), len(toks), raw))
                for tok, w in zip(toks, widths):
                    out += resolve(tok, names, raw).to_bytes(w, "little")
                continue
            sys.exit("parse_back: cannot read line %r" % raw)
        width = 1 if m.group(1) == "db" else 2
        for token in m.group(2).split(","):
            token = token.strip()
            out += resolve(token, names, raw).to_bytes(width, "little")
    return bytes(out)


# ----------------------------------------------------------------------------- main

def assets_for(schema):
    enums = {name: scrape_enum(spec) for name, spec in schema["enums"].items()}
    jobs = []
    for asset_name, asset in schema["assets"].items():
        for path in sorted(q for g in globs(asset)
                           for q in glob.glob(os.path.join(ROOT, g))):
            jobs.append((asset_name, asset, path))
    return enums, jobs


def match_asset(schema, path):
    rel = os.path.relpath(os.path.abspath(path), ROOT).replace(os.sep, "/")
    for asset_name, asset in schema["assets"].items():
        if any(fnmatch.fnmatch(rel, g) for g in globs(asset)):
            return asset_name, asset
    sys.exit("%s matches no asset glob in map_formats.json" % rel)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("bin", nargs="?", help="a .bin to render")
    ap.add_argument("-o", "--output", help="where to write the .asm")
    ap.add_argument("--all", action="store_true", help="render every asset in the schema")
    ap.add_argument("--check", action="store_true",
                    help="exit 1 if any checked-in .asm differs from a fresh render")
    ap.add_argument("--verify", action="store_true",
                    help="exit 1 if the rendered asm does not re-assemble to the .bin")
    ap.add_argument("--list-outputs", action="store_true",
                    help="print the .asm paths this schema generates, for the Makefile")
    ap.add_argument("-q", "--quiet", action="store_true")
    args = ap.parse_args()

    schema = load_schema()

    if args.list_outputs:
        for _, asset in schema["assets"].items():
            for path in sorted(q for g in globs(asset)
                               for q in glob.glob(os.path.join(ROOT, g))):
                print(os.path.relpath(os.path.splitext(path)[0] + ".asm", ROOT)
                      .replace(os.sep, "/"))
        return 0

    if args.bin and not (args.all or args.check or args.verify):
        asset_name, asset = match_asset(schema, args.bin)
        enums = {n: scrape_enum(s) for n, s in schema["enums"].items()}
        jobs = [(asset_name, asset, os.path.abspath(args.bin))]
    else:
        enums, jobs = assets_for(schema)

    stale, bad, warned = [], [], 0
    for asset_name, asset, path in jobs:
        rel = os.path.relpath(path, ROOT).replace(os.sep, "/")
        with open(path, "rb") as f:
            data = f.read()
        # the .asm sits beside the .bin, and INCBIN paths are relative to src/
        bin_for_header = rel[len("src/"):] if rel.startswith("src/") else rel
        text, warnings = render(data, asset, enums, bin_for_header, asset_name, schema)

        for w in warnings:
            print("%s: warning: %s" % (rel, w), file=sys.stderr)
        warned += len(warnings)

        if args.verify:
            got = parse_back(text, enums, schema)
            if got != data:
                bad.append(rel)
                n = next((i for i in range(min(len(got), len(data)))
                          if got[i] != data[i]), min(len(got), len(data)))
                print("%s: MISMATCH at byte %d (bin has %d bytes, asm %d)"
                      % (rel, n, len(data), len(got)), file=sys.stderr)
            elif not args.quiet:
                print("%s: round trip ok, %d bytes" % (rel, len(data)))
            continue

        dest = args.output or os.path.splitext(path)[0] + ".asm"
        if args.check:
            old = open(dest).read() if os.path.exists(dest) else None
            if old != text:
                stale.append(os.path.relpath(dest, ROOT).replace(os.sep, "/"))
            continue

        with open(dest, "w", newline="\n") as f:
            f.write(text)
        if not args.quiet:
            print("%s -> %s" % (rel, os.path.relpath(dest, ROOT).replace(os.sep, "/")))

    if args.check and stale:
        print("\nstale generated files (run `make maps-docs`):", file=sys.stderr)
        for s in stale:
            print("  " + s, file=sys.stderr)
        return 1
    if bad:
        return 1
    if warned and not args.quiet:
        print("\n%d warning(s)." % warned, file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
