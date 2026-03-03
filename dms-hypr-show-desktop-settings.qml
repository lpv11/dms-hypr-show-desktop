import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "showDesktop"

    StyledText {
        width: parent.width
        text: "Mouse Actions"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Choose which mouse button triggers each action."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    SelectionSetting {
        settingKey: "iconName"
        label: "Icon"
        description: "Choose the widget icon."
        options: [
            { label: "desktop_windows", value: "desktop_windows" },
            { label: "home", value: "home" },
            { label: "square", value: "square" },
            { label: "stop", value: "stop" }
        ]
        defaultValue: "desktop_windows"
    }

    StringSetting {
        settingKey: "scriptPath"
        label: "Script Path"
        description: "Path to the show-desktop script. Only change if you want to place the script elsewhere."
        placeholder: "$HOME/.config/DankMaterialShell/plugins/dms-hypr-show-desktop/assets/show-desktop.sh"
        defaultValue: "$HOME/.config/DankMaterialShell/plugins/dms-hypr-show-desktop/assets/show-desktop.sh"
    }

    SelectionSetting {
        id: showDesktopButtonSetting
        settingKey: "showDesktopButton"
        label: "Show Desktop"
        description: "Run show-desktop.sh all"
        options: [
            { label: "Left Click", value: "left" },
            { label: "Middle Click", value: "middle" },
            { label: "Right Click", value: "right" },
            { label: "Disabled", value: "none" }
        ]
        defaultValue: "middle"
    }

    SelectionSetting {
        id: toggleOverviewButtonSetting
        settingKey: "toggleOverviewButton"
        label: "Toggle Overview"
        description: "Run dms ipc call hypr toggleOverview"
        options: [
            { label: "Left Click", value: "left" },
            { label: "Middle Click", value: "middle" },
            { label: "Right Click", value: "right" },
            { label: "Disabled", value: "none" }
        ]
        defaultValue: "right"
    }

    StyledText {
        readonly property var configuredButtons: [
            showDesktopButtonSetting.value,
            toggleOverviewButtonSetting.value
        ]
        readonly property bool hasDuplicateButtons: {
            const used = configuredButtons.filter(v => v && v !== "none")
            const unique = Array.from(new Set(used))
            return used.length !== unique.length
        }

        width: parent.width
        visible: hasDuplicateButtons
        text: "Warning: the same mouse button is assigned to multiple actions."
        color: Theme.error
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }
}
