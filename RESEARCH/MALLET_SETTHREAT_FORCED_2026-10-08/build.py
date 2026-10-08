# Octavia Mallet root replacement (BardMusic, content key ec368d4901690a15): build + offline gates (2026-10-08,
# client 44.1.0 2026.10.06.16.12). Reuses the gated instruction-edit builder of the Icebind Solo package
# (repos/runtime/bootstrapper-runtime/Scripts/IcebindSolo/src/build_members.py); this file only declares the edits.
#
#   P16 i568 / i570  LOADB 1 -> 0   checkForCover / staticCoverOnly of the Mallet's radial damage (the existing
#                                   "No Cover exact flags" edits, unchanged since 2026-09-11)
#   P18 i25          MOVE R6, R2 -> LOADN R6, 5   SetThreatLevel (EM_HOST secondary script) passes 5 to
#                                   box:SetThreatModifier instead of the pushed level, so every threat update
#                                   the game makes for the Mallet applies 5, whether or not the PushFloatArg
#                                   addon hook caught that push.
# Usage: python build.py
import sys
from pathlib import Path

ROOT = Path(r'C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE')
sys.path.insert(0, str(ROOT / 'repos/runtime/bootstrapper-runtime/Scripts/IcebindSolo/src'))
import build_members as bm  # noqa: E402

HERE = Path(__file__).resolve().parent
NAME = 'ec368d4901690a15 (Octavia Mallet No Cover + threat 5).lua_B'

bm.OUT = HERE / 'build'
bm.MEMBERS = [
    {
        'stock': 'Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B',
        'key': 'ec368d4901690a15',
        'file': NAME,
        'edits': [
            {'proto': 16, 'i': 568, 'old': (bm.LOADB, 31, 1), 'new': (bm.LOADB, 31, 0),
             'why': 'Mallet radial damage: checkForCover = false (existing No Cover edit)'},
            {'proto': 16, 'i': 570, 'old': (bm.LOADB, 31, 1), 'new': (bm.LOADB, 31, 0),
             'why': 'Mallet radial damage: staticCoverOnly = false (existing No Cover edit)'},
            {'proto': 18, 'i': 25, 'old': (bm.MOVE, 6, 2), 'new': (bm.LOADN, 6, 5),
             'why': 'SetThreatLevel: box:SetThreatModifier(5) instead of the pushed level (stock floor(Lerp(5, 0, '
                    'min(1, pool / 1500))), 0 once the Mallet holds 1500 damage), applied at the game\'s own setter '
                    'on every update; same value Loki Decoy sets'},
        ],
    },
]

if __name__ == '__main__':
    sys.exit(bm.main())
