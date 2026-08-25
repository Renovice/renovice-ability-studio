#include "renovice/core.hpp"

#include <array>
#include <filesystem>
#include <optional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>

#include <windows.h>
#include <commctrl.h>
#include <shellapi.h>

namespace
{
    enum ControlId : int
    {
        id_project = 1001,
        id_warframe,
        id_ability,
        id_ability_identifier,
        id_localize_tag,
        id_module_path,
        id_body_key,
        id_installed_build,
        id_hook,
        id_handler_slot,
        id_rate_id,
        id_rate_label,
        id_base_percent,
        id_max_percent,
        id_modifier_binding,
        id_cap_id,
        id_cap_label,
        id_cap_value,
        id_trace_prefix,
        id_staging_root,
        id_build = 1101,
        id_open_folder,
        id_status,
    };

    struct AppState
    {
        std::filesystem::path editor_root;
        std::filesystem::path last_generation;
        std::unordered_map<int, HWND> controls;
        HFONT font = nullptr;
    };

    [[nodiscard]] std::filesystem::path executable_path()
    {
        std::wstring buffer(32768, L'\0');
        const DWORD length = GetModuleFileNameW(nullptr, buffer.data(), static_cast<DWORD>(buffer.size()));
        if (length == 0 || length >= buffer.size())
        {
            throw std::runtime_error("GetModuleFileNameW failed");
        }
        buffer.resize(length);
        return std::filesystem::path(buffer);
    }

    [[nodiscard]] std::string wide_to_utf8(const std::wstring& value)
    {
        if (value.empty())
        {
            return {};
        }
        const int count = WideCharToMultiByte(
            CP_UTF8, WC_ERR_INVALID_CHARS, value.data(), static_cast<int>(value.size()), nullptr, 0, nullptr, nullptr);
        if (count <= 0)
        {
            throw std::runtime_error("Invalid Unicode input");
        }
        std::string output(static_cast<std::size_t>(count), '\0');
        WideCharToMultiByte(
            CP_UTF8,
            WC_ERR_INVALID_CHARS,
            value.data(),
            static_cast<int>(value.size()),
            output.data(),
            count,
            nullptr,
            nullptr);
        return output;
    }

    [[nodiscard]] std::wstring utf8_to_wide(const std::string& value)
    {
        if (value.empty())
        {
            return {};
        }
        const int count = MultiByteToWideChar(
            CP_UTF8, MB_ERR_INVALID_CHARS, value.data(), static_cast<int>(value.size()), nullptr, 0);
        if (count <= 0)
        {
            throw std::runtime_error("Invalid UTF-8 output");
        }
        std::wstring output(static_cast<std::size_t>(count), L'\0');
        MultiByteToWideChar(
            CP_UTF8,
            MB_ERR_INVALID_CHARS,
            value.data(),
            static_cast<int>(value.size()),
            output.data(),
            count);
        return output;
    }

    void set_font(const AppState& state, const HWND control)
    {
        SendMessageW(control, WM_SETFONT, reinterpret_cast<WPARAM>(state.font), TRUE);
    }

    HWND add_label(AppState& state, const HWND parent, const wchar_t* text, const int x, const int y, const int width)
    {
        const HWND control = CreateWindowExW(
            0, L"STATIC", text, WS_CHILD | WS_VISIBLE, x, y, width, 22, parent, nullptr, nullptr, nullptr);
        set_font(state, control);
        return control;
    }

    HWND add_edit(
        AppState& state,
        const HWND parent,
        const int id,
        const wchar_t* value,
        const int x,
        const int y,
        const int width)
    {
        const HWND control = CreateWindowExW(
            WS_EX_CLIENTEDGE,
            L"EDIT",
            value,
            WS_CHILD | WS_VISIBLE | WS_TABSTOP | ES_AUTOHSCROLL,
            x,
            y,
            width,
            25,
            parent,
            reinterpret_cast<HMENU>(static_cast<INT_PTR>(id)),
            nullptr,
            nullptr);
        set_font(state, control);
        state.controls[id] = control;
        return control;
    }

    [[nodiscard]] std::string edit_text(const AppState& state, const int id)
    {
        const HWND control = state.controls.at(id);
        const int length = GetWindowTextLengthW(control);
        std::wstring value(static_cast<std::size_t>(length) + 1, L'\0');
        GetWindowTextW(control, value.data(), length + 1);
        value.resize(static_cast<std::size_t>(length));
        return wide_to_utf8(value);
    }

