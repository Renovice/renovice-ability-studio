using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using Microsoft.Win32;
using Renovice.AbilityEditor.Core;

namespace Renovice.AbilityEditor.App;

public partial class MainWindow : Window
{
    private sealed record ProjectEntry(string Path, string DisplayName, EditorMode Mode);

    public sealed class StatRow
    {
        public string Id { get; set; } = "new_stat";
        public string Label { get; set; } = "New Stat";
        public string Kind { get; set; } = "RAW";
        public string Base { get; set; } = "0";
        public string Minimum { get; set; } = "0";
        public string Maximum { get; set; } = string.Empty;
        public string ModifierFamily { get; set; } = "NONE";
        public string? ModifierBinding { get; set; }
        public bool ShowOnCard { get; set; } = true;
        public string Unit { get; set; } = "None";
        public int Order { get; set; } = 100;

        public static StatRow FromDefinition(StatDefinition definition) => new()
        {
            Id = definition.Id,
            Label = definition.Label,
            Kind = definition.Kind,
            Base = definition.Base.ToString("G17", CultureInfo.InvariantCulture),
            Minimum = definition.Minimum?.ToString("G17", CultureInfo.InvariantCulture) ?? string.Empty,
            Maximum = definition.Maximum?.ToString("G17", CultureInfo.InvariantCulture) ?? string.Empty,
            ModifierFamily = definition.ModifierFamily,
            ModifierBinding = definition.ModifierBinding,
            ShowOnCard = definition.ShowOnCard,
            Unit = StatUnits.DisplayName(definition.Unit),
            Order = definition.Order,
        };

        public StatDefinition ToDefinition()
        {
            if (!double.TryParse(Base, NumberStyles.Float, CultureInfo.InvariantCulture, out var baseValue))
                throw new InvalidDataException($"{Label}: Base must be a number.");
            double? minimum = ParseOptional(Minimum, Label, "Minimum");
            double? maximum = ParseOptional(Maximum, Label, "Maximum");
            return new StatDefinition(
                Id.Trim(), Label.Trim(), Kind.Trim().ToUpperInvariant(), baseValue, minimum, maximum,
                ModifierFamily.Trim().ToUpperInvariant(), string.IsNullOrWhiteSpace(ModifierBinding) ? null : ModifierBinding.Trim(),
                ShowOnCard, StatUnits.Path(Unit), Order);
        }

