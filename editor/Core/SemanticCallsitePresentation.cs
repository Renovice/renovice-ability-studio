using System.Globalization;
using System.Text;

namespace Renovice.AbilityEditor.Core;

public enum SemanticCallsiteMarkerKind
{
    Information,
    EvidenceWarning,
    ObservedMismatch,
}

public sealed record SemanticCallsitePresentation(
    SemanticCallsiteMarkerKind MarkerKind,
    string? WarningCode,
    string Tooltip)
{
    public bool IsWarning => MarkerKind is not SemanticCallsiteMarkerKind.Information;
}

public static class SemanticCallsitePresenter
{
    public static SemanticCallsitePresentation Build(SemanticCallsiteEntry callsite)
    {
        ArgumentNullException.ThrowIfNull(callsite);

        var warningCode = WarningCode(callsite);
        var markerKind = callsite.Contract.Match == "OBSERVED_MISMATCH"
            ? SemanticCallsiteMarkerKind.ObservedMismatch
            : warningCode is null
                ? SemanticCallsiteMarkerKind.Information
                : SemanticCallsiteMarkerKind.EvidenceWarning;

        return new SemanticCallsitePresentation(markerKind, warningCode, BuildTooltip(callsite, warningCode));
    }

    private static string? WarningCode(SemanticCallsiteEntry callsite)
    {
        if (callsite.Contract.Match == "OBSERVED_MISMATCH") return "OBSERVED CONTRACT MISMATCH";
        if (callsite.Contract.Match == "AMBIGUOUS") return "AMBIGUOUS CONTRACT";
        if (callsite.Contract.Status == "UNRESOLVED") return "UNRESOLVED CONTRACT";
        if (callsite.DescriptorJoin == "RECEIVER_TYPE_CONFLICT") return "RECEIVER TYPE CONFLICT";
        return null;
    }

    private static string BuildTooltip(SemanticCallsiteEntry callsite, string? warningCode)
    {
        var text = new StringBuilder();
        text.AppendLine(warningCode is null
            ? "VERIFIED API CALLSITE EVIDENCE"
            : $"WARNING — {warningCode}");
        text.Append("Call: ").AppendLine(callsite.DisplayCall);
        text.Append("Exact identity: prototype ")
            .Append(callsite.Prototype.ToString(CultureInfo.InvariantCulture))
            .Append(", block ")
            .Append(callsite.Block.ToString(CultureInfo.InvariantCulture))
            .Append(", instruction ")
            .Append(callsite.Instruction.ToString(CultureInfo.InvariantCulture))
            .Append(", source occurrence ")
            .AppendLine(callsite.SourceOccurrence.ToString(CultureInfo.InvariantCulture));
        text.Append("Contract: ").Append(callsite.ContractStatus)
            .Append("; arity ").AppendLine(callsite.Contract.Match);
        text.Append("Descriptor: ").AppendLine(callsite.Contract.Descriptor ?? "none — no unique SDK contract is registered");
        text.Append("Descriptor join: ").AppendLine(callsite.DescriptorJoin);
        text.Append("Arguments: ").AppendLine(ArgumentWidth(callsite));
        text.Append("Results: ").AppendLine(ResultWidth(callsite));
        text.Append("Receiver: ").Append(callsite.ReceiverDisplay)
            .Append("; type ").Append(callsite.ReceiverTypeDisplay)
            .Append("; confidence ").AppendLine(callsite.ReceiverSemantics.Confidence ?? "none");
        text.Append("Parameters: ").AppendLine(callsite.Contract.Parameters ?? "not established");
        text.Append("Returns: ").AppendLine(callsite.Contract.Returns ?? "not established");
        text.Append("Contract evidence: ").AppendLine(callsite.Contract.Evidence ?? "none recorded");
        text.Append("Receiver evidence: ").AppendLine(callsite.ReceiverSemantics.Evidence ?? "none recorded");
        text.Append("Evidence boundary: ").Append(Boundary(callsite));
        return text.ToString();
    }

    private static string ArgumentWidth(SemanticCallsiteEntry callsite) => callsite.OpenArguments
        ? $"open; value webs {callsite.ArgumentDisplay}"
        : $"{callsite.ExplicitArgumentCount?.ToString(CultureInfo.InvariantCulture) ?? "unknown"}; value webs {callsite.ArgumentDisplay}";

    private static string ResultWidth(SemanticCallsiteEntry callsite) => callsite.OpenResults
        ? $"open; value webs {callsite.ResultDisplay}"
        : $"{callsite.ResultCount?.ToString(CultureInfo.InvariantCulture) ?? "unknown"}; value webs {callsite.ResultDisplay}";

    private static string Boundary(SemanticCallsiteEntry callsite)
    {
        if (callsite.Contract.Match == "OBSERVED_MISMATCH")
            return "The stock call form is outside the current observed contract. Preserve it; do not rewrite it automatically.";
        if (callsite.Contract.Match == "AMBIGUOUS")
            return "Several SDK descriptors remain possible. No contract was selected.";
        if (callsite.Contract.Status == "UNRESOLVED")
            return "A descriptor exists, but its behavior contract remains unresolved.";
        if (callsite.DescriptorJoin == "RECEIVER_TYPE_CONFLICT")
            return "The recorded receiver type conflicts with descriptor ownership. The displayed candidate is retained only as evidence.";
        if (callsite.Contract.Descriptor is null)
            return "The callsite identity and source span are exact. No SDK contract is registered, so parameter meaning and runtime behavior are not claimed.";
        if (callsite.Contract.Status == "CONFIRMED")
            return "The descriptor and contract are supported by the recorded evidence above.";
        return "The descriptor is evidence-bound at the stated confidence; stronger runtime behavior is not claimed.";
    }
}