    [[nodiscard]] double edit_number(const AppState& state, const int id, const char* label)
    {
        const std::string text = edit_text(state, id);
        std::size_t consumed = 0;
        const double value = std::stod(text, &consumed);
        if (consumed != text.size() || !std::isfinite(value))
        {
            throw std::runtime_error(std::string(label) + " must be a finite number");
        }
        return value;
    }

    void set_status(const AppState& state, const std::string& value)
    {
        SetWindowTextW(state.controls.at(id_status), utf8_to_wide(value).c_str());
    }

    [[nodiscard]] renovice::LinkedAddonForm form_from_controls(const AppState& state)
    {
        renovice::LinkedAddonForm form;
        form.project_id = edit_text(state, id_project);
        form.warframe = edit_text(state, id_warframe);
        form.ability = edit_text(state, id_ability);
        form.ability_identifier = edit_text(state, id_ability_identifier);
        form.ability_localize_tag = edit_text(state, id_localize_tag);
        form.module_path = edit_text(state, id_module_path);
        form.module_body_key = edit_text(state, id_body_key);
        form.installed_build = edit_text(state, id_installed_build);
        form.hook_binding = edit_text(state, id_hook);
        form.handler_slot = edit_text(state, id_handler_slot);
        form.rate_id = edit_text(state, id_rate_id);
        form.rate_label = edit_text(state, id_rate_label);
        form.base_percent = edit_number(state, id_base_percent, "Base percent");
        form.maximum_percent = edit_number(state, id_max_percent, "Maximum percent");
        form.modifier_binding = edit_text(state, id_modifier_binding);
        form.cap_id = edit_text(state, id_cap_id);
        form.cap_label = edit_text(state, id_cap_label);
        form.cap_value = edit_number(state, id_cap_value, "Overguard cap");
        form.trace_prefix = edit_text(state, id_trace_prefix);
        return form;
    }

    void build_project(AppState& state)
    {
        set_status(state, "Building staged addon...\r\nThe UI may pause briefly while the compiler gates run.");
        const renovice::LinkedAddonForm form = form_from_controls(state);
        const renovice::Json project = renovice::make_linked_overguard_project(form);
        const std::filesystem::path staging_root = std::filesystem::absolute(edit_text(state, id_staging_root));
        const renovice::BuildResult result = renovice::build_staged_addon(
            project, state.editor_root, staging_root, true);
        state.last_generation = result.generation_directory;

        std::ostringstream report;
        report << (result.success ? "BUILD STAGED: PASS\r\n" : "BUILD STAGED: FAILED\r\n")
               << "\r\n"
               << renovice::diagnostics_text(result.diagnostics);
        if (!result.generation_directory.empty())
        {
            report << "\r\nGeneration: " << result.generation_directory.string()
                   << "\r\nSource: " << result.generated_source.string()
                   << "\r\nBytecode: " << result.generated_bytecode.string()
                   << "\r\nManifest: " << result.manifest.string()
                   << "\r\n\r\nNo live game file was modified.";
        }
        set_status(state, report.str());
        EnableWindow(state.controls.at(id_open_folder), !state.last_generation.empty());
        MessageBoxW(
            nullptr,
            result.success
                ? L"Linked addon generated and all focused gates passed. Nothing was deployed to the live game."
                : L"The staged addon did not pass every required gate. Inspect the diagnostics in the editor.",
            L"RENOVICE Ability Editor",
            MB_OK | (result.success ? MB_ICONINFORMATION : MB_ICONERROR));
    }

