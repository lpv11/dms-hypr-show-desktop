import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "show-desktop"

    readonly property string defaultScriptPath: "/home/lpv/.config/DankMaterialShell/plugins/dms-hypr-show-desktop/assets/show-desktop.sh"
    readonly property string scriptPath: (pluginData.scriptPath || defaultScriptPath).trim()
    readonly property string showDesktopButton: (pluginData.showDesktopButton || "middle").toLowerCase()
    readonly property string toggleOverviewButton: (pluginData.toggleOverviewButton || "right").toLowerCase()
    readonly property string iconName: pluginData.iconName || "desktop_windows"

    function runShowDesktopAll() {
        Quickshell.execDetached(["/bin/sh", scriptPath, "all"])
    }

    function toggleOverview() {
        Quickshell.execDetached(["dms", "ipc", "call", "hypr", "toggleOverview"])
    }

    function handleMouseButton(button) {
        const isLeft = button === Qt.LeftButton
        const isMiddle = button === Qt.MiddleButton
        const isRight = button === Qt.RightButton

        if (isLeft && showDesktopButton === "left")
            return runShowDesktopAll()
        if (isMiddle && showDesktopButton === "middle")
            return runShowDesktopAll()
        if (isRight && showDesktopButton === "right")
            return runShowDesktopAll()

        if (isLeft && toggleOverviewButton === "left")
            return toggleOverview()
        if (isMiddle && toggleOverviewButton === "middle")
            return toggleOverview()
        if (isRight && toggleOverviewButton === "right")
            return toggleOverview()
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: root.widgetThickness
            implicitHeight: root.widgetThickness

            DankIcon {
                anchors.centerIn: parent
                name: root.iconName
                size: Math.max(16, root.widgetThickness - 8)
                color: Theme.widgetTextColor
            }

            // Slightly oversized hit area so edge placement is easier to click.
            MouseArea {
                anchors.fill: parent
                anchors.margins: -14
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => {
                    root.handleMouseButton(mouse.button)
                    mouse.accepted = true
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: root.widgetThickness
            implicitHeight: root.widgetThickness

            DankIcon {
                anchors.centerIn: parent
                name: root.iconName
                size: Math.max(16, root.widgetThickness - 8)
                color: Theme.widgetTextColor
            }

            // Slightly oversized hit area so edge placement is easier to click.
            MouseArea {
                anchors.fill: parent
                anchors.margins: -14
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => {
                    root.handleMouseButton(mouse.button)
                    mouse.accepted = true
                }
            }
        }
    }
}
