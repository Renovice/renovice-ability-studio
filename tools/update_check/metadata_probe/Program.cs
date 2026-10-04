// compose <Packages.bin> <types.json> <out.json>
// Writes {"types": {path: {"parent", "text"}}, "missing": [path, ...]} with the composed (inherited) metadata text of each
// requested type, decoded by the metadata editor's PackagesBinDecoder / MetadataCatalog (same logic as the 44.0.2
// package-probe "meta" mode that produced the registry's METADATA_SNAPSHOT.json). Read-only; fails on an unaligned decode.
using MetadataPatchEditor.Core;
using System.Text.Json;

if (args.Length != 4 || args[0] != "compose")
{
    Console.Error.WriteLine("usage: metadata_probe compose <Packages.bin> <types.json> <out.json>");
    return 2;
}
var decoded = PackagesBinDecoder.DecodeBytes(File.ReadAllBytes(args[1]));
if (!decoded.Aligned)
{
    Console.Error.WriteLine("unaligned metadata decode");
    return 3;
}
var catalog = MetadataCatalog.Build(decoded);
var paths = JsonSerializer.Deserialize<string[]>(File.ReadAllText(args[2])) ?? [];
var types = new SortedDictionary<string, object>(StringComparer.Ordinal);
var missing = new List<string>();
foreach (var path in paths)
{
    if (!decoded.Types.TryGetValue(path, out var type))
    {
        missing.Add(path);
        continue;
    }
    types[path] = new { parent = type.Parent, text = catalog.ComposedText(path) };
}
File.WriteAllText(args[3], JsonSerializer.Serialize(new { types, missing }));
Console.WriteLine($"decoded {decoded.Types.Count} types, composed {types.Count}, missing {missing.Count}");
return 0;
