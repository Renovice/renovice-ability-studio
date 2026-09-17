using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Media;
using Renovice.AbilityEditor.Core;

namespace Renovice.AbilityEditor.App;

internal sealed record SemanticCallsiteAnnotation(
    int Offset,
    int Length,
    SemanticCallsiteEntry Callsite,
    SemanticCallsitePresentation Presentation)
{
    public int End => checked(Offset + Length);
    public bool Contains(int characterIndex) => characterIndex >= Offset && characterIndex < End;
}

internal sealed class SemanticCallsiteAdorner : Adorner
{
    private static readonly Brush InformationBrush = FrozenBrush(83, 126, 145);
    private static readonly Brush WarningBrush = FrozenBrush(226, 176, 91);
    private static readonly Brush MismatchBrush = FrozenBrush(229, 95, 95);
    private static readonly Brush WarningFill = FrozenBrush(48, 226, 176, 91);
    private static readonly Brush MismatchFill = FrozenBrush(58, 229, 95, 95);
    private readonly TextBox editor;
    private IReadOnlyList<SemanticCallsiteAnnotation> annotations = [];

    public SemanticCallsiteAdorner(TextBox editor) : base(editor)
    {
        this.editor = editor;
        IsHitTestVisible = false;
    }

    public void SetAnnotations(IReadOnlyList<SemanticCallsiteAnnotation> value)
    {
        annotations = value;
        InvalidateVisual();
    }

    protected override void OnRender(DrawingContext drawingContext)
    {
        base.OnRender(drawingContext);
        if (annotations.Count == 0 || editor.Text.Length == 0) return;

        drawingContext.PushClip(new RectangleGeometry(new Rect(editor.RenderSize)));
        foreach (var annotation in annotations)
        {
            foreach (var rectangle in VisibleRectangles(annotation))
            {
                var brush = annotation.Presentation.MarkerKind switch
                {
                    SemanticCallsiteMarkerKind.ObservedMismatch => MismatchBrush,
                    SemanticCallsiteMarkerKind.EvidenceWarning => WarningBrush,
                    _ => InformationBrush,
                };
                if (annotation.Presentation.MarkerKind == SemanticCallsiteMarkerKind.ObservedMismatch)
                    drawingContext.DrawRectangle(MismatchFill, null, rectangle);
                else if (annotation.Presentation.MarkerKind == SemanticCallsiteMarkerKind.EvidenceWarning)
                    drawingContext.DrawRectangle(WarningFill, null, rectangle);

                var pen = new Pen(brush, annotation.Presentation.IsWarning ? 1.8 : 1.0)
                {
                    DashStyle = annotation.Presentation.IsWarning ? DashStyles.Solid : DashStyles.Dot,
                };
                pen.Freeze();
                var underline = Math.Max(rectangle.Top, rectangle.Bottom - 1.5);
                drawingContext.DrawLine(pen, new Point(rectangle.Left, underline), new Point(rectangle.Right, underline));
            }
        }
        drawingContext.Pop();
    }

    private IEnumerable<Rect> VisibleRectangles(SemanticCallsiteAnnotation annotation)
    {
        var textLength = editor.Text.Length;
        var cursor = Math.Clamp(annotation.Offset, 0, textLength);
        var end = Math.Clamp(annotation.End, cursor, textLength);
        while (cursor < end)
        {
            var line = editor.GetLineIndexFromCharacterIndex(cursor);
            if (line < 0) yield break;
            var nextLineStart = line + 1 < editor.LineCount
                ? editor.GetCharacterIndexFromLineIndex(line + 1)
                : textLength;
            var contentEnd = nextLineStart;
            while (contentEnd > cursor && editor.Text[contentEnd - 1] is '\r' or '\n') contentEnd--;
            var segmentEnd = Math.Min(end, contentEnd);
            if (segmentEnd > cursor)
            {
                var first = editor.GetRectFromCharacterIndex(cursor, trailingEdge: false);
                var last = editor.GetRectFromCharacterIndex(segmentEnd - 1, trailingEdge: true);
                if (!first.IsEmpty && !last.IsEmpty)
                {
                    var left = first.Left;
                    var right = Math.Max(left + 2, last.Right);
                    var top = Math.Min(first.Top, last.Top);
                    var bottom = Math.Max(first.Bottom, last.Bottom);
                    if (bottom >= 0 && top <= editor.ActualHeight && right >= 0 && left <= editor.ActualWidth)
                        yield return new Rect(new Point(left, top), new Point(right, bottom));
                }
            }
            if (nextLineStart <= cursor) yield break;
            cursor = Math.Min(end, nextLineStart);
        }
    }

    private static SolidColorBrush FrozenBrush(byte red, byte green, byte blue)
    {
        var brush = new SolidColorBrush(Color.FromRgb(red, green, blue));
        brush.Freeze();
        return brush;
    }

    private static SolidColorBrush FrozenBrush(byte alpha, byte red, byte green, byte blue)
    {
        var brush = new SolidColorBrush(Color.FromArgb(alpha, red, green, blue));
        brush.Freeze();
        return brush;
    }
}
