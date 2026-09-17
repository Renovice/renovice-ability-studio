# Ability Studio tree contrast repair — 2026-08-26

## Hypothesis and result

**Setting the `TreeView` foreground alone guarantees readable generated item labels. — FALSE.**

The Warframe and ability labels are created by data templates inside generated `TreeViewItem` containers. The platform item styling allowed a dark/black foreground to reach those labels despite the dark panel background.

**Binding each template label to the owning `TreeViewItem.Foreground`, with an explicit item-container style, fixes normal, hover, and selected states. — TRUE.**

The tree now defines:

- light foreground for normal items;
- a visible dark hover background;
- a blue-gray selected background with white text;
- explicit ancestor bindings in both the Warframe and ability data templates.

## Verification

- Native C++ tests: 100% passed.
- Managed editor tests: 26/26 passed.
- Release build completed successfully.
- Visual smoke capture confirmed that the full Warframe list is readable against the dark tree background.

## 2026-09-02 — ComboBox popup repair

**Setting `ComboBox.Background` and `Foreground` alone themes its opened popup. — FALSE.**

The Windows/WPF default popup and item templates still rendered a white system
surface, while the inherited application foreground remained light. Mission
names therefore became low-contrast or effectively invisible.

**Replacing the global ComboBox and ComboBoxItem templates fixes every editor dropdown. — TRUE.**

The shared template now owns the closed field, arrow area, popup border,
scrolling surface, normal items, hover state, selected state, keyboard focus,
and disabled state. The palette uses the existing dark panels with gold
selection/focus accents. Visual QA on the published executable confirmed the
expanded Survival/Mobile Defense/Interception/Excavation menu no longer exposes
the white system popup.

- Managed Release build: 0 warnings, 0 errors.
- Managed regression harness: 43/43 passed.
- Full mission-source compile/transcode/reparse gates remained green.