    void create_controls(const HWND window, AppState& state)
    {
        state.font = CreateFontW(
            -17, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET,
            OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY,
            DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");

        add_label(state, window, L"Addon Creation / Linked Stats", 22, 14, 420);
        add_label(
            state,
            window,
            L"One canonical stat definition generates gameplay math and native ability-card rows.",
            22,
            40,
            760);

        constexpr int left_label = 22;
        constexpr int left_edit = 170;
        constexpr int right_label = 545;
        constexpr int right_edit = 700;
        constexpr int edit_width = 330;
        int y = 76;
        const int row = 34;

        add_label(state, window, L"Project ID", left_label, y, 145);
        add_edit(state, window, id_project, L"octavia.mallet.overguard", left_edit, y - 3, edit_width);
        add_label(state, window, L"Installed build", right_label, y, 145);
        add_edit(state, window, id_installed_build, L"private-live-2026-08-25", right_edit, y - 3, edit_width);
        y += row;

        add_label(state, window, L"Warframe", left_label, y, 145);
        add_edit(state, window, id_warframe, L"Octavia", left_edit, y - 3, edit_width);
        add_label(state, window, L"Ability", right_label, y, 145);
        add_edit(state, window, id_ability, L"Mallet", right_edit, y - 3, edit_width);
        y += row;

        add_label(state, window, L"Ability ID", left_label, y, 145);
        add_edit(state, window, id_ability_identifier, L"BARD_MUSIC", left_edit, y - 3, edit_width);
        add_label(state, window, L"Body key", right_label, y, 145);
        add_edit(state, window, id_body_key, L"08faf07b504d058f", right_edit, y - 3, edit_width);
        y += row;

        add_label(state, window, L"Module path", left_label, y, 145);
        add_edit(
            state,
            window,
            id_module_path,
            L"Lotus/Powersuits/Bard/Abilities/BardMusic.lua",
            left_edit,
            y - 3,
            edit_width);
        add_label(state, window, L"Localize tag", right_label, y, 145);
        add_edit(
            state,
            window,
            id_localize_tag,
            L"/Lotus/Language/Suits/BardMusicAbilityName",
            right_edit,
            y - 3,
            edit_width);
        y += row + 10;

        add_label(state, window, L"Proven hook", left_label, y, 145);
        add_edit(state, window, id_hook, L"renovice.mallet.damage_dispatch", left_edit, y - 3, edit_width);
        add_label(state, window, L"Handler slot", right_label, y, 145);
        add_edit(state, window, id_handler_slot, L"RENOVICE_AFTER_MALLET_DAMAGE", right_edit, y - 3, edit_width);
        y += row + 10;

        add_label(state, window, L"Rate stat ID", left_label, y, 145);
        add_edit(state, window, id_rate_id, L"damage_to_overguard", left_edit, y - 3, edit_width);
        add_label(state, window, L"Card label", right_label, y, 145);
        add_edit(state, window, id_rate_label, L"Overguard From Damage", right_edit, y - 3, edit_width);
        y += row;

        add_label(state, window, L"Base percent", left_label, y, 145);
        add_edit(state, window, id_base_percent, L"1", left_edit, y - 3, edit_width);
        add_label(state, window, L"Maximum percent", right_label, y, 145);
        add_edit(state, window, id_max_percent, L"5", right_edit, y - 3, edit_width);
        y += row;

        add_label(state, window, L"Modifier binding", left_label, y, 145);
        add_edit(state, window, id_modifier_binding, L"mallet.strength.channel_10", left_edit, y - 3, edit_width);
        add_label(state, window, L"Trace prefix", right_label, y, 145);
        add_edit(state, window, id_trace_prefix, L"mallet.addon", right_edit, y - 3, edit_width);
        y += row + 10;

        add_label(state, window, L"Cap stat ID", left_label, y, 145);
        add_edit(state, window, id_cap_id, L"overguard_cap", left_edit, y - 3, edit_width);
        add_label(state, window, L"Cap card label", right_label, y, 145);
        add_edit(state, window, id_cap_label, L"Overguard Cap", right_edit, y - 3, edit_width);
        y += row;

        add_label(state, window, L"Cap value", left_label, y, 145);
        add_edit(state, window, id_cap_value, L"15000", left_edit, y - 3, edit_width);
        add_label(state, window, L"Staging root", right_label, y, 145);
        add_edit(
            state,
            window,
            id_staging_root,
            (state.editor_root / "STAGING").wstring().c_str(),
            right_edit,
            y - 3,
            edit_width);
        y += row + 12;

        const HWND build = CreateWindowExW(
            0,
            WC_BUTTONW,
            L"Validate + Build Staged Addon",
            WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_DEFPUSHBUTTON,
            22,
            y,
            260,
            34,
            window,
            reinterpret_cast<HMENU>(static_cast<INT_PTR>(id_build)),
            nullptr,
            nullptr);
        set_font(state, build);
        state.controls[id_build] = build;

        const HWND open = CreateWindowExW(
            0,
            WC_BUTTONW,
            L"Open Last Build Folder",
            WS_CHILD | WS_VISIBLE | WS_TABSTOP,
            296,
            y,
            210,
            34,
            window,
            reinterpret_cast<HMENU>(static_cast<INT_PTR>(id_open_folder)),
            nullptr,
            nullptr);
        set_font(state, open);
        EnableWindow(open, FALSE);
        state.controls[id_open_folder] = open;
        y += 46;

        const HWND status = CreateWindowExW(
            WS_EX_CLIENTEDGE,
            L"EDIT",
            L"Ready. The builder stages locally and never writes directly to the live game.",
            WS_CHILD | WS_VISIBLE | WS_VSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_READONLY,
            22,
            y,
            1008,
            205,
            window,
            reinterpret_cast<HMENU>(static_cast<INT_PTR>(id_status)),
            nullptr,
            nullptr);
        set_font(state, status);
        state.controls[id_status] = status;
    }

    LRESULT CALLBACK window_proc(const HWND window, const UINT message, const WPARAM w_param, const LPARAM l_param)
    {
        AppState* state = reinterpret_cast<AppState*>(GetWindowLongPtrW(window, GWLP_USERDATA));
        if (message == WM_NCCREATE)
        {
            const auto* creation = reinterpret_cast<const CREATESTRUCTW*>(l_param);
            state = static_cast<AppState*>(creation->lpCreateParams);
            SetWindowLongPtrW(window, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(state));
        }

        try
        {
            switch (message)
            {
            case WM_CREATE:
                create_controls(window, *state);
                return 0;
            case WM_COMMAND:
                if (LOWORD(w_param) == id_build && HIWORD(w_param) == BN_CLICKED)
                {
                    build_project(*state);
                    return 0;
                }
                if (LOWORD(w_param) == id_open_folder && HIWORD(w_param) == BN_CLICKED && !state->last_generation.empty())
                {
                    ShellExecuteW(nullptr, L"open", state->last_generation.wstring().c_str(), nullptr, nullptr, SW_SHOWNORMAL);
                    return 0;
                }
                break;
            case WM_DESTROY:
                if (state != nullptr && state->font != nullptr)
                {
                    DeleteObject(state->font);
                    state->font = nullptr;
                }
                PostQuitMessage(0);
                return 0;
            default:
                break;
            }
        }
        catch (const std::exception& exception)
        {
            if (state != nullptr && state->controls.contains(id_status))
            {
                set_status(*state, std::string("ERROR: ") + exception.what());
            }
            MessageBoxW(nullptr, utf8_to_wide(exception.what()).c_str(), L"RENOVICE Ability Editor", MB_OK | MB_ICONERROR);
            return 0;
        }
        return DefWindowProcW(window, message, w_param, l_param);
    }
}

int WINAPI wWinMain(HINSTANCE instance, HINSTANCE, PWSTR, int show_command)
{
    try
    {
        InitCommonControls();
        AppState state;
        state.editor_root = renovice::locate_editor_root(executable_path());

        const wchar_t* class_name = L"RenoviceAbilityEditorWindow";
        WNDCLASSEXW window_class{};
        window_class.cbSize = sizeof(window_class);
        window_class.lpfnWndProc = window_proc;
        window_class.hInstance = instance;
        window_class.hCursor = LoadCursorW(nullptr, IDC_ARROW);
        window_class.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1);
        window_class.lpszClassName = class_name;
        window_class.hIcon = LoadIconW(nullptr, IDI_APPLICATION);
        window_class.hIconSm = LoadIconW(nullptr, IDI_APPLICATION);
        if (RegisterClassExW(&window_class) == 0)
        {
            throw std::runtime_error("RegisterClassExW failed");
        }

        const HWND window = CreateWindowExW(
            0,
            class_name,
            L"RENOVICE Ability Editor — Linked Addon Stats",
            WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX,
            CW_USEDEFAULT,
            CW_USEDEFAULT,
            1070,
            765,
            nullptr,
            nullptr,
            instance,
            &state);
        if (window == nullptr)
        {
            throw std::runtime_error("CreateWindowExW failed");
        }

        ShowWindow(window, show_command);
        UpdateWindow(window);
        MSG message{};
        while (GetMessageW(&message, nullptr, 0, 0) > 0)
        {
            TranslateMessage(&message);
            DispatchMessageW(&message);
        }
        return static_cast<int>(message.wParam);
    }
    catch (const std::exception& exception)
    {
        MessageBoxW(nullptr, utf8_to_wide(exception.what()).c_str(), L"RENOVICE Ability Editor", MB_OK | MB_ICONERROR);
        return 1;
    }
}
