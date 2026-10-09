"""Scripts menu (SCRIPTS / SCRIPT SETTINGS rows) attachment check (2026-10-09).

The bootstrapper attaches the Scripts menu to Lotus/Interface/TopMenu through a pinned closure shape per TopMenu content
key (renovice/injection_core.hpp `pause_top_menu_layouts`): the root's global `Initialize` closure has N captures,
capture B is the ESC row builder (a closure with M captures), and the builder's capture D is the dispatch it wraps. An
unregistered key or a changed shape makes the bootstrapper fail closed (no SCRIPTS row). Hotfix 44.1.1 inserted one
Initialize capture; nothing checked this before install and the menu disappeared in game.

This derives the shape from the stock TopMenu bytes of the checked client and compares it with the layout row of the
bootstrapper source the check reads. Read only.
"""
import re
import struct

import uc_bytecode as B

TOPMENU_FILE = 'Lotus_Interface_TopMenu.lua_B'
LAYOUT_SOURCE = 'renovice/injection_core.hpp'
SETGLOBAL, NEWCLOSURE, DUPCLOSURE, CAPTURE = 0x02, 0x16, 0x42, 0x35
_ROW = re.compile(r'\{\s*0x([0-9a-fA-F]{16})ull\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\}')


def layout_rows(source_text: str) -> dict:
    """{top menu key: (initialize_upvalues, builder_upvalue, builder_upvalues, dispatch_upvalue)} of the source table."""
    start = source_text.find('pause_top_menu_layouts[]')
    if start < 0:
        return {}
    body = source_text[start:source_text.find('};', start)]
    return {m.group(1).lower(): tuple(int(m.group(i)) for i in range(2, 6)) for m in _ROW.finditer(body)}


def closure_shape(m: B.Module) -> dict:
    """Root closures by register as the root runs, the global Initialize closure and every capture's closure."""
    root = m.protos[m.main_index]
    regs = {}          # register -> {'proto': index, 'captures': [(type, index)]}
    initialize = None
    current = None
    for logical, off, op in root.instructions:
        word = root.canonical_code[off:off + 8]
        if op in (NEWCLOSURE, DUPCLOSURE):
            a = word[1]
            d = struct.unpack_from('<H', word, 2)[0]
            if op == NEWCLOSURE:
                proto = root.kids[d] if d < len(root.kids) else None
            else:
                c = root.consts[d] if d < len(root.consts) else None
                proto = c.value if c is not None and c.tag == 6 else None
            current = {'proto': proto, 'captures': [], 'captured': [], 'register': a}
            regs[a] = current
            continue
        if op == CAPTURE and current is not None:
            current['captures'].append((word[1], word[2]))
            current['captured'].append(regs.get(word[2]) if word[1] == 0 else None)  # VAL of a root closure
            continue
        current = None
        if op == SETGLOBAL:
            k = m.aux(root, off)
            c = root.consts[k] if k < len(root.consts) else None
            name = m.string(c.value) if c is not None and c.tag == 3 else None
            if name == b'Initialize' and word[1] in regs:
                initialize = regs[word[1]]
    return {'initialize': initialize}


def check(stock, boot) -> tuple[str, str, dict]:
    """(status, reason, evidence) for the Scripts menu attachment on this client."""
    m = stock.module_file(TOPMENU_FILE)
    if m is None:
        return B_UNKNOWN, f'{TOPMENU_FILE} is not in this client', {}
    if not boot.has(LAYOUT_SOURCE):
        return B_UNKNOWN, f'bootstrapper source has no {LAYOUT_SOURCE}', {}
    rows = layout_rows(boot.read(LAYOUT_SOURCE))
    shape = closure_shape(m)
    init = shape['initialize']
    evidence = {'top_menu_key': m.key, 'layout_keys': sorted(rows)}
    if init is None:
        return B_BROKEN, 'TopMenu root no longer stores a global Initialize closure', evidence
    count = len(init['captures'])
    builders = [(i, c) for i, c in enumerate(init['captured']) if c is not None]
    evidence.update(initialize_upvalues=count,
                    closure_captures={i: len(c['captures']) for i, c in builders})
    row = rows.get(m.key)
    if row is None:
        fits = [i for i, c in builders if len(c['captures']) in {r[2] for r in rows.values()}]
        return (B_BROKEN, f'no layout row for TopMenu {m.key} in {LAYOUT_SOURCE}: the bootstrapper refuses to attach '
                f'the Scripts menu (TopMenu-layout-unregistered). This client: Initialize {count} captures, builder '
                f'candidates at {fits}; add a row {{0x{m.key}ull, {count}, <builder>, <builder captures>, <dispatch>}}',
                evidence)
    want_count, builder_index, builder_count, dispatch = row
    if count != want_count:
        return B_BROKEN, f'Initialize has {count} captures, the layout row says {want_count}', evidence
    captured = init['captured'][builder_index] if builder_index < len(init['captured']) else None
    if captured is None:
        return B_BROKEN, f'Initialize capture {builder_index} is not a root closure (the ESC builder moved)', evidence
    if len(captured['captures']) != builder_count:
        return (B_BROKEN, f'the closure at Initialize capture {builder_index} has {len(captured["captures"])} captures, '
                f'the layout row says {builder_count}', evidence)
    if captured['captured'][dispatch] is None:
        return (B_BROKEN, f'builder capture {dispatch} is not a root closure (the dispatch the Scripts menu wraps moved)',
                evidence)
    return (B_OK, f'TopMenu {m.key}: Initialize {count} captures, builder at U{builder_index} ({builder_count} captures), '
            f'dispatch U{dispatch} = the layout row', evidence)


B_OK, B_BROKEN, B_UNKNOWN = 'OK', 'BROKEN', 'UNKNOWN'