        private static double? ParseOptional(string value, string label, string field)
        {
            if (string.IsNullOrWhiteSpace(value)) return null;
            if (!double.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out var parsed))
                throw new InvalidDataException($"{label}: {field} must be blank or a number.");
            return parsed;
        }
    }

    public sealed class MissionTimerRow : INotifyPropertyChanged
    {
        public string Id { get; init; } = string.Empty;
        public string Group { get; init; } = string.Empty;
        public string Label { get; init; } = string.Empty;
        public string StockValue { get; init; } = string.Empty;
        public string RecommendedValue { get; init; } = string.Empty;
        public string Unit { get; init; } = string.Empty;
        public string Explanation { get; init; } = string.Empty;
        public string StockCaption { get; init; } = string.Empty;
        public string RecommendedCaption => $"Suggested example: {RecommendedValue} {Unit}";

        string _value = string.Empty;
        public string Value
        {
            get => _value;
            set
            {
                if (_value == value) return;
                _value = value;
                PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Value)));
            }
        }

        public event PropertyChangedEventHandler? PropertyChanged;
    }

    public sealed class StockNumericRow
    {
        public required LinkedCardControl Control { get; init; }
        public string Label => Control.Label;
        public string Unit => Control.Unit;
        public string Evidence => Control.Evidence;
        public string Explanation => Editable ? Control.Operation == "scale"
            ? "1× keeps stock values. Scales all base ranks and variants together, including PvP. Native mod scaling is retained."
            : "Updates gameplay and the ability card together. Native mod scaling is retained." : Control.Evidence;
        public bool Editable => Control.Inputs.Count > 0;
        public string OriginalDisplay => Control.StockCaption;
        public string Value { get; set; } = string.Empty;
        public IReadOnlyList<StockNumericValue> ToValues()
        {
            if (!double.TryParse(Value, NumberStyles.Float, CultureInfo.InvariantCulture, out var parsed))
                throw new InvalidDataException($"{Label}: value must be a number.");
            return Control.Edits(parsed);
        }
    }

    private readonly ObservableCollection<StatRow> statRows = [];
    private readonly ObservableCollection<MissionTimerRow> missionTimerRows = [];
    private IReadOnlyList<MissionTimerPreset> missionPresets = MissionTimerPreset.All;
    private readonly ObservableCollection<StockNumericRow> stockNumericRows = [];
    private readonly ObservableCollection<SemanticNameEntry> semanticNameRows = [];
    private readonly ObservableCollection<ClosureOwnershipEntry> closureRows = [];
    private readonly ObservableCollection<SemanticExportEntry> exportRows = [];
    private readonly ObservableCollection<SemanticPrototypeNode> prototypeOutlineRows = [];
    private readonly ObservableCollection<SemanticPrototypeRelation> prototypeRelationRows = [];
    private readonly ObservableCollection<SemanticApiEvidenceContract> semanticApiEvidenceRows = [];
    private readonly ObservableCollection<SemanticCallsiteEntry> semanticCallsiteRows = [];
    private IReadOnlyList<SemanticCallsiteAnnotation> sourceCallAnnotations = [];
    private readonly List<ProjectEntry> allProjects = [];
    private ICollectionView? semanticNameView;
    private AbilityCatalog? abilityCatalog;
    private ModifierBindingRegistry? modifierRegistry;
    private HelminthRegistry? helminthRegistry;
    private WarframeCatalogEntry? selectedCatalogWarframe;
    private AbilityCatalogEntry? selectedCatalogAbility;
    private WorkspacePaths? workspace;
    private AbilityProject? project;
    private string? replacementSourcePath;
    private string? lastGeneration;
    private string? lastBuildManifest;
    private string? lastDeploymentManifest;
    private string? semanticBaseReadablePath;
    private string? semanticBaseReadableText;
    private bool semanticBaseWasFreshWhenLoaded;
    private string semanticSummaryBase = "No validated semantic naming map is loaded.";
    private bool semanticClosureMapLoaded;
    private bool semanticVerificationLoaded;
    private SemanticVerificationDocument? semanticVerificationDocument;
    private SemanticCallsiteAdorner? sourceCallsiteAdorner;
    private SemanticCallsiteAnnotation? hoveredSourceCallAnnotation;
    private StructuralRebaseResult? pendingSourceRebase;
    private string? pendingRebaseBaselinePath;
    private string? pendingRebaseGeneratedPath;
    private bool settingSourceEditorText;
    private bool loading;

    public MainWindow()
    {
        InitializeComponent();
        StatKindColumn.ItemsSource = new[] { "FRACTION", "RAW", "SECONDS", "METERS", "MULTIPLIER", "COUNT" };
        ModifierFamilyColumn.ItemsSource = new[] { "NONE", "STRENGTH", "DURATION", "RANGE", "EFFICIENCY", "CUSTOM", "UNKNOWN" };
        StatUnitColumn.ItemsSource = new[] { "None", "Percent", "Seconds", "Meters", "Multiplier" };
        StatsGrid.ItemsSource = statRows;
        MissionValuesList.ItemsSource = missionTimerRows;
        StockValuesList.ItemsSource = stockNumericRows;
        SemanticRowsGrid.ItemsSource = semanticNameRows;
        ClosureRowsGrid.ItemsSource = closureRows;
        ExportRowsGrid.ItemsSource = exportRows;
        PrototypeOutlineGrid.ItemsSource = prototypeOutlineRows;
        PrototypeRelationsGrid.ItemsSource = prototypeRelationRows;
        SemanticApiEvidenceGrid.ItemsSource = semanticApiEvidenceRows;
        SemanticCallsiteGrid.ItemsSource = semanticCallsiteRows;
        SourceEditor.Loaded += SourceEditor_Loaded;
        SourceEditor.SizeChanged += (_, _) => sourceCallsiteAdorner?.InvalidateVisual();
        SourceEditor.AddHandler(ScrollViewer.ScrollChangedEvent,
            new ScrollChangedEventHandler((_, _) => sourceCallsiteAdorner?.InvalidateVisual()));
        ToolTipService.SetInitialShowDelay(SourceEditor, 180);
        ToolTipService.SetBetweenShowDelay(SourceEditor, 0);
        ToolTipService.SetShowDuration(SourceEditor, 60000);
        semanticNameView = CollectionViewSource.GetDefaultView(semanticNameRows);
        semanticNameView.Filter = SemanticEntryMatches;
        SemanticPrototypeBox.ItemsSource = new[] { "All prototypes" };
        SemanticPrototypeBox.SelectedIndex = 0;
        MissionPresetBox.DisplayMemberPath = nameof(MissionTimerPreset.DisplayName);
        MissionSectionBox.ItemsSource = new[] { "Regular missions", "EDA / ETA" };
        MissionSectionBox.SelectedIndex = 0;
        statRows.CollectionChanged += (_, _) => UpdateStatPreview();
        try
        {
            workspace = WorkspaceLocator.Locate();
            missionPresets = MissionBuildProfile.Presets(workspace.EditorRoot);
            RefreshMissionSection();
            modifierRegistry = ModifierBindingRegistry.Load(workspace.ModifierRegistryPath);
            helminthRegistry = HelminthRegistry.Load(workspace.HelminthRegistryPath);
            Directory.CreateDirectory(workspace.ProjectsRoot);
            Directory.CreateDirectory(workspace.StagingRoot);
            Directory.CreateDirectory(workspace.RenderedSourceRoot);
            RefreshProjects();
            var first = allProjects.FirstOrDefault(entry => entry.DisplayName.Contains("Mallet", StringComparison.OrdinalIgnoreCase))
                ?? allProjects.FirstOrDefault();
            if (first is not null) LoadProject(first.Path);
            FooterStatus.Text = "Ready — builds are staged only; no live game file is modified.";
            _ = RefreshAbilityCatalogAsync(forceRebuild: false);
        }
        catch (Exception exception)
        {
            ShowFailure("Startup failed", exception);
        }
    }

    private static string NormalizeSourceText(string value) =>
        value.Replace("\r\n", "\n", StringComparison.Ordinal).Replace('\r', '\n');

    private static string CompanionPath(string readablePath, string suffix)
    {
        var directory = Path.GetDirectoryName(readablePath)
            ?? throw new InvalidDataException($"Source path has no parent directory: {readablePath}");
        return Path.Combine(directory, Path.GetFileNameWithoutExtension(readablePath) + suffix);
    }

    private string? RenderedSemanticBase(string moduleBodyKey)
    {
        if (workspace is null || string.IsNullOrWhiteSpace(moduleBodyKey)) return null;
        var candidate = Path.Combine(workspace.RenderedSourceRoot, moduleBodyKey + ".luau");
        if (!File.Exists(candidate)) return null;
        var requiredCompanions = new[]
        {
            ".fidelity.luau", ".names.tsv", ".calls.tsv", ".closures.tsv", ".semantic-view.json",
        };
        return requiredCompanions.All(suffix => File.Exists(CompanionPath(candidate, suffix)))
            ? candidate
            : null;
    }

    private void SetSourceDocument(string source, string? sourcePath, string? semanticBasePath = null)
    {
        settingSourceEditorText = true;
        try
        {
            SourceEditor.Text = source;
        }
        finally
        {
            settingSourceEditorText = false;
        }
        if (!string.IsNullOrWhiteSpace(sourcePath)) SourcePathText.Text = sourcePath;
        if (semanticBasePath is null)
        {
            ClearSemanticCompanions("No verified fidelity/name-map companions are available for this source.");
        }
        else
        {
            LoadSemanticCompanions(semanticBasePath);
        }
        semanticBaseWasFreshWhenLoaded = semanticBaseReadableText is not null
            && string.Equals(
                NormalizeSourceText(source),
                NormalizeSourceText(semanticBaseReadableText),
                StringComparison.Ordinal);
        UpdateSemanticFreshness();
    }

    private void ClearSemanticCompanions(string message)
    {
        semanticBaseReadablePath = null;
        semanticBaseReadableText = null;
        semanticBaseWasFreshWhenLoaded = false;
        semanticClosureMapLoaded = false;
        semanticVerificationLoaded = false;
        semanticVerificationDocument = null;
        ResetSourceCallsiteAnnotations("INLINE API EVIDENCE — no hash-validated callsite proof is loaded.");
        semanticSummaryBase = message;
        semanticNameRows.Clear();
        closureRows.Clear();
        exportRows.Clear();
        prototypeOutlineRows.Clear();
        prototypeRelationRows.Clear();
        semanticApiEvidenceRows.Clear();
        semanticCallsiteRows.Clear();
        SemanticPrototypeBox.ItemsSource = new[] { "All prototypes" };
        SemanticPrototypeBox.SelectedIndex = 0;
        SemanticMapSummary.Text = message;
        SemanticStateText.Text = "NO PROVENANCE MAP";
        SemanticStateText.Foreground = new SolidColorBrush(Color.FromRgb(213, 168, 93));
        FidelityEditor.Clear();
        FidelityPathText.Text = "No fidelity companion is loaded.";
        ClosureMapSummary.Text = "No validated closure ownership map is loaded.";
        SemanticVerificationSummary.Text = "No semantic verification document is loaded.";
        SemanticVerificationPathText.Text = "No semantic verification path.";
        SemanticVerificationEditor.Clear();
        SemanticIdentityEvidenceText.Text = "Select an identity to see its exact presentation status and behavior-evidence boundary.";
        PrototypeOutlineSummary.Text = "No verified prototype outline is loaded.";
        SemanticApiEvidenceSummary.Text = "No verified API evidence index is loaded.";
        SemanticCallsiteSummary.Text = "Select a resolved ability or load a project with a verified stock target to generate its instruction-addressed API call map.";
        semanticNameView?.Refresh();
    }

    private void LoadSemanticCompanions(string readablePath)
    {
        var fidelityPath = CompanionPath(readablePath, ".fidelity.luau");
        var namingMapPath = CompanionPath(readablePath, ".names.tsv");
        var callMapPath = CompanionPath(readablePath, ".calls.tsv");
        var closureMapPath = CompanionPath(readablePath, ".closures.tsv");
        var semanticViewPath = CompanionPath(readablePath, ".semantic-view.json");
        var hasFidelity = File.Exists(fidelityPath);
        var hasNamingMap = File.Exists(namingMapPath);
        if (!hasFidelity && !hasNamingMap)
        {
            ClearSemanticCompanions("No verified fidelity/name-map companions are available for this source.");
            return;
        }
        if (!File.Exists(readablePath))
            throw new FileNotFoundException("Readable source for the semantic companions is missing.", readablePath);
        if (!hasFidelity)
            throw new FileNotFoundException("Fidelity source companion is missing.", fidelityPath);
        if (!hasNamingMap)
            throw new FileNotFoundException("Semantic naming-map companion is missing.", namingMapPath);

        var namingMap = SemanticNamingMap.Load(namingMapPath);
        semanticBaseReadablePath = readablePath;
        semanticBaseReadableText = File.ReadAllText(readablePath);
        FidelityEditor.Text = File.ReadAllText(fidelityPath);
        FidelityPathText.Text = fidelityPath;

        semanticNameRows.Clear();
        foreach (var entry in namingMap.Entries.OrderBy(entry => entry.Prototype).ThenBy(entry => entry.Web))
            semanticNameRows.Add(entry);

        ClosureOwnershipMap? closureMap = null;
        closureRows.Clear();
        if (File.Exists(closureMapPath))
        {
            closureMap = ClosureOwnershipMap.Load(closureMapPath);
            foreach (var entry in closureMap.Entries
                .OrderBy(entry => entry.ParentPrototype)
                .ThenBy(entry => entry.Instruction))
                closureRows.Add(entry);
            semanticClosureMapLoaded = true;
            ClosureMapSummary.Text = $"Validated {closureMap.Entries.Count} closure sites, {closureMap.CaptureCount} ordered captures, "
                + $"and {closureMap.PrototypeCount} referenced prototypes. Every row is fail-closed PASS.";
        }
        else
        {
            semanticClosureMapLoaded = false;
            ClosureMapSummary.Text = $"Closure ownership companion is missing: {closureMapPath}. Rerender this module before relying on closure navigation.";
        }

        SemanticVerificationEditor.Clear();
        exportRows.Clear();
        prototypeOutlineRows.Clear();
        prototypeRelationRows.Clear();
        semanticApiEvidenceRows.Clear();
        semanticCallsiteRows.Clear();
        if (closureMap is not null && File.Exists(semanticViewPath))
        {
            var semanticVerification = SemanticVerificationDocument.Load(
                semanticViewPath,
                readablePath,
                fidelityPath,
                namingMapPath,
                closureMapPath,
                callMapPath,
                namingMap,
                closureMap);
            semanticVerificationLoaded = true;
            semanticVerificationDocument = semanticVerification;
            SemanticVerificationSummary.Text = semanticVerification.Summary;
            SemanticVerificationPathText.Text = semanticVerification.Path;
            SemanticVerificationEditor.Text = semanticVerification.RawJson;
            foreach (var entry in semanticVerification.Exports) exportRows.Add(entry);
            foreach (var entry in semanticVerification.Callsites) semanticCallsiteRows.Add(entry);
            SemanticCallsiteSummary.Text = semanticVerification.SchemaVersion >= 2
                ? $"Verified {semanticVerification.ApiCallsiteCount} exact instruction-addressed calls projected as {semanticVerification.ApiCallExpressionCount} source expressions; "
                    + $"registered={semanticVerification.RegisteredApiCallsiteCount}, confirmed={semanticVerification.ConfirmedApiCallsiteCount}, "
                    + $"unresolved={semanticVerification.UnresolvedApiCallsiteCount}, unregistered={semanticVerification.UnregisteredApiCallsiteCount}, "
                    + $"ambiguous={semanticVerification.AmbiguousApiCallsiteCount}, observed arity mismatches={semanticVerification.ObservedContractMismatchCount}, "
                    + $"receiver-typed joins={semanticVerification.Callsites.Count(call => call.SourceOccurrence == 0 && call.DescriptorJoin == "RECEIVER_TYPE")}, "
                    + $"unique-name candidates={semanticVerification.Callsites.Count(call => call.SourceOccurrence == 0 && call.DescriptorJoin == "UNIQUE_METHOD_NAME")}, "
                    + $"receiver conflicts={semanticVerification.Callsites.Count(call => call.SourceOccurrence == 0 && call.DescriptorJoin == "RECEIVER_TYPE_CONFLICT")}, confirmed violations=0."
                : "Legacy semantic proof V1 has no instruction-addressed API callsite map; rerender this module.";
            var prototypeGraph = SemanticPrototypeGraph.Build(namingMap, closureMap, semanticVerification);
            foreach (var node in prototypeGraph.Nodes) prototypeOutlineRows.Add(node);
            foreach (var relation in prototypeGraph.Relations) prototypeRelationRows.Add(relation);
            PrototypeOutlineSummary.Text = prototypeGraph.Summary;
            var apiEvidenceIndex = SemanticApiEvidenceIndex.Build(namingMap, semanticVerification);
            foreach (var contract in apiEvidenceIndex.Contracts) semanticApiEvidenceRows.Add(contract);
            SemanticApiEvidenceSummary.Text = apiEvidenceIndex.Summary;
        }
        else
        {
            semanticVerificationLoaded = false;
            semanticVerificationDocument = null;
            SemanticVerificationSummary.Text = File.Exists(semanticViewPath)
                ? "Semantic proof cannot be validated because its closure companion is missing."
                : $"Semantic verification companion is missing: {semanticViewPath}. Rerender before treating aliases as verified.";
            SemanticVerificationPathText.Text = semanticViewPath;
            PrototypeOutlineSummary.Text = "Verified outline unavailable: the hash-bound semantic proof and closure map are both required.";
            SemanticApiEvidenceSummary.Text = "Verified API evidence index unavailable: a hash-bound semantic proof is required.";
            SemanticCallsiteSummary.Text = File.Exists(callMapPath)
                ? "API callsite map exists but cannot be trusted without its matching hash-bound semantic proof."
                : $"API callsite companion is missing: {callMapPath}. Rerender this module.";
        }

        var prototypeIds = semanticNameRows.Select(entry => entry.Prototype)
            .Concat(closureRows.SelectMany(entry => new[] { entry.ParentPrototype, entry.TargetPrototype }))
            .Distinct()
            .OrderBy(value => value);
        var prototypes = new[] { "All prototypes" }.Concat(
            prototypeIds.Select(value => $"Prototype {value}"));
        SemanticPrototypeBox.ItemsSource = prototypes.ToArray();
        SemanticPrototypeBox.SelectedIndex = 0;

        var confidence = semanticNameRows
            .Where(entry => !string.IsNullOrWhiteSpace(entry.Confidence))
            .GroupBy(entry => entry.Confidence, StringComparer.Ordinal)
            .OrderByDescending(group => group.Count())
            .ThenBy(group => group.Key, StringComparer.Ordinal)
            .Select(group => $"{group.Key}={group.Count()}");
        semanticSummaryBase = $"Validated {namingMap.Entries.Count} value-web rows spanning {namingMap.PrototypeCount} prototypes; "
            + $"aliases={namingMap.AliasCount}, typed={namingMap.TypedWebCount}; {string.Join(", ", confidence)}. "
            + "Unknown and ambiguous identities remain canonical rather than guessed. "
            + (semanticVerificationLoaded
                ? semanticVerificationDocument?.SchemaVersion >= 2
                    ? "The independent semantic proof is hash-bound to both source views and all three evidence sidecars."
                    : "The legacy proof is hash-bound to both source views and its name/closure sidecars."
                : "No independent hash-bound semantic proof is active.");
        semanticNameView?.Refresh();
        UpdateSemanticIdentityEvidence();
    }

    private void UpdateSemanticFreshness()
    {
        if (semanticBaseReadableText is null)
        {
            SemanticMapSummary.Text = semanticSummaryBase;
            ResetSourceCallsiteAnnotations("INLINE API EVIDENCE — no hash-validated callsite proof is loaded.");
            return;
        }
        var matches = string.Equals(
            NormalizeSourceText(SourceEditor.Text),
            NormalizeSourceText(semanticBaseReadableText),
            StringComparison.Ordinal);
        SemanticStateText.Text = !matches
            ? "BASE PROVENANCE — SOURCE EDITED"
            : semanticVerificationLoaded
                ? "SEMANTIC PROOF MATCHES"
                : semanticClosureMapLoaded
                    ? "MAPS PRESENT — PROOF MISSING"
                    : "NAME MAP MATCHES — CLOSURES MISSING";
        SemanticStateText.Foreground = new SolidColorBrush(matches && semanticClosureMapLoaded && semanticVerificationLoaded
            ? Color.FromRgb(139, 197, 130)
            : Color.FromRgb(226, 176, 91));
        SemanticMapSummary.Text = semanticSummaryBase + (matches
            ? semanticVerificationLoaded
                ? " The readable source still matches the verified generated base."
                : " The readable source matches its generated base, but automatic rewriting remains disabled without the proof document."
            : " The editable source differs from the generated base; identities are shown for reference and must be regenerated or structurally rebased before automatic rewriting.");
        UpdateSourceCallsiteAnnotations(matches);
        UpdateSemanticIdentityEvidence();
    }

    private void SourceEditor_Loaded(object sender, RoutedEventArgs e)
    {
        if (sourceCallsiteAdorner is not null)
        {
            sourceCallsiteAdorner.SetAnnotations(sourceCallAnnotations);
            return;
        }
        var layer = AdornerLayer.GetAdornerLayer(SourceEditor);
        if (layer is null)
        {
            ResetSourceCallsiteAnnotations("INLINE API EVIDENCE DISABLED — the source editor has no adorner layer.", isError: true);
            return;
        }
        sourceCallsiteAdorner = new SemanticCallsiteAdorner(SourceEditor);
        layer.Add(sourceCallsiteAdorner);
        sourceCallsiteAdorner.SetAnnotations(sourceCallAnnotations);
    }

    private void UpdateSourceCallsiteAnnotations(bool sourceMatchesVerifiedBase)
    {
        if (!sourceMatchesVerifiedBase)
        {
            ResetSourceCallsiteAnnotations(
                "INLINE API EVIDENCE DISABLED — edited source no longer matches the hash-validated base. Regenerate or structurally rebase before using exact spans.");
            return;
        }
        if (semanticVerificationDocument is null || semanticVerificationDocument.SchemaVersion < 2)
        {
            ResetSourceCallsiteAnnotations(
                "INLINE API EVIDENCE — a hash-validated semantic proof V2 or newer is required.");
            return;
        }

        try
        {
            var callsites = semanticVerificationDocument.Callsites;
            var byteBoundaries = callsites.SelectMany(callsite => new[]
            {
                callsite.ReadableSpan.ByteOffset,
                checked(callsite.ReadableSpan.ByteOffset + callsite.ReadableSpan.ByteLength),
            });
            var textOffsets = MapUtf8ByteBoundaries(SourceEditor.Text, byteBoundaries);
            sourceCallAnnotations = callsites
                .Select(callsite =>
                {
                    var start = textOffsets[callsite.ReadableSpan.ByteOffset];
                    var end = textOffsets[checked(callsite.ReadableSpan.ByteOffset + callsite.ReadableSpan.ByteLength)];
                    if (end <= start)
                        throw new InvalidDataException("Verified API callsite span projected to an empty source range.");
                    return new SemanticCallsiteAnnotation(
                        start,
                        end - start,
                        callsite,
                        SemanticCallsitePresenter.Build(callsite));
                })
                .OrderBy(annotation => annotation.Offset)
                .ThenBy(annotation => annotation.Length)
                .ToArray();
            sourceCallsiteAdorner?.SetAnnotations(sourceCallAnnotations);
            CloseSourceCallTooltip();

            var exactCalls = semanticVerificationDocument.Callsites
                .Where(call => call.SourceOccurrence == 0)
                .ToArray();
            var unresolved = exactCalls.Count(call => call.Contract.Status == "UNRESOLVED");
            var ambiguous = exactCalls.Count(call => call.Contract.Match == "AMBIGUOUS");
            var observedMismatch = exactCalls.Count(call => call.Contract.Match == "OBSERVED_MISMATCH");
            var receiverConflicts = exactCalls.Count(call => call.DescriptorJoin == "RECEIVER_TYPE_CONFLICT");
            var warningExpressions = sourceCallAnnotations.Count(annotation => annotation.Presentation.IsWarning);
            SourceCallDiagnosticsSummary.Text =
                $"INLINE API EVIDENCE — {sourceCallAnnotations.Count} exact expressions; warning expressions={warningExpressions} "
                + $"(unresolved calls={unresolved}, ambiguous={ambiguous}, observed mismatches={observedMismatch}, receiver conflicts={receiverConflicts}). "
                + "Dotted blue marks exact callsite evidence; amber/red marks calls that must not be rewritten automatically. Hover a marked call for its contract and evidence boundary.";
            SourceCallDiagnosticsSummary.Foreground = new SolidColorBrush(
                observedMismatch > 0 ? Color.FromRgb(229, 95, 95)
                : warningExpressions > 0 ? Color.FromRgb(226, 176, 91)
                : Color.FromRgb(139, 197, 130));
        }
        catch (Exception exception) when (exception is InvalidDataException or ArgumentException or OverflowException)
        {
            ResetSourceCallsiteAnnotations(
                $"INLINE API EVIDENCE DISABLED — verified spans could not be projected into the source editor: {exception.Message}",
                isError: true);
        }
    }

    private void ResetSourceCallsiteAnnotations(string message, bool isError = false)
    {
        sourceCallAnnotations = [];
        sourceCallsiteAdorner?.SetAnnotations(sourceCallAnnotations);
        CloseSourceCallTooltip();
        SourceCallDiagnosticsSummary.Text = message;
        SourceCallDiagnosticsSummary.Foreground = new SolidColorBrush(isError
            ? Color.FromRgb(229, 95, 95)
            : Color.FromRgb(154, 156, 166));
    }

    private void SourceEditor_MouseMove(object sender, MouseEventArgs e)
    {
        if (sourceCallAnnotations.Count == 0) return;
        var characterIndex = SourceEditor.GetCharacterIndexFromPoint(e.GetPosition(SourceEditor), snapToText: false);
        var annotation = characterIndex < 0
            ? null
            : sourceCallAnnotations
                .Where(candidate => candidate.Contains(characterIndex))
                .OrderByDescending(candidate => candidate.Presentation.IsWarning)
                .ThenBy(candidate => candidate.Length)
                .FirstOrDefault();
        if (ReferenceEquals(annotation, hoveredSourceCallAnnotation)) return;
        CloseSourceCallTooltip();
        if (annotation is null) return;

        hoveredSourceCallAnnotation = annotation;
        var tooltip = new ToolTip
        {
            Background = new SolidColorBrush(Color.FromRgb(28, 29, 34)),
            BorderBrush = annotation.Presentation.MarkerKind == SemanticCallsiteMarkerKind.ObservedMismatch
                ? new SolidColorBrush(Color.FromRgb(229, 95, 95))
                : annotation.Presentation.IsWarning
                    ? new SolidColorBrush(Color.FromRgb(226, 176, 91))
                    : new SolidColorBrush(Color.FromRgb(83, 126, 145)),
            BorderThickness = new Thickness(1),
            Padding = new Thickness(9, 7, 9, 7),
            MaxWidth = 720,
            Placement = System.Windows.Controls.Primitives.PlacementMode.Mouse,
            IsHitTestVisible = false,
            Content = new TextBlock
            {
                Text = annotation.Presentation.Tooltip,
                Foreground = new SolidColorBrush(Color.FromRgb(232, 232, 234)),
                TextWrapping = TextWrapping.Wrap,
                FontFamily = new FontFamily("Cascadia Mono, Consolas"),
                FontSize = 12,
            },
        };
        SourceEditor.ToolTip = tooltip;
        tooltip.IsOpen = true;
    }

    private void SourceEditor_MouseLeave(object sender, MouseEventArgs e) => CloseSourceCallTooltip();

    private void CloseSourceCallTooltip()
    {
        if (SourceEditor.ToolTip is ToolTip tooltip) tooltip.IsOpen = false;
        SourceEditor.ToolTip = null;
        hoveredSourceCallAnnotation = null;
    }

    private static IReadOnlyDictionary<int, int> MapUtf8ByteBoundaries(
        string text,
        IEnumerable<int> requestedBoundaries)
    {
        var utf8 = new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true);
        var bytes = utf8.GetBytes(text);
        var boundaries = requestedBoundaries.Distinct().OrderBy(value => value).ToArray();
        if (boundaries.Length == 0) return new Dictionary<int, int>();
        if (boundaries[0] < 0 || boundaries[^1] > bytes.Length)
            throw new InvalidDataException("Verified UTF-8 callsite boundary is outside the current source document.");

        var mapped = new Dictionary<int, int>(boundaries.Length);
        var previousByte = 0;
        var previousCharacter = 0;
        foreach (var boundary in boundaries)
        {
            previousCharacter += utf8.GetCharCount(bytes, previousByte, boundary - previousByte);
            mapped.Add(boundary, previousCharacter);
            previousByte = boundary;
        }
        return mapped;
    }

    private void SemanticRowsGrid_SelectionChanged(object sender, SelectionChangedEventArgs e) =>
        UpdateSemanticIdentityEvidence();

    private void UpdateSemanticIdentityEvidence()
    {
        if (SemanticRowsGrid.SelectedItem is not SemanticNameEntry entry)
        {
            SemanticIdentityEvidenceText.Text =
                "Select an identity to see its exact presentation status and behavior-evidence boundary.";
            return;
        }

        var occurrenceState = "NO HASH-BOUND PROOF";
        if (semanticVerificationDocument is not null
            && semanticVerificationDocument.Occurrences.TryGetValue(
                (entry.Prototype, entry.Web), out var occurrences))
        {
            occurrenceState = occurrences.Count == 0
                ? "PROVEN SIDECAR-ONLY"
                : $"PROVEN SOURCE-MAPPED · exact occurrences={occurrences.Count}";
        }
        var freshness = SemanticSourceIsFresh() ? "verified base unchanged" : "editable base changed";
        var behaviorBoundary = entry.Confidence switch
        {
            "EXACT_EXPORT" => "Exact export identity; function behavior is not inferred by the export relation.",
            "API_CONTRACT" => "API contract/stock-bytecode evidence; this is not automatically a live gameplay confirmation.",
            "CORPUS_CATALOG" => "Corpus catalog evidence only; signature or behavior may still be incomplete.",
            "STRUCTURAL" => "Structural dataflow label only; native API behavior is not established.",
            _ => "No behavior confidence grade; preserve the canonical identity and do not infer meaning.",
        };
        SemanticIdentityEvidenceText.Text =
            $"p{entry.Prototype}/web{entry.Web} · {entry.DisplayName} ← {entry.Canonical} · {occurrenceState} · {freshness}\n"
            + $"Behavior boundary: {behaviorBoundary}\n"
            + $"Name evidence [{entry.Confidence}]: {entry.Evidence}\n"
            + $"Type [{entry.SemanticType}] [{entry.TypeConfidence}]: {entry.TypeEvidence}";
    }

    private bool SemanticEntryMatches(object item)
    {
        if (item is not SemanticNameEntry entry) return false;
        if (SemanticPrototypeBox.SelectedItem is string selected
            && !string.Equals(selected, "All prototypes", StringComparison.Ordinal))
        {
            const string prefix = "Prototype ";
            if (!selected.StartsWith(prefix, StringComparison.Ordinal)
                || !int.TryParse(selected[prefix.Length..], NumberStyles.None, CultureInfo.InvariantCulture, out var prototype)
                || entry.Prototype != prototype)
                return false;
        }
        var query = SemanticFilterBox.Text.Trim();
        return query.Length == 0 || entry.SearchText.Contains(query, StringComparison.OrdinalIgnoreCase);
    }

    private void JumpToSemanticIdentity(bool fidelity)
    {
        if (SemanticRowsGrid.SelectedItem is not SemanticNameEntry entry)
        {
            FooterStatus.Text = "Select an API/identity row before jumping to source.";
            return;
        }
        var editor = fidelity ? FidelityEditor : SourceEditor;
        if (semanticVerificationDocument is not null
            && semanticVerificationDocument.Occurrences.TryGetValue(
                (entry.Prototype, entry.Web), out var verifiedOccurrences))
        {
            if (verifiedOccurrences.Count == 0)
            {
                FooterStatus.Text = $"Identity {entry.Canonical} is proven sidecar-only in this source view.";
                return;
            }
            if (!fidelity && !SemanticSourceIsFresh())
            {
                FooterStatus.Text = "Exact readable navigation is disabled because the editable source no longer matches the verified hash.";
                return;
            }
            var candidates = verifiedOccurrences
                .Select(occurrence => fidelity ? occurrence.Fidelity : occurrence.Readable)
                .Select(span => (Span: span, Selection: Utf8SpanToTextSelection(editor.Text, span)))
                .OrderBy(candidate => candidate.Selection.Offset)
                .ToArray();
            var selected = candidates.FirstOrDefault(candidate => candidate.Selection.Offset >= editor.CaretIndex);
            if (selected.Span is null) selected = candidates[0];
            SelectVerifiedSpan(editor, selected.Selection, fidelity ? 1 : 0);
            FooterStatus.Text = $"Selected verified span for prototype {entry.Prototype}, value web {entry.Web}: {entry.Canonical}.";
            return;
        }

        var token = fidelity ? entry.Canonical : entry.DisplayName;
        var start = Math.Min(editor.CaretIndex + Math.Max(editor.SelectionLength, 1), editor.Text.Length);
        var index = editor.Text.IndexOf(token, start, StringComparison.Ordinal);
        if (index < 0) index = editor.Text.IndexOf(token, StringComparison.Ordinal);
        if (index < 0 && !fidelity && !string.Equals(token, entry.Canonical, StringComparison.Ordinal))
        {
            token = entry.Canonical;
            index = editor.Text.IndexOf(token, StringComparison.Ordinal);
        }
        if (index < 0)
        {
            FooterStatus.Text = $"Identity {entry.Canonical} is sidecar-only in this source view.";
            return;
        }
        SourceWorkspaceTabs.SelectedIndex = fidelity ? 1 : 0;
        editor.Focus();
        editor.Select(index, token.Length);
        editor.ScrollToLine(editor.GetLineIndexFromCharacterIndex(index));
        FooterStatus.Text = $"Selected prototype {entry.Prototype}, value web {entry.Web} by unverified text search; rerender for exact spans.";
    }

    private void ShowClosurePrototype(bool target)
    {
        if (ClosureRowsGrid.SelectedItem is not ClosureOwnershipEntry entry)
        {
            FooterStatus.Text = "Select a closure ownership row first.";
            return;
        }
        var prototype = target ? entry.TargetPrototype : entry.ParentPrototype;
        SemanticPrototypeBox.SelectedItem = $"Prototype {prototype}";
        SourceWorkspaceTabs.SelectedIndex = 2;
        FooterStatus.Text = $"Showing API/value-web identities for prototype {prototype}.";
    }

    private void JumpToClosureTarget()
    {
        if (ClosureRowsGrid.SelectedItem is not ClosureOwnershipEntry entry)
        {
            FooterStatus.Text = "Select a closure ownership row first.";
            return;
        }
        if (semanticVerificationDocument is not null)
        {
            if (!SemanticSourceIsFresh())
            {
                FooterStatus.Text = "Exact closure-target navigation is disabled because the editable source no longer matches the verified hash.";
                return;
            }
            var verifiedSpan = semanticNameRows
                .Where(name => name.Prototype == entry.TargetPrototype)
                .SelectMany(name => semanticVerificationDocument.Occurrences.TryGetValue(
                    (name.Prototype, name.Web), out var occurrences)
                        ? occurrences
                        : [])
                .Select(occurrence => occurrence.Readable)
                .OrderBy(span => span.ByteOffset)
                .FirstOrDefault();
            if (verifiedSpan is not null)
            {
                var selection = Utf8SpanToTextSelection(SourceEditor.Text, verifiedSpan);
                SelectVerifiedSpan(SourceEditor, selection, 0);
                FooterStatus.Text = $"Selected first verified value span for closure target prototype {entry.TargetPrototype}.";
                return;
            }
            FooterStatus.Text = $"Closure target prototype {entry.TargetPrototype} has no source-mapped identity span; it remains sidecar-only.";
            return;
        }

        var tokens = new[] { $"p{entry.TargetPrototype}_", $"v{entry.TargetPrototype}_" };
        var token = tokens.FirstOrDefault(candidate => SourceEditor.Text.Contains(candidate, StringComparison.Ordinal));
        if (token is null)
        {
            FooterStatus.Text = $"Target prototype {entry.TargetPrototype} has no canonical token in the readable source.";
            return;
        }
        var index = SourceEditor.Text.IndexOf(token, StringComparison.Ordinal);
        SourceWorkspaceTabs.SelectedIndex = 0;
        SourceEditor.Focus();
        SourceEditor.Select(index, token.Length);
        SourceEditor.ScrollToLine(SourceEditor.GetLineIndexFromCharacterIndex(index));
        FooterStatus.Text = $"Selected a closure-target token by unverified text search; rerender for exact spans.";
    }

    private void ShowOutlinePrototype_Click(object sender, RoutedEventArgs e)
    {
        if (PrototypeOutlineGrid.SelectedItem is not SemanticPrototypeNode node)
        {
            FooterStatus.Text = "Select a verified prototype row first.";
            return;
        }
        ShowPrototypeIdentities(node.Prototype);
    }

    private void JumpOutlinePrototype_Click(object sender, RoutedEventArgs e)
    {
        if (PrototypeOutlineGrid.SelectedItem is not SemanticPrototypeNode node)
        {
            FooterStatus.Text = "Select a verified prototype row first.";
            return;
        }
        JumpToVerifiedPrototype(node.Prototype);
    }

    private void ShowOutlineRelationTarget_Click(object sender, RoutedEventArgs e)
    {
        if (PrototypeRelationsGrid.SelectedItem is not SemanticPrototypeRelation relation)
        {
            FooterStatus.Text = "Select an exact export/closure relation first.";
            return;
        }
        ShowPrototypeIdentities(relation.TargetPrototype);
    }

    private void JumpOutlineRelationTarget_Click(object sender, RoutedEventArgs e)
    {
        if (PrototypeRelationsGrid.SelectedItem is not SemanticPrototypeRelation relation)
        {
            FooterStatus.Text = "Select an exact export/closure relation first.";
            return;
        }
        JumpToVerifiedPrototype(relation.TargetPrototype);
    }

    private void ShowPrototypeIdentities(int prototype)
    {
        SemanticPrototypeBox.SelectedItem = $"Prototype {prototype}";
        SourceWorkspaceTabs.SelectedIndex = 2;
        FooterStatus.Text = $"Showing verified API/value-web evidence for prototype {prototype}.";
    }

    private void JumpToVerifiedPrototype(int prototype)
    {
        if (semanticVerificationDocument is null)
        {
            FooterStatus.Text = "Verified prototype navigation requires a hash-bound semantic proof.";
            return;
        }
        if (!SemanticSourceIsFresh())
        {
            FooterStatus.Text = "Verified prototype navigation is disabled because the editable source changed.";
            return;
        }
        var span = semanticNameRows
            .Where(entry => entry.Prototype == prototype)
            .SelectMany(entry => semanticVerificationDocument.Occurrences.TryGetValue(
                (entry.Prototype, entry.Web), out var occurrences) ? occurrences : [])
            .Select(occurrence => occurrence.Readable)
            .OrderBy(candidate => candidate.ByteOffset)
            .FirstOrDefault();
        if (span is null)
        {
            FooterStatus.Text = $"Prototype {prototype} has no verified source-mapped identity; its evidence remains sidecar-only.";
            return;
        }
        SelectVerifiedSpan(SourceEditor, Utf8SpanToTextSelection(SourceEditor.Text, span), 0);
        FooterStatus.Text = $"Selected the first exact source-mapped identity for prototype {prototype}.";
    }

    private void ShowApiEvidenceIdentities_Click(object sender, RoutedEventArgs e)
    {
        if (SemanticApiEvidenceGrid.SelectedItem is not SemanticApiEvidenceContract contract)
        {
            FooterStatus.Text = "Select a verified API evidence descriptor first.";
            return;
        }
        SemanticFilterBox.Text = contract.Descriptor;
        SemanticPrototypeBox.SelectedIndex = 0;
        SourceWorkspaceTabs.SelectedIndex = 2;
        FooterStatus.Text = $"Showing exact identity rows bound to {contract.DisplayName}; these are not callsite counts.";
    }

    private void JumpApiEvidenceIdentity_Click(object sender, RoutedEventArgs e)
    {
        if (SemanticApiEvidenceGrid.SelectedItem is not SemanticApiEvidenceContract contract)
        {
            FooterStatus.Text = "Select a verified API evidence descriptor first.";
            return;
        }
        var identity = semanticNameRows.FirstOrDefault(entry =>
            entry.Evidence.StartsWith(contract.Descriptor + ";", StringComparison.Ordinal));
        if (identity is null)
        {
            FooterStatus.Text = $"No identity row remains bound to {contract.Descriptor}.";
            return;
        }
        SemanticFilterBox.Text = contract.Descriptor;
        SemanticPrototypeBox.SelectedIndex = 0;
        SemanticRowsGrid.SelectedItem = identity;
        SemanticRowsGrid.ScrollIntoView(identity);
        JumpToSemanticIdentity(fidelity: false);
    }

    private void JumpToApiCallsite(bool fidelity)
    {
        if (SemanticCallsiteGrid.SelectedItem is not SemanticCallsiteEntry callsite)
        {
            FooterStatus.Text = "Select an exact API callsite row first.";
            return;
        }
        if (semanticVerificationDocument is null || semanticVerificationDocument.SchemaVersion < 2)
        {
            FooterStatus.Text = "Exact API callsite navigation requires a hash-bound semantic proof V2.";
            return;
        }
        if (!fidelity && !SemanticSourceIsFresh())
        {
            FooterStatus.Text = "Exact readable callsite navigation is disabled because the editable source changed.";
            return;
        }
        var editor = fidelity ? FidelityEditor : SourceEditor;
        var span = fidelity ? callsite.FidelitySpan : callsite.ReadableSpan;
        SelectVerifiedSpan(editor, Utf8SpanToTextSelection(editor.Text, span), fidelity ? 1 : 0);
        FooterStatus.Text = $"Selected exact {callsite.Kind} call at prototype {callsite.Prototype}, instruction {callsite.Instruction}, source occurrence {callsite.SourceOccurrence}; contract={callsite.ContractStatus}, arity={callsite.Contract.Match}.";
    }

    private bool SemanticSourceIsFresh() => semanticBaseReadableText is not null
        && string.Equals(
            NormalizeSourceText(SourceEditor.Text),
            NormalizeSourceText(semanticBaseReadableText),
            StringComparison.Ordinal);

    private static (int Offset, int Length) Utf8SpanToTextSelection(
        string text,
        SemanticSourceSpan span)
    {
        var utf8 = new UTF8Encoding(encoderShouldEmitUTF8Identifier: false, throwOnInvalidBytes: true);
        var bytes = utf8.GetBytes(text);
        if (span.ByteOffset < 0 || span.ByteLength <= 0
            || span.ByteOffset > bytes.Length - span.ByteLength)
            throw new InvalidDataException("Verified UTF-8 byte span is outside the current source document.");
        var prefix = utf8.GetString(bytes, 0, span.ByteOffset);
        var token = utf8.GetString(bytes, span.ByteOffset, span.ByteLength);
        if (token.Length == 0)
            throw new InvalidDataException("Verified UTF-8 byte span decodes to an empty token.");
        return (prefix.Length, token.Length);
    }

    private void SelectVerifiedSpan(TextBox editor, (int Offset, int Length) selection, int tabIndex)
    {
        SourceWorkspaceTabs.SelectedIndex = tabIndex;
        editor.Focus();
        editor.Select(selection.Offset, selection.Length);
        editor.ScrollToLine(editor.GetLineIndexFromCharacterIndex(selection.Offset));
    }

    private void ExportRowsGrid_MouseDoubleClick(object sender, System.Windows.Input.MouseButtonEventArgs e)
    {
        if (ExportRowsGrid.SelectedItem is not SemanticExportEntry export) return;
        var identity = semanticNameRows.FirstOrDefault(entry =>
            entry.Prototype == export.Prototype && entry.Web == export.Web);
        if (identity is null)
        {
            FooterStatus.Text = $"Exact export {export.ExportedName} has no matching naming-map row.";
            return;
        }
        SemanticRowsGrid.SelectedItem = identity;
        JumpToSemanticIdentity(fidelity: false);
    }

    private void RefreshProjects()
    {
        if (workspace is null) return;
        allProjects.Clear();
        var roots = new[] { Path.Combine(workspace.EditorRoot, "EXAMPLES"), workspace.ProjectsRoot };
        foreach (var root in roots.Where(Directory.Exists))
        {
            foreach (var file in Directory.EnumerateFiles(root, "*.json", SearchOption.AllDirectories))
            {
                try
                {
                    var candidate = AbilityProject.Load(file);
                    allProjects.Add(new ProjectEntry(
                        file,
                        $"{candidate.Warframe} — {candidate.Ability}\n{candidate.ProjectId}",
                        candidate.Mode));
                }
                catch
                {
                    // Non-project JSON files are deliberately ignored by the project browser.
                }
            }
        }
        ApplySearch();
    }

    private void ApplySearch()
    {
        var needle = SearchBox.Text.Trim();
        ProjectList.ItemsSource = allProjects
            .Where(entry => needle.Length == 0 || entry.DisplayName.Contains(needle, StringComparison.OrdinalIgnoreCase))
            .OrderBy(entry => entry.DisplayName, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private async Task RefreshAbilityCatalogAsync(bool forceRebuild)
    {
        if (workspace is null) return;
        try
        {
            var snapshot = Directory.EnumerateDirectories(workspace.MetadataSnapshotsRoot)
                .OrderByDescending(Path.GetFileName, StringComparer.OrdinalIgnoreCase)
                .FirstOrDefault() ?? throw new DirectoryNotFoundException("No metadata snapshot is available.");
            if (forceRebuild || !File.Exists(workspace.CatalogPath) || !File.Exists(workspace.LocalizedNamesPath))
            {
                CatalogSummary.Text = "Building deterministic catalog…";
                string? cache = null;
                string localizationDiagnostic = string.Empty;
                try { cache = await Task.Run(() => InstalledGameData.RefreshEnglishNames(workspace)); }
                catch (Exception exception)
                {
                    localizationDiagnostic = "WARNING [LOCALIZED_NAMES] " + exception.Message + Environment.NewLine
                        + "Catalog will use explicit internal-name fallbacks.";
                }
                var arguments = new List<string>
                {
                    "build-catalog", "--metadata", snapshot, "--corpus", workspace.CorpusRoot, "--output", workspace.CatalogPath,
                };
                if (File.Exists(workspace.LocalizedNamesPath))
                {
                    arguments.Add("--names");
                    arguments.Add(workspace.LocalizedNamesPath);
                }
                var result = await CliBridge.RunAsync(workspace, arguments);
                DiagnosticsBox.Text = localizationDiagnostic + result.Output;
                if (!result.Success) throw new InvalidDataException("Catalog build failed. Inspect Diagnostics.");
                if (cache is not null) DiagnosticsBox.Text += $"Localized names: {cache}{Environment.NewLine}";
            }
            abilityCatalog = AbilityCatalog.Load(workspace.CatalogPath);
            foreach (var ability in abilityCatalog.Warframes.SelectMany(frame => frame.Abilities))
                ability.HelminthDefinition = helminthRegistry?.Find(ability.AssetPath);
            ApplyAbilitySearch();
            CatalogSummary.Text = $"{abilityCatalog.Counts.Warframes:N0} Warframes · {abilityCatalog.Counts.Abilities:N0} abilities\n"
                + $"{abilityCatalog.Counts.ResolvedBodyKeys:N0} exact body keys · snapshot {abilityCatalog.MetadataSnapshot}";
            FooterStatus.Text = "Ability catalog ready — metadata ownership and stock body keys resolved.";
            await EnsureAddonTargetPreviewAsync();
        }
        catch (Exception exception)
        {
            CatalogSummary.Text = "Catalog unavailable";
            ShowFailure("Ability catalog failed", exception);
        }
    }

    private void ApplyAbilitySearch()
    {
        if (abilityCatalog is null) return;
        var needle = AbilitySearchBox.Text.Trim();
        if (needle.Length == 0)
        {
            AbilityTree.ItemsSource = abilityCatalog.Warframes;
            return;
        }
        var filtered = abilityCatalog.Warframes
            .Select(frame => new WarframeCatalogEntry
            {
                Name = frame.Name,
                NameSource = frame.NameSource,
                AssetPath = frame.AssetPath,
                LocalizeTag = frame.LocalizeTag,
                Abilities = frame.Abilities.Where(ability =>
                    frame.Name.Contains(needle, StringComparison.OrdinalIgnoreCase)
                    || ability.Name.Contains(needle, StringComparison.OrdinalIgnoreCase)
                    || ability.Identifier.Contains(needle, StringComparison.OrdinalIgnoreCase)
                    || ability.ModulePath.Contains(needle, StringComparison.OrdinalIgnoreCase)).ToList(),
            })
            .Where(frame => frame.Abilities.Count != 0)
            .ToList();
        AbilityTree.ItemsSource = filtered;
    }

    private async Task PreviewCatalogAbilityAsync(AbilityCatalogEntry ability)
    {
        if (workspace is null) return;
        if (ability.ResolutionStatus != "RESOLVED")
        {
            SetSourceDocument(
                $"-- {ability.ResolutionStatus}\n-- Exact stock bytecode is not available for this entry.\n",
                ability.StockBytecodePath);
            return;
        }
        var output = Path.Combine(workspace.RenderedSourceRoot, ability.BodyKey + ".luau");
        var result = await CliBridge.RunAsync(workspace,
            ["render-source", "--toolchain", workspace.ToolchainRoot, "--bytecode", ability.StockBytecodePath, "--output", output]);
        if (!result.Success)
        {
            DiagnosticsBox.Text = result.Output;
            BottomTabs.SelectedIndex = 1;
            FooterStatus.Text = "SOURCE RENDER FAILED — inspect diagnostics.";
            return;
        }
        if (project?.Mode == EditorMode.Replacement) replacementSourcePath = output;
        SetSourceDocument(File.ReadAllText(output), output, output);
        DiscoverStockValues(ability.BodyKey, SourceEditor.Text);
        BottomTabs.SelectedIndex = 0;
        FooterStatus.Text = $"Rendered verified stock source for {ability.Name}.";
    }

    private async Task EnsureAddonTargetPreviewAsync()
    {
        if (workspace is null || abilityCatalog is null || project?.Mode != EditorMode.Addon
            || string.IsNullOrWhiteSpace(project.ModuleBodyKey)) return;
        var expected = Path.Combine(workspace.RenderedSourceRoot, project.ModuleBodyKey + ".luau");
        if (semanticVerificationLoaded
            && string.Equals(semanticBaseReadablePath, expected, StringComparison.OrdinalIgnoreCase)) return;
        var ability = abilityCatalog.Warframes
            .SelectMany(frame => frame.Abilities)
            .FirstOrDefault(candidate => candidate.ResolutionStatus == "RESOLVED"
                && string.Equals(candidate.BodyKey, project.ModuleBodyKey, StringComparison.OrdinalIgnoreCase));
        if (ability is null)
        {
            SemanticCallsiteSummary.Text =
                "No verified API callsite map is loaded because this addon's target body key is absent from the resolved catalog.";
            return;
        }
        await PreviewCatalogAbilityAsync(ability);
    }

    private void ApplyCatalogTarget(EditorMode mode)
    {
        if (workspace is null || selectedCatalogWarframe is null || selectedCatalogAbility is null)
        {
            MessageBox.Show(this, "Select an ability row first.", "Ability catalog", MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }
        if (selectedCatalogAbility.ResolutionStatus != "RESOLVED")
        {
            MessageBox.Show(this, "This target has no exact stock bytecode/body key and is not buildable yet.",
                "Unresolved target", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }
        CreateNew(mode);
        project!.Warframe = selectedCatalogWarframe.Name;
        project.Ability = selectedCatalogAbility.Name;
        project.AbilityIdentifier = selectedCatalogAbility.Identifier;
        project.AbilityLocalizeTag = selectedCatalogAbility.LocalizeTag;
        project.ModulePath = selectedCatalogAbility.ModulePath;
        project.ModuleBodyKey = selectedCatalogAbility.BodyKey;
        project.InstalledBuild = abilityCatalog?.MetadataSnapshot ?? "unknown-snapshot";
        project.ProjectId = Slug($"{selectedCatalogWarframe.Name}.{selectedCatalogAbility.Name}.{(mode == EditorMode.Addon ? "addon" : "replacement")}");
        project.EffectSummary = mode == EditorMode.Addon
            ? "Define an additive behavior through a proven hook binding."
            : "Edit the verified reconstructed native module while preserving semantics.";
        project.DescriptionText = string.Empty;
        project.ReplaceStats([]);
        if (mode == EditorMode.Addon) project.Hook = string.Empty;
        WarframeBox.Text = project.Warframe;
        AbilityBox.Text = project.Ability;
        AbilityIdBox.Text = project.AbilityIdentifier;
        ModulePathBox.Text = project.ModulePath;
        BodyKeyBox.Text = project.ModuleBodyKey;
        InstalledBuildBox.Text = project.InstalledBuild;
        ProjectIdBox.Text = project.ProjectId;
        EffectSummaryBox.Text = project.EffectSummary;
        DescriptionBox.Clear();
        HookBox.Text = project.Hook;
        statRows.Clear();
        var renderedTarget = RenderedSemanticBase(selectedCatalogAbility.BodyKey);
        if (renderedTarget is not null)
        {
            if (mode == EditorMode.Replacement) replacementSourcePath = renderedTarget;
            SetSourceDocument(File.ReadAllText(renderedTarget), renderedTarget, renderedTarget);
        }
        StateText.Text = "DRAFT";
        BuildIdentity.Text = "Unsaved catalog target";
        FooterStatus.Text = mode == EditorMode.Addon
            ? "Addon target created. Choose a proven hook and define linked stats before validation."
            : "Replacement target created from exact metadata + stock body key + verified rendered source.";
    }

    private static string Slug(string value)
    {
        var characters = value.ToLowerInvariant().Select(character =>
            char.IsLetterOrDigit(character) || character is '.' or '_' or '-' ? character : '-').ToArray();
        return string.Join("", new string(characters).Split('-', StringSplitOptions.RemoveEmptyEntries));
    }

    private void LoadProject(string path)
    {
        loading = true;
        try
        {
            ClearRebaseReview();
            project = AbilityProject.Load(path);
            ProjectIdBox.Text = project.ProjectId;
            WarframeBox.Text = project.Warframe;
            AbilityBox.Text = project.Ability;
            AbilityIdBox.Text = project.AbilityIdentifier;
            BodyKeyBox.Text = project.ModuleBodyKey;
            ModulePathBox.Text = project.ModulePath;
            InstalledBuildBox.Text = project.InstalledBuild;
            EffectSummaryBox.Text = project.EffectSummary;
            HookBox.Text = project.Hook;
            DescriptionBox.Text = project.DescriptionText;
            statRows.Clear();
            foreach (var stat in project.ReadStats()) statRows.Add(StatRow.FromDefinition(stat));
            AddonMode.IsChecked = project.Mode == EditorMode.Addon;
            ReplacementMode.IsChecked = project.Mode == EditorMode.Replacement;
            StateText.Text = project.Status;
            BuildIdentity.Text = Path.GetFileName(path);
            lastGeneration = null;
            lastBuildManifest = null;
            lastDeploymentManifest = null;
            OpenOutputButton.IsEnabled = false;
            DeployButton.IsEnabled = false;
            RollbackButton.IsEnabled = false;

            replacementSourcePath = FindProjectSource(path, project.Mode);
            if (project.Mode == EditorMode.Replacement && replacementSourcePath is not null)
            {
                var structuralBaseline = StructuralRebaseWorkspace.FindBaseline(path, project.ModuleBodyKey);
                SetSourceDocument(
                    File.ReadAllText(replacementSourcePath),
                    replacementSourcePath,
                    structuralBaseline ?? RenderedSemanticBase(project.ModuleBodyKey));
            }
            else if (project.Mode == EditorMode.Addon
                && RenderedSemanticBase(project.ModuleBodyKey) is string renderedTarget)
            {
                SetSourceDocument(File.ReadAllText(renderedTarget), renderedTarget, renderedTarget);
                DiscoverStockValues(project.ModuleBodyKey, SourceEditor.Text);
            }
            else
            {
                var sourceMessage = project.Mode == EditorMode.Addon
                    ? "Addon source will be generated from the structured project."
                    : "Open a reconstructed native .luau source file.";
                SetSourceDocument(string.Empty, sourceMessage);
            }
            DiagnosticsBox.Text = "Project loaded. Validate before building.";
            ManifestBox.Clear();
            ApplyModeVisuals();
            UpdateStatPreview();
        }
        finally
        {
            loading = false;
        }
    }

    private static string? FindProjectSource(string projectPath, EditorMode mode)
    {
        if (mode != EditorMode.Replacement) return null;
        var candidate = Path.Combine(Path.GetDirectoryName(projectPath)!, "source", "replacement.luau");
        return File.Exists(candidate) ? candidate : null;
    }

    private void PullUiIntoProject()
    {
        if (project is null) throw new InvalidOperationException("No project is loaded.");
        StatsGrid.CommitEdit(DataGridEditingUnit.Cell, true);
        StatsGrid.CommitEdit(DataGridEditingUnit.Row, true);
        project.Status = "DRAFT";
        project.ProjectId = ProjectIdBox.Text.Trim();
        project.Warframe = WarframeBox.Text.Trim();
        project.Ability = AbilityBox.Text.Trim();
        project.AbilityIdentifier = AbilityIdBox.Text.Trim();
        project.ModuleBodyKey = BodyKeyBox.Text.Trim();
        project.ModulePath = ModulePathBox.Text.Trim();
        project.InstalledBuild = InstalledBuildBox.Text.Trim();
        project.EffectSummary = EffectSummaryBox.Text.Trim();
        project.SetMode(ReplacementMode.IsChecked == true ? EditorMode.Replacement : EditorMode.Addon);
        if (project.Mode == EditorMode.Addon) project.Hook = HookBox.Text.Trim();
        project.DescriptionText = DescriptionBox.Text.Trim();
        project.ReplaceStats(statRows.Select(row => row.ToDefinition()));
    }

    private void UpdateStatPreview()
    {
        if (project is null || modifierRegistry is null)
        {
            StatPreviewText.Text = "Load a project to preview linked native rows.";
            return;
        }
        try
        {
            if (!double.TryParse(PreviewStrengthBox.Text, NumberStyles.Float, CultureInfo.InvariantCulture,
                    out var strength))
                throw new InvalidDataException("Power Strength must be a number.");
            var definitions = statRows.Select(row => row.ToDefinition()).Where(stat => stat.ShowOnCard).ToList();
            if (definitions.Count == 0)
            {
                StatPreviewText.Text = "No enabled native card rows.";
                return;
            }
            var previews = definitions.OrderBy(stat => stat.Order).Select(stat =>
                StatProjector.Project(stat, strength, PreviewBaseStatsCheck.IsChecked == true,
                    modifierRegistry, BodyKeyBox.Text.Trim(), AbilityIdBox.Text.Trim()));
            StatPreviewText.Text = string.Join(Environment.NewLine,
                previews.Select(preview => $"{preview.Label}:  {preview.DisplayValue}"));
            StatPreviewText.ToolTip = PreviewBaseStatsCheck.IsChecked == true
                ? "Base-stat mode uses each canonical base value."
                : $"Modded preview at {strength.ToString("G6", CultureInfo.InvariantCulture)}% Power Strength.";
        }
        catch (Exception exception)
        {
            StatPreviewText.Text = "Preview blocked: " + exception.Message;
            StatPreviewText.ToolTip = exception.Message;
        }
    }

    private string SaveProject(bool forceNewLocation = false)
    {
        if (workspace is null || project is null) throw new InvalidOperationException("Editor workspace is not available.");
        PullUiIntoProject();
        var current = project.FilePath;
        var examplesRoot = Path.Combine(workspace.EditorRoot, "EXAMPLES");
        var mustCreate = forceNewLocation || string.IsNullOrWhiteSpace(current)
            || Path.GetFullPath(current).StartsWith(Path.GetFullPath(examplesRoot), StringComparison.OrdinalIgnoreCase);
        var path = mustCreate
            ? Path.Combine(workspace.ProjectsRoot, project.ProjectId, "ability_edit.json")
            : current!;
        project.Save(path);
        if (project.Mode == EditorMode.Replacement && !string.IsNullOrWhiteSpace(SourceEditor.Text))
        {
            SaveReplacementSource(path);
        }
        BuildIdentity.Text = Path.GetFileName(path);
        StateText.Text = project.Status;
        RefreshProjects();
        return path;
    }

    private void SaveReplacementSource(string projectPath)
    {
        var sourceDirectory = Path.Combine(Path.GetDirectoryName(projectPath)!, "source");
        Directory.CreateDirectory(sourceDirectory);
        replacementSourcePath = Path.Combine(sourceDirectory, "replacement.luau");
        var temporary = replacementSourcePath + ".tmp";
        File.WriteAllText(temporary, SourceEditor.Text.Replace("\r\n", "\n"));
        File.Move(temporary, replacementSourcePath, true);
        if (project is not null
            && semanticVerificationLoaded
            && !string.IsNullOrWhiteSpace(semanticBaseReadablePath))
        {
            var existingBaseline = StructuralRebaseWorkspace.FindBaseline(
                projectPath, project.ModuleBodyKey);
            if (existingBaseline is null && semanticBaseWasFreshWhenLoaded)
            {
                if (semanticBaseReadableText is null
                    || !string.Equals(
                        NormalizeSourceText(File.ReadAllText(semanticBaseReadablePath)),
                        NormalizeSourceText(semanticBaseReadableText),
                        StringComparison.Ordinal))
                    throw new InvalidDataException(
                        "The verified generated base changed on disk after it was opened. Source was saved, but no rebase baseline was captured; reload the verified base first.");
                _ = StructuralRebaseWorkspace.CaptureBaseline(
                    projectPath,
                    project.ModuleBodyKey,
                    semanticBaseReadablePath);
            }
        }
        SourcePathText.Text = replacementSourcePath;
    }

    private async Task RunValidationAsync(bool build)
    {
        if (workspace is null || project is null) return;
        try
        {
            SetBusy(true, build ? "Running compiler and semantic gates…" : "Validating project bindings…");
            var projectPath = SaveProject();
            IReadOnlyList<string> arguments;
            if (project.Mode == EditorMode.Addon)
            {
                arguments = build
                    ? ["build", projectPath, "--staging", workspace.StagingRoot]
                    : ["validate", projectPath];
            }
            else
            {
                if (replacementSourcePath is null) throw new InvalidDataException("Open or write native replacement source first.");
                if (build)
                {
                    var apiBaseline = StructuralRebaseWorkspace.FindBaseline(projectPath, project.ModuleBodyKey)
                        ?? throw new InvalidDataException(
                            "No hash-bound verified stock baseline is attached to this replacement. Reload verified stock source before building.");
                    arguments = ["build-replacement", projectPath, "--source", replacementSourcePath,
                        "--staging", workspace.StagingRoot, "--baseline", apiBaseline];
                }
                else
                    arguments = ["validate-replacement", projectPath, "--source", replacementSourcePath];
            }
            var result = await CliBridge.RunAsync(workspace, arguments);
            DiagnosticsBox.Text = result.Output;
            BottomTabs.SelectedIndex = 1;
            if (!result.Success)
            {
                FooterStatus.Text = build ? "BUILD FAILED — inspect diagnostics." : "VALIDATION FAILED — inspect diagnostics.";
                StateBadge.Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(100, 42, 42));
                return;
            }

            if (build)
            {
                LoadBuildArtifacts(result.Output);
                project.Status = "BUILT";
                project.Save(projectPath);
                StateText.Text = "BUILT";
                FooterStatus.Text = "STAGED BUILD PASS — no live game file was modified.";
            }
            else
            {
                project.Status = "READY_TO_BUILD";
                project.Save(projectPath);
                StateText.Text = "READY_TO_BUILD";
                FooterStatus.Text = "VALIDATION PASS — project bindings are accepted by the C++ core.";
            }
            StateBadge.Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Color.FromRgb(48, 91, 54));
        }
        catch (Exception exception)
        {
            ShowFailure(build ? "Build failed" : "Validation failed", exception);
        }
        finally
        {
            SetBusy(false, FooterStatus.Text);
        }
    }

    private void LoadBuildArtifacts(string output)
    {
        string? generatedSource = null;
        string? manifest = null;
        foreach (var line in output.Split('\n'))
        {
            var trimmed = line.Trim();
            if (trimmed.StartsWith("Generation: ", StringComparison.Ordinal)) lastGeneration = trimmed[12..];
            if (trimmed.StartsWith("Source: ", StringComparison.Ordinal)) generatedSource = trimmed[8..];
            if (trimmed.StartsWith("Manifest: ", StringComparison.Ordinal)) manifest = trimmed[10..];
        }
        OpenOutputButton.IsEnabled = lastGeneration is not null && Directory.Exists(lastGeneration);
        lastBuildManifest = manifest;
        DeployButton.IsEnabled = manifest is not null && File.Exists(manifest);
        if (generatedSource is not null && File.Exists(generatedSource))
        {
            SetSourceDocument(
                File.ReadAllText(generatedSource),
                generatedSource,
                project?.Mode == EditorMode.Replacement ? semanticBaseReadablePath : null);
        }
        if (manifest is not null && File.Exists(manifest)) ManifestBox.Text = File.ReadAllText(manifest);
    }

    private void ApplyModeVisuals()
    {
        var replacement = ReplacementMode.IsChecked == true;
        AddonFields.Visibility = replacement ? Visibility.Collapsed : Visibility.Visible;
        BrowseSourceButton.Visibility = replacement ? Visibility.Visible : Visibility.Collapsed;
        RebaseSourceButton.Visibility = replacement ? Visibility.Visible : Visibility.Collapsed;
        ApplyRebaseButton.Visibility = replacement ? Visibility.Visible : Visibility.Collapsed;
        if (!replacement) ApplyRebaseButton.IsEnabled = false;
        SourceEditor.IsReadOnly = !replacement;
        SourcePathText.Text = replacement
            ? replacementSourcePath ?? "Open a reconstructed native .luau source file."
            : semanticBaseReadablePath is not null
                ? $"Read-only verified stock target: {semanticBaseReadablePath}"
                : "Addon source is generated deterministically after a successful build.";
        BuildButton.Content = replacement ? "Build Staged Replacement" : "Build Staged Addon";
    }

    private void SetBusy(bool busy, string status)
    {
        BuildButton.IsEnabled = !busy;
        RebaseSourceButton.IsEnabled = !busy;
        ApplyRebaseButton.IsEnabled = !busy && pendingSourceRebase?.Success == true;
        if (busy)
        {
            DeployButton.IsEnabled = false;
            RollbackButton.IsEnabled = false;
        }
        else
        {
            DeployButton.IsEnabled = lastBuildManifest is not null && File.Exists(lastBuildManifest);
            RollbackButton.IsEnabled = lastDeploymentManifest is not null && File.Exists(lastDeploymentManifest);
        }
        FooterStatus.Text = status;
        System.Windows.Input.Mouse.OverrideCursor = busy ? System.Windows.Input.Cursors.Wait : null;
    }

    private void ShowFailure(string title, Exception exception)
    {
        DiagnosticsBox.Text = $"ERROR: {exception.Message}\n\n{exception}";
        BottomTabs.SelectedIndex = 1;
        FooterStatus.Text = "ERROR — inspect diagnostics.";
        MessageBox.Show(this, exception.Message, title, MessageBoxButton.OK, MessageBoxImage.Error);
    }

    private void Mode_Checked(object sender, RoutedEventArgs e)
    {
        if (loading || project is null) return;
        try
        {
            PullUiIntoProject();
            if (project.Mode == EditorMode.Replacement && replacementSourcePath is null)
            {
                SetSourceDocument(string.Empty, "Open a reconstructed native .luau source file.");
            }
            ApplyModeVisuals();
            StateText.Text = "DRAFT";
            project.Status = "DRAFT";
        }
        catch (Exception exception)
        {
            ShowFailure("Mode change failed", exception);
        }
    }

    private async void ProjectList_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (ProjectList.SelectedItem is not ProjectEntry entry) return;
        try
        {
            LoadProject(entry.Path);
            await EnsureAddonTargetPreviewAsync();
        }
        catch (Exception exception)
        {
            ShowFailure("Project load failed", exception);
        }
    }

    private void Search_TextChanged(object sender, TextChangedEventArgs e) => ApplySearch();

    private void AbilitySearch_TextChanged(object sender, TextChangedEventArgs e) => ApplyAbilitySearch();

    private void SourceEditor_TextChanged(object sender, TextChangedEventArgs e)
    {
        if (settingSourceEditorText || !IsInitialized) return;
        if (pendingSourceRebase is not null)
        {
            pendingSourceRebase = null;
            ApplyRebaseButton.IsEnabled = false;
            RebaseSummaryText.Text =
                "STALE PREVIEW — the editable source changed after this comparison. Run Preview Structural Rebase again.";
            RebaseSummaryText.Foreground = new SolidColorBrush(Color.FromRgb(226, 176, 91));
        }
        UpdateSemanticFreshness();
    }

    private void SemanticFilter_TextChanged(object sender, TextChangedEventArgs e) => semanticNameView?.Refresh();

    private void SemanticPrototype_SelectionChanged(object sender, SelectionChangedEventArgs e) => semanticNameView?.Refresh();

    private void JumpReadable_Click(object sender, RoutedEventArgs e) => JumpToSemanticIdentity(fidelity: false);

    private void JumpFidelity_Click(object sender, RoutedEventArgs e) => JumpToSemanticIdentity(fidelity: true);

    private void JumpApiCallsiteReadable_Click(object sender, RoutedEventArgs e) => JumpToApiCallsite(fidelity: false);

    private void JumpApiCallsiteFidelity_Click(object sender, RoutedEventArgs e) => JumpToApiCallsite(fidelity: true);

    private void ShowClosureParent_Click(object sender, RoutedEventArgs e) => ShowClosurePrototype(target: false);

    private void ShowClosureTarget_Click(object sender, RoutedEventArgs e) => ShowClosurePrototype(target: true);

    private void JumpClosureTarget_Click(object sender, RoutedEventArgs e) => JumpToClosureTarget();

    private async void RefreshCatalog_Click(object sender, RoutedEventArgs e) =>
        await RefreshAbilityCatalogAsync(forceRebuild: true);

    private async void AbilityTree_SelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
    {
        if (e.NewValue is not AbilityCatalogEntry ability || abilityCatalog is null) return;
        selectedCatalogAbility = ability;
        selectedCatalogWarframe = ability.Owner;
        if (selectedCatalogWarframe is null) return;

        WarframeBox.Text = selectedCatalogWarframe.Name;
        AbilityBox.Text = ability.Name;
        AbilityIdBox.Text = ability.Identifier;
        BodyKeyBox.Text = ability.BodyKey;
        ModulePathBox.Text = ability.ModulePath;
        InstalledBuildBox.Text = abilityCatalog.MetadataSnapshot;
        HelminthStatusText.Text = ability.HelminthDefinition is null
            ? "Helminth: not listed as subsumable in the pinned Wiki registry"
            : $"Helminth: SUBSUMABLE — {ability.HelminthDefinition.AbilityName} ({ability.HelminthDefinition.Provenance}, {ability.HelminthDefinition.RetrievedAt})";
        BuildIdentity.Text = $"Catalog preview · {ability.ResolutionStatus}";
        try
        {
            await PreviewCatalogAbilityAsync(ability);
        }
        catch (Exception exception)
        {
            ShowFailure("Source preview failed", exception);
        }
    }

    private void UseCatalogAddon_Click(object sender, RoutedEventArgs e) => ApplyCatalogTarget(EditorMode.Addon);

    private void UseCatalogReplacement_Click(object sender, RoutedEventArgs e) => ApplyCatalogTarget(EditorMode.Replacement);

    private void NewAddon_Click(object sender, RoutedEventArgs e) => CreateNew(EditorMode.Addon);
    private void NewReplacement_Click(object sender, RoutedEventArgs e) => CreateNew(EditorMode.Replacement);

    private void CreateNew(EditorMode mode)
    {
        if (workspace is null) return;
        loading = true;
        try
        {
            project = AbilityProject.CreateFromTemplate(
                Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), mode);
            var temporary = Path.Combine(workspace.ProjectsRoot, ".draft", mode == EditorMode.Addon ? "addon.json" : "replacement.json");
            Directory.CreateDirectory(Path.GetDirectoryName(temporary)!);
            project.Save(temporary);
            LoadProject(temporary);
            File.Delete(temporary);
            var draftDirectory = Path.GetDirectoryName(temporary)!;
            if (!Directory.EnumerateFileSystemEntries(draftDirectory).Any()) Directory.Delete(draftDirectory);
            project = AbilityProject.CreateFromTemplate(
                Path.Combine(workspace.EditorRoot, "EXAMPLES", "mallet_linked_overguard_addon.json"), mode);
            ProjectIdBox.Text = project.ProjectId;
            StateText.Text = "DRAFT";
            BuildIdentity.Text = "Unsaved project";
            replacementSourcePath = null;
            if (mode == EditorMode.Replacement)
                SetSourceDocument(
                    "-- Paste or open reconstructed native DE Luau source here.\n",
                    "Unsaved replacement source");
        }
        catch (Exception exception)
        {
            ShowFailure("New project failed", exception);
        }
        finally
        {
            loading = false;
            ApplyModeVisuals();
        }
    }

    private void OpenProject_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog { Filter = "Ability edit project|*.json|All files|*.*" };
        if (dialog.ShowDialog(this) != true) return;
        try
        {
            LoadProject(dialog.FileName);
        }
        catch (Exception exception)
        {
            ShowFailure("Project load failed", exception);
        }
    }

    private void Save_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            var path = SaveProject();
            FooterStatus.Text = $"Saved {path}";
        }
        catch (Exception exception)
        {
            ShowFailure("Save failed", exception);
        }
    }

    private async void Validate_Click(object sender, RoutedEventArgs e) => await RunValidationAsync(false);
    private async void Build_Click(object sender, RoutedEventArgs e) => await RunValidationAsync(true);

    private void BrowseSource_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog { Filter = "Luau source|*.luau;*.lua|All files|*.*" };
        if (dialog.ShowDialog(this) != true) return;
        try
        {
            replacementSourcePath = dialog.FileName;
            SetSourceDocument(File.ReadAllText(dialog.FileName), dialog.FileName, dialog.FileName);
        }
        catch (Exception exception)
        {
            ShowFailure("Source load failed", exception);
        }
    }

    private void SaveSource_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            if (project?.Mode != EditorMode.Replacement)
            {
                MessageBox.Show(this, "Addon source is generated from linked stats and cannot be hand-edited here.", "Generated source", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }
            SaveProject();
            FooterStatus.Text = $"Saved native source to {replacementSourcePath}";
        }
        catch (Exception exception)
        {
            ShowFailure("Source save failed", exception);
        }
    }

    private void ClearRebaseReview()
    {
        pendingSourceRebase = null;
        pendingRebaseBaselinePath = null;
        pendingRebaseGeneratedPath = null;
        if (!IsInitialized) return;
        ApplyRebaseButton.IsEnabled = false;
        RebaseSummaryText.Text = "No structural rebase preview is loaded.";
        RebaseSummaryText.Foreground = new SolidColorBrush(Color.FromRgb(158, 160, 169));
        RebaseBaseEditor.Clear();
        RebaseGeneratedEditor.Clear();
        RebaseUserEditor.Clear();
        RebasePreviewEditor.Clear();
        RebaseHunksGrid.ItemsSource = null;
    }

    private async void RebaseSource_Click(object sender, RoutedEventArgs e)
    {
        if (workspace is null || project?.Mode != EditorMode.Replacement) return;
        try
        {
            ClearRebaseReview();
            SetBusy(true, "Rendering a fresh verified base and checking structural edit anchors…");
            var projectPath = SaveProject();
            var baselinePath = StructuralRebaseWorkspace.FindBaseline(projectPath, project.ModuleBodyKey)
                ?? throw new InvalidDataException(
                    "No hash-bound generated baseline is captured for this replacement. Load verified stock source and save once before rebasing.");
            if (abilityCatalog is null) await RefreshAbilityCatalogAsync(forceRebuild: false);
            var ability = abilityCatalog?.Warframes.SelectMany(frame => frame.Abilities)
                .SingleOrDefault(candidate => candidate.ResolutionStatus == "RESOLVED"
                    && string.Equals(candidate.BodyKey, project.ModuleBodyKey, StringComparison.OrdinalIgnoreCase))
                ?? throw new InvalidDataException(
                    $"The catalog has no single resolved stock module for body key {project.ModuleBodyKey}.");
            var generatedPath = StructuralRebaseWorkspace.CandidatePath(projectPath, project.ModuleBodyKey);
            Directory.CreateDirectory(Path.GetDirectoryName(generatedPath)!);
            var render = await CliBridge.RunAsync(workspace,
                ["render-source", "--toolchain", workspace.ToolchainRoot,
                    "--bytecode", ability.StockBytecodePath, "--output", generatedPath]);
            DiagnosticsBox.Text = render.Output;
            if (!render.Success)
                throw new InvalidDataException("Fresh source rendering failed. Inspect Diagnostics; no rebase output was produced.");

            var baseline = VerifiedSemanticSource.Load(baselinePath);
            var generated = VerifiedSemanticSource.Load(generatedPath);
            var userSource = NormalizeSourceText(SourceEditor.Text);
            var result = StructuralSourceRebaser.Rebase(baseline, userSource, generated);
            var reportPath = StructuralRebaseWorkspace.ReportPath(projectPath);
            var previewPath = StructuralRebaseWorkspace.PreviewPath(projectPath);
            result.WriteReport(reportPath);
            if (result.Success)
                StructuralRebaseWorkspace.AtomicWrite(previewPath, result.MergedSource!);
            else if (File.Exists(previewPath))
                File.Delete(previewPath);

            pendingSourceRebase = result;
            pendingRebaseBaselinePath = baselinePath;
            pendingRebaseGeneratedPath = generatedPath;
            RebaseBaseEditor.Text = baseline.Source;
            RebaseGeneratedEditor.Text = generated.Source;
            RebaseUserEditor.Text = userSource;
            RebasePreviewEditor.Text = result.MergedSource
                ?? "-- REBASE BLOCKED\n-- No merged source was emitted. Inspect the conflict rows and JSON report.\n";
            RebaseHunksGrid.ItemsSource = result.Hunks;
            RebaseSummaryText.Text = result.Success
                ? $"SAFE TO APPLY — user hunks={result.Hunks.Count}, generator hunks={result.GeneratorChangeCount}, conflicts=0. "
                    + $"Every edit has a surviving hash-bound prototype boundary. Report: {reportPath}"
                : $"CONFLICT — user hunks={result.Hunks.Count}, generator hunks={result.GeneratorChangeCount}, "
                    + $"conflicts={result.Conflicts.Count}. No merged source exists. Report: {reportPath}";
            RebaseSummaryText.Foreground = new SolidColorBrush(result.Success
                ? Color.FromRgb(139, 197, 130)
                : Color.FromRgb(229, 95, 95));
            ApplyRebaseButton.IsEnabled = result.Success;
            SourceWorkspaceTabs.SelectedItem = RebaseReviewTab;
            BottomTabs.SelectedIndex = 0;
            FooterStatus.Text = result.Success
                ? "STRUCTURAL REBASE PASS — review all three inputs and the merged preview before applying."
                : "STRUCTURAL REBASE BLOCKED — resolve the listed conflicts; user source was not changed.";
        }
        catch (Exception exception)
        {
            ShowFailure("Structural rebase failed", exception);
        }
        finally
        {
            SetBusy(false, FooterStatus.Text);
        }
    }

    private void ApplyRebase_Click(object sender, RoutedEventArgs e)
    {
        if (project?.Mode != EditorMode.Replacement
            || string.IsNullOrWhiteSpace(project.FilePath)
            || pendingSourceRebase?.Success != true
            || pendingRebaseBaselinePath is null
            || pendingRebaseGeneratedPath is null)
        {
            FooterStatus.Text = "Run a zero-conflict structural rebase preview before applying.";
            return;
        }
        try
        {
            var baseline = VerifiedSemanticSource.Load(pendingRebaseBaselinePath);
            var generated = VerifiedSemanticSource.Load(pendingRebaseGeneratedPath);
            var verifiedAgain = StructuralSourceRebaser.Rebase(baseline, SourceEditor.Text, generated);
            if (!verifiedAgain.Success
                || verifiedAgain.BaselineSha256 != pendingSourceRebase.BaselineSha256
                || verifiedAgain.UserSha256 != pendingSourceRebase.UserSha256
                || verifiedAgain.GeneratedSha256 != pendingSourceRebase.GeneratedSha256
                || verifiedAgain.MergedSource != pendingSourceRebase.MergedSource)
                throw new InvalidDataException(
                    "The baseline, editable source, generated source, or merge result changed after preview. Run the preview again.");

            settingSourceEditorText = true;
            try { SourceEditor.Text = verifiedAgain.MergedSource!; }
            finally { settingSourceEditorText = false; }
            SaveReplacementSource(project.FilePath);
            var promotedBaseline = StructuralRebaseWorkspace.CaptureBaseline(
                project.FilePath,
                project.ModuleBodyKey,
                generated.ReadablePath,
                promote: true);
            SetSourceDocument(SourceEditor.Text, replacementSourcePath, promotedBaseline);
            pendingSourceRebase = null;
            ApplyRebaseButton.IsEnabled = false;
            RebaseSummaryText.Text =
                $"APPLIED — replacement source was updated atomically and the fresh verified base is now bound at {promotedBaseline}.";
            RebaseSummaryText.Foreground = new SolidColorBrush(Color.FromRgb(139, 197, 130));
            project.Status = "DRAFT";
            project.Save(project.FilePath);
            StateText.Text = "DRAFT";
            FooterStatus.Text = "STRUCTURAL REBASE APPLIED — validate and build the replacement before deployment.";
        }
        catch (Exception exception)
        {
            ShowFailure("Apply structural rebase failed", exception);
        }
    }

    private void AddStat_Click(object sender, RoutedEventArgs e)
    {
        var suffix = statRows.Count + 1;
        statRows.Add(new StatRow { Id = $"new_stat_{suffix}", Label = $"New Stat {suffix}", Order = 100 + suffix });
        StatsGrid.SelectedItem = statRows[^1];
        StatsGrid.ScrollIntoView(statRows[^1]);
    }

    private void RemoveStat_Click(object sender, RoutedEventArgs e)
    {
        if (StatsGrid.SelectedItem is StatRow selected) statRows.Remove(selected);
    }

    private void StatsGrid_CellEditEnding(object sender, DataGridCellEditEndingEventArgs e) =>
        Dispatcher.BeginInvoke(UpdateStatPreview, System.Windows.Threading.DispatcherPriority.Background);

    private void StatsGrid_CurrentCellChanged(object? sender, EventArgs e) =>
        Dispatcher.BeginInvoke(UpdateStatPreview, System.Windows.Threading.DispatcherPriority.Background);

    private void PreviewStrength_TextChanged(object sender, TextChangedEventArgs e)
    {
        if (IsInitialized) UpdateStatPreview();
    }

    private void PreviewMode_Changed(object sender, RoutedEventArgs e)
    {
        if (IsInitialized) UpdateStatPreview();
    }

    private int cardDiscoveryGeneration;
    private string? cardDiscoverySource;
    private string? cardDiscoveryBody;
    private async void DiscoverStockValues(string moduleBodyKey, string source)
    {
        var generation = ++cardDiscoveryGeneration;
        cardDiscoverySource = null;
        cardDiscoveryBody = null;
        stockNumericRows.Clear();
        if (workspace is null || string.IsNullOrWhiteSpace(moduleBodyKey) || string.IsNullOrWhiteSpace(source)) return;
        StockValuesSummary.Text = "Reading native card labels and base-value links…";
        try
        {
            var entries = await CardStatDiscovery.DiscoverLinkedAsync(workspace, moduleBodyKey, source);
            if (generation != cardDiscoveryGeneration || SourceEditor.Text != source) return;
            foreach (var entry in entries)
            {
                stockNumericRows.Add(new StockNumericRow
                {
                    Control = entry,
                    Value = entry.Inputs.Count > 0 ? entry.InitialValue.ToString("0.################", CultureInfo.InvariantCulture) : "—",
                });
            }
            cardDiscoverySource = source;
            cardDiscoveryBody = moduleBodyKey;
            var editable = stockNumericRows.Count(row => row.Editable);
            StockValuesSummary.Text = $"{editable} verified card + gameplay controls; {stockNumericRows.Count - editable} read-only labels. Exact catalog source only; this does not migrate the ability catalog to a newer game build.";
        }
        catch (Exception exception)
        {
            if (generation != cardDiscoveryGeneration) return;
            StockValuesSummary.Text = "Card stat discovery failed: " + exception.Message;
        }
    }

    private void DiscoverStockValues_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            DiscoverStockValues(BodyKeyBox.Text.Trim(), SourceEditor.Text);
            FooterStatus.Text = "Native card stat discovery requested.";
        }
        catch (Exception exception)
        {
            ShowFailure("Stock value discovery failed", exception);
        }
    }

    private void CreateStockReplacement_Click(object sender, RoutedEventArgs e)
    {
        if (selectedCatalogAbility is null || selectedCatalogWarframe is null)
        {
            MessageBox.Show(this, "Select an exact catalog ability first.", "Stock values", MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }
        try
        {
            if (cardDiscoverySource != SourceEditor.Text || cardDiscoveryBody != selectedCatalogAbility.BodyKey)
                throw new InvalidDataException("Select and discover values for this exact ability source again before creating a replacement.");
            var edits = stockNumericRows.Where(row => row.Editable).SelectMany(row => row.ToValues()).ToList();
            if (!edits.Any(value => value.Value != value.OriginalValue))
                throw new InvalidDataException("No stock numeric value has been changed.");
            var patched = StockNumericEditor.Apply(SourceEditor.Text, edits);
            ApplyCatalogTarget(EditorMode.Replacement);
            SourceEditor.Text = patched;
            replacementSourcePath = null;
            project!.EffectSummary = "Linked card and gameplay rank inputs edited together from exact verified source bindings.";
            EffectSummaryBox.Text = project.EffectSummary;
            var path = SaveProject(forceNewLocation: true);
            DiscoverStockValues(project.ModuleBodyKey, SourceEditor.Text);
            FooterStatus.Text = $"Stock-value replacement created at {path}. Run Validate and Build before deployment.";
        }
        catch (Exception exception)
        {
            ShowFailure("Stock replacement failed", exception);
        }
    }

    private void MissionSection_SelectionChanged(object sender, SelectionChangedEventArgs e) => RefreshMissionSection();

    private void RefreshMissionSection()
    {
        if (MissionPresetBox is null || MissionSectionBox.SelectedItem is not string section) return;
        MissionPresetBox.ItemsSource = missionPresets.Where(p => p.Section == section).ToList();
        MissionPresetBox.SelectedIndex = 0;
    }

    private void MissionPreset_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        missionTimerRows.Clear();
        if (MissionPresetBox.SelectedItem is not MissionTimerPreset preset) return;
        foreach (var value in preset.Values)
        {
            var resetValue = (value.StockValue ?? value.Value).ToString("0.################", CultureInfo.InvariantCulture);
            missionTimerRows.Add(new MissionTimerRow
            {
                Id = value.Id,
                Group = value.Group,
                Label = value.Label,
                StockValue = resetValue,
                Value = value.Value.ToString("0.################", CultureInfo.InvariantCulture),
                RecommendedValue = value.RecommendedValue.ToString("0.################", CultureInfo.InvariantCulture),
                Unit = value.Unit,
                Explanation = value.Explanation,
                StockCaption = value.StockValue is double stock
                    ? $"Stock: {stock.ToString("0.################", CultureInfo.InvariantCulture)} {value.Unit}"
                    : $"Stock: {value.StockDescription ?? "mission-configured value"}",
            });
        }
        ResetMissionValuesButton.Content = preset.Values.All(value => value.StockValue.HasValue)
            ? "Reset to Stock"
            : "Reset Initial Values";
        var view = CollectionViewSource.GetDefaultView(missionTimerRows);
        view.GroupDescriptions.Clear();
        if (preset.Values.Any(v => !string.IsNullOrEmpty(v.Group)))
            view.GroupDescriptions.Add(new PropertyGroupDescription(nameof(MissionTimerRow.Group)));
        MissionTimerSummary.Text = preset.DisplayName + " · " + preset.Summary;
        MissionMechanicText.Text = preset.Mechanic;
        MissionBindingText.Text = $"{preset.ModulePath}  ·  exact body {preset.ModuleBodyKey}  ·  {preset.CorpusFile}";
    }

    private void UseRecommendedMissionValues_Click(object sender, RoutedEventArgs e)
    {
        foreach (var row in missionTimerRows) row.Value = row.RecommendedValue;
        FooterStatus.Text = "Loaded the visible faster examples. Review every value before creating the mission edit.";
    }

    private void ResetMissionValues_Click(object sender, RoutedEventArgs e)
    {
        foreach (var row in missionTimerRows) row.Value = row.StockValue;
        FooterStatus.Text = MissionPresetBox.SelectedItem is MissionTimerPreset preset
                            && preset.Values.Any(value => !value.StockValue.HasValue)
            ? "Mission controls reset to their initial editor values; this preset's stock duration is mission-resource configured."
            : "Mission controls reset to decoded stock values.";
    }

    private async void CreateMissionTimerPatch_Click(object sender, RoutedEventArgs e)
    {
        if (workspace is null || MissionPresetBox.SelectedItem is not MissionTimerPreset preset) return;
        try
        {
            var values = new Dictionary<string, double>(StringComparer.Ordinal);
            foreach (var row in missionTimerRows)
            {
                if (!double.TryParse(row.Value, NumberStyles.Float, CultureInfo.InvariantCulture, out var value))
                    throw new InvalidDataException($"{row.Label}: value must be a number.");
                values.Add(row.Id, value);
            }

            // Artifact lane comes from the verified mission registry (REGISTRIES/mission_build_u44.json).
            var metadataPatch = preset.Lane == "METADATA_PATCH";
            var exactReplacement = preset.Lane == "EXACT_LITERAL";
            if (!metadataPatch && !exactReplacement && preset.Lane != "TARGET_ADDON")
                throw new InvalidDataException($"Mission preset {preset.Id} has no verified artifact lane in the current registry.");
            var exportName = metadataPatch ? preset.Id + ".txt" : exactReplacement
                ? VerifiedArtifactExporter.MissionReplacementFileName(preset.ModuleBodyKey, preset.Id)
                : VerifiedArtifactExporter.MissionTargetAddonFileName(preset.ModuleBodyKey, preset.Id);
            var suggestedCustomScripts = Path.GetFullPath(Path.Combine(
                workspace.WorkspaceRoot, "..", "Warframe 23.09.2026", "OpenWF", "CustomScripts"));
            var suggestedInject = Path.Combine(suggestedCustomScripts, "Inject");
            var suggestedMetadata = Path.Combine(Path.GetDirectoryName(suggestedCustomScripts)!, "Metadata Patches");
            var saveDialog = new SaveFileDialog
            {
                Title = metadataPatch ? $"Save {preset.DisplayName} metadata patch" : exactReplacement
                    ? $"Save verified {preset.DisplayName} exact timer replacement"
                    : $"Save verified {preset.DisplayName} timer addon",
                Filter = metadataPatch ? "Metadata patch|*.txt" : "DE Lua bytecode|*.lua_B",
                DefaultExt = metadataPatch ? ".txt" : ".lua_B",
                AddExtension = true,
                OverwritePrompt = true,
                FileName = exportName,
                InitialDirectory = metadataPatch && Directory.Exists(suggestedMetadata) ? suggestedMetadata : exactReplacement && Directory.Exists(suggestedCustomScripts)
                    ? suggestedCustomScripts
                    : Directory.Exists(suggestedInject)
                    ? suggestedInject
                    : Directory.Exists(suggestedCustomScripts)
                    ? suggestedCustomScripts
                    : workspace.WorkspaceRoot,
            };
            if (saveDialog.ShowDialog(this) != true) return;

            var bytecode = Path.Combine(MissionBuildProfile.CorpusRoot(workspace), preset.CorpusFile);
            if (!File.Exists(bytecode)) throw new FileNotFoundException("Exact stock mission bytecode is missing.", bytecode);

            SetBusy(true, metadataPatch ? $"Building {preset.DisplayName} metadata patch…" : exactReplacement
                ? $"Building exact {preset.DisplayName} timer replacement…"
                : $"Building exact {preset.DisplayName} timer target addon…");
            CreateNew(exactReplacement ? EditorMode.Replacement : EditorMode.Addon);
            project!.Warframe = "Mission";
            project.Ability = preset.DisplayName + " Timers";
            project.AbilityIdentifier = preset.AbilityIdentifier;
            project.ClearAbilityLocalizeTag();
            project.ModulePath = preset.ModulePath;
            project.ModuleBodyKey = preset.ModuleBodyKey;
            project.InstalledBuild = abilityCatalog?.MetadataSnapshot ?? "exact-corpus-build";
            project.ProjectId = metadataPatch ? $"mission.{preset.Id}.metadata" : exactReplacement
                ? $"mission.{preset.Id}.timers.exact-replacement"
                : $"mission.{preset.Id}.timers.addon";
            project.ModeSelection = "AUTOMATIC_RECOMMENDATION";
            project.ModeReason = metadataPatch ? "Native metadata parameter controls gameplay and its native progress display." : exactReplacement
                ? "Exact stock-body replacement changes only the verified duration operands."
                : "Exact target addon changes the verified stock timer owner while retaining the native mission module and lifecycle.";
            project.EffectSummary = string.Join("; ", missionTimerRows.Select(row => $"{row.Label}={row.Value} {row.Unit}"));
            project.DescriptionText = metadataPatch ? $"Verified native {preset.DisplayName} metadata parameter edit." : exactReplacement
                ? $"Exact body-keyed {preset.DisplayName} replacement for the verified stock timing assignments."
                : $"Exact body-keyed {preset.DisplayName} addon for the verified stock timing owner.";
            project.ReplaceStats([]);
            switch (preset.Id)
            {
                case "survival":
                    project.ConfigureSurvivalTimerLuaCallAddon(
                        values["reward_interval"],
                        values["pickup_life_support"],
                        values["pickup_reward_progress"]);
                    break;
                case "mobile_defense":
                    project.ConfigureMobileDefenseTimerReplacement(
                        values["minimum_total_time"],
                        values["maximum_total_time"]);
                    break;
                case "interception":
                    project.ConfigureInterceptionTimerAddon(values["scoring_speed_multiplier"]);
                    break;
                case "excavation":
                    project.ConfigureExcavationTimerReplacement(
                        values["standard_dig_time"],
                        values["old_world_salvage_dig_time"],
                        values["elite_alert_dig_time"]);
                    break;
                case "control_area_plains":
                    project.ConfigureControlAreaPlainsTimerReplacement(values["control_area_duration"]);
                    break;
                case "control_area_deimos":
                    project.ConfigureControlAreaDeimosTimerReplacement(values["control_area_duration"]);
                    break;
                case "control_area_nokko":
                    project.ConfigureControlAreaNokkoTimerReplacement(values["control_area_duration"]);
                    break;
                case "void_cascade":
                case "archimedea":
                case "descendia_excavation":
                case "descendia_shrine":
                case "netracells":
                    break;
                default:
                    throw new InvalidDataException($"No verified mission edit binding exists for mission preset {preset.Id}.");
            }

            project.ConfigureMissionBuildProfile(preset.Id, values, workspace.EditorRoot);

            ProjectIdBox.Text = project.ProjectId;
            WarframeBox.Text = project.Warframe;
            AbilityBox.Text = project.Ability;
            AbilityIdBox.Text = project.AbilityIdentifier;
            ModulePathBox.Text = project.ModulePath;
            BodyKeyBox.Text = project.ModuleBodyKey;
            InstalledBuildBox.Text = project.InstalledBuild;
            EffectSummaryBox.Text = project.EffectSummary;
            DescriptionBox.Text = project.DescriptionText;
            HookBox.Text = project.Hook;
            statRows.Clear();

            var projectPath = SaveProject(forceNewLocation: true);
            var build = await CliBridge.RunAsync(workspace,
                ["build", projectPath, "--staging", workspace.StagingRoot]);
            DiagnosticsBox.Text = $"PASS exact {preset.DisplayName} body key and timer owner selected"
                + Environment.NewLine + "Stock bytecode: " + bytecode
                + Environment.NewLine + "Project: " + projectPath
                + Environment.NewLine + build.Output;
            BottomTabs.SelectedIndex = 1;
            if (!build.Success)
                throw new InvalidDataException($"{preset.DisplayName} {(exactReplacement ? "exact replacement" : "target-addon")} build failed. Inspect Diagnostics; no artifact was exported.");
            LoadBuildArtifacts(build.Output);
            if (string.IsNullOrWhiteSpace(lastBuildManifest))
                throw new InvalidDataException("The successful build did not report a build manifest.");
            var exported = VerifiedArtifactExporter.Export(
                lastBuildManifest,
                saveDialog.FileName,
                Path.Combine(workspace.WorkspaceRoot, "work", "export-rollbacks", "ability-editor"));
            project.Status = "EXPORTED";
            project.Save(projectPath);
            StateText.Text = "EXPORTED";
            DiagnosticsBox.Text += Environment.NewLine
                + $"EXPORT PASS bytes={exported.ArtifactSize} sha256={exported.ArtifactSha256}"
                + Environment.NewLine + "Export: " + exported.DestinationPath;
            if (exported.RollbackPath is not null)
                DiagnosticsBox.Text += Environment.NewLine
                    + $"Previous destination preserved: {exported.RollbackPath} sha256={exported.RollbackSha256}";
            BuildIdentity.Text = projectPath;
            FooterStatus.Text = metadataPatch ? $"EXPORT PASS — metadata patch saved to {exported.DestinationPath}" : exactReplacement
                ? $"EXPORT PASS — verified {preset.DisplayName} exact replacement saved to {exported.DestinationPath}"
                : $"EXPORT PASS — verified {preset.DisplayName} target addon saved to {exported.DestinationPath}";
        }
        catch (Exception exception)
        {
            ShowFailure("Mission timer patch failed", exception);
        }
        finally
        {
            SetBusy(false, FooterStatus.Text);
        }
    }

    private void OpenOutput_Click(object sender, RoutedEventArgs e)
    {
        if (lastGeneration is null || !Directory.Exists(lastGeneration)) return;
        Process.Start(new ProcessStartInfo("explorer.exe", lastGeneration) { UseShellExecute = true });
    }

    private async void Deploy_Click(object sender, RoutedEventArgs e)
    {
        if (workspace is null || lastBuildManifest is null) return;
        var dialog = new OpenFolderDialog
        {
            Title = "Select the Warframe game root containing OpenWF",
            Multiselect = false,
        };
        if (dialog.ShowDialog(this) != true) return;
        var answer = MessageBox.Show(
            this,
            $"Deploy the verified staged package to:\n\n{dialog.FolderName}\n\n"
            + "The previous target will be snapshotted and hash-verified for rollback. Continue?",
            "Confirm transactional deployment",
            MessageBoxButton.YesNo,
            MessageBoxImage.Warning);
        if (answer != MessageBoxResult.Yes) return;

        try
        {
            SetBusy(true, "Creating rollback snapshot and deploying verified artifact…");
            var result = await CliBridge.RunAsync(workspace, ["deploy", lastBuildManifest, "--game-root", dialog.FolderName]);
            DiagnosticsBox.Text = result.Output;
            BottomTabs.SelectedIndex = 1;
            if (!result.Success)
            {
                FooterStatus.Text = "DEPLOYMENT FAILED — live state was not accepted; inspect diagnostics.";
                return;
            }
            foreach (var line in result.Output.Split('\n'))
            {
                var trimmed = line.Trim();
                if (trimmed.StartsWith("Deployment manifest: ", StringComparison.Ordinal))
                    lastDeploymentManifest = trimmed[21..];
            }
            project!.Status = "DEPLOYED";
            if (project.FilePath is not null) project.Save(project.FilePath);
            StateText.Text = "DEPLOYED";
            FooterStatus.Text = "DEPLOYMENT PASS — press F9 or restart as required, then perform the in-game acceptance check.";
        }
        catch (Exception exception)
        {
            ShowFailure("Deployment failed", exception);
        }
        finally
        {
            SetBusy(false, FooterStatus.Text);
        }
    }

    private async void Rollback_Click(object sender, RoutedEventArgs e)
    {
        if (workspace is null || lastDeploymentManifest is null) return;
        var answer = MessageBox.Show(
            this,
            "Restore the exact file that existed before the last deployment?\n\n"
            + "Rollback will stop if the deployed target has changed externally.",
            "Confirm rollback",
            MessageBoxButton.YesNo,
            MessageBoxImage.Warning);
        if (answer != MessageBoxResult.Yes) return;
        try
        {
            SetBusy(true, "Verifying and restoring rollback snapshot…");
            var result = await CliBridge.RunAsync(workspace, ["rollback", lastDeploymentManifest]);
            DiagnosticsBox.Text = result.Output;
            BottomTabs.SelectedIndex = 1;
            if (!result.Success)
            {
                FooterStatus.Text = "ROLLBACK STOPPED — inspect diagnostics; external changes were preserved.";
                return;
            }
            project!.Status = "BUILT";
            if (project.FilePath is not null) project.Save(project.FilePath);
            StateText.Text = "BUILT";
            FooterStatus.Text = "ROLLBACK PASS — exact previous target state restored.";
            lastDeploymentManifest = null;
        }
        catch (Exception exception)
        {
            ShowFailure("Rollback failed", exception);
        }
        finally
        {
            SetBusy(false, FooterStatus.Text);
        }
    }
}
