/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the test suite of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.2
import QtQuick.Window 2.2
import QtTest 1.0
import Qt.labs.controls 1.0
import Qt.labs.controls.material 1.0

TestCase {
    id: testCase
    width: 200
    height: 200
    visible: true
    when: windowShown
    name: "Material"

    Component {
        id: button
        Button { }
    }

    Component {
        id: styledButton
        Button {
            Material.theme: Material.Dark
            Material.accent: Material.DeepPurple
        }
    }

    Component {
        id: window
        Window { }
    }

    Component {
        id: styledWindow
        Window {
            Material.theme: Material.Dark
            Material.accent: Material.Green
        }
    }

    Component {
        id: loader
        Loader {
            active: false
            sourceComponent: Button { }
        }
    }

    Component {
        id: swipeView
        SwipeView {
            Material.theme: Material.Dark
            Button { }
        }
    }

    Component {
        id: menu
        Item {
            Material.accent: Material.Red
            property alias menu: popup
            Menu {
                id: popup
                Material.theme: Material.Dark
                MenuItem { }
            }
        }
    }

    Component {
        id: comboBox
        ApplicationWindow {
            width: 200
            height: 200
            visible: true
            Material.accent: Material.Red
            property alias combo: box
            ComboBox {
                id: box
                Material.theme: Material.Dark
                model: 1
            }
        }
    }

    function test_defaults() {
        var control = button.createObject(testCase)
        verify(control)
        verify(control.Material)
        compare(control.Material.accent, Material.color(Material.Teal))
        compare(control.Material.theme, Material.Light)
        control.destroy()
    }

    function test_set() {
        var control = button.createObject(testCase)
        verify(control)
        control.Material.accent = Material.Brown
        control.Material.theme = Material.Dark
        compare(control.Material.accent, Material.color(Material.Brown))
        compare(control.Material.theme, Material.Dark)
        control.destroy()
    }

    function test_reset() {
        var control = styledButton.createObject(testCase)
        verify(control)
        compare(control.Material.accent, Material.color(Material.DeepPurple))
        compare(control.Material.theme, Material.Dark)
        control.Material.accent = undefined
        control.Material.theme = undefined
        compare(control.Material.accent, testCase.Material.accent)
        compare(control.Material.theme, testCase.Material.theme)
        control.destroy()
    }

    function test_inheritance_data() {
        return [
            { tag: "accent", value1: Material.color(Material.Amber), value2: Material.color(Material.Indigo) },
            { tag: "theme", value1: Material.Dark, value2: Material.Light },
        ]
    }

    function test_inheritance(data) {
        var prop = data.tag
        var parent = button.createObject(testCase)
        parent.Material[prop] = data.value1
        compare(parent.Material[prop], data.value1)

        var child1 = button.createObject(parent)
        compare(child1.Material[prop], data.value1)

        parent.Material[prop] = data.value2
        compare(parent.Material[prop], data.value2)
        compare(child1.Material[prop], data.value2)

        var child2 = button.createObject(parent)
        compare(child2.Material[prop], data.value2)

        child2.Material[prop] = data.value1
        compare(child2.Material[prop], data.value1)
        compare(child1.Material[prop], data.value2)
        compare(parent.Material[prop], data.value2)

        parent.Material[prop] = undefined
        verify(parent.Material[prop] !== data.value1)
        verify(parent.Material[prop] !== undefined)
        compare(child1.Material[prop], parent.Material[prop])
        verify(child2.Material[prop] !== parent.Material[prop])

        var grandChild1 = button.createObject(child1)
        var grandChild2 = button.createObject(child2)
        compare(grandChild1.Material[prop], child1.Material[prop])
        compare(grandChild2.Material[prop], child2.Material[prop])

        var themelessGrandGrandChild = button.createObject(grandChild1)
        var grandGrandGrandChild1 = button.createObject(themelessGrandGrandChild)
        compare(grandGrandGrandChild1.Material[prop], parent.Material[prop])

        child1.Material[prop] = data.value2
        compare(child1.Material[prop], data.value2)
        compare(grandChild1.Material[prop], data.value2)
        compare(grandGrandGrandChild1.Material[prop], data.value2)

        parent.destroy()
    }

    function test_window() {
        var parent = window.createObject()

        var control = button.createObject(parent.contentItem)
        compare(control.Material.accent, parent.Material.accent)
        compare(control.Material.theme, parent.Material.theme)

        var styledChild = styledWindow.createObject(window)
        verify(styledChild.Material.accent !== parent.Material.accent)
        verify(styledChild.Material.theme !== parent.Material.theme)

        var unstyledChild = window.createObject(window)
        compare(unstyledChild.Material.accent, parent.Material.accent)
        compare(unstyledChild.Material.theme, parent.Material.theme)

        parent.Material.accent = Material.Cyan
        compare(control.Material.accent, Material.color(Material.Cyan))
        verify(styledChild.Material.accent !== Material.color(Material.Cyan))
        // ### TODO: compare(unstyledChild.Material.accent, Material.color(Material.Cyan))

        parent.destroy()
    }

    function test_loader() {
        var control = loader.createObject(testCase)
        control.Material.accent = Material.Lime
        control.active = true
        compare(control.item.Material.accent, Material.color(Material.Lime))
        control.Material.accent = Material.Pink
        compare(control.item.Material.accent, Material.color(Material.Pink))
        control.active = false
        control.Material.accent = Material.Brown
        control.active = true
        compare(control.item.Material.accent, Material.color(Material.Brown))
        control.destroy()
    }

    function test_swipeView() {
        var control = swipeView.createObject(testCase)
        verify(control)
        var child = control.itemAt(0)
        verify(child)
        compare(control.Material.theme, Material.Dark)
        compare(child.Material.theme, Material.Dark)
        control.destroy()
    }

    function test_menu() {
        var container = menu.createObject(testCase)
        verify(container)
        verify(container.menu)
        var child = container.menu.itemAt(0)
        verify(child)
        compare(container.Material.theme, Material.Light)
        compare(container.menu.Material.theme, Material.Dark)
        compare(child.Material.theme, Material.Dark)
        compare(container.Material.accent, Material.color(Material.Red))
        compare(container.menu.Material.accent, Material.color(Material.Red))
        compare(child.Material.accent, Material.color(Material.Red))
        container.destroy()
    }

    function test_comboBox() {
        var window = comboBox.createObject(testCase)
        verify(window)
        verify(window.combo)
        waitForRendering(window.combo)
        window.combo.forceActiveFocus()
        verify(window.combo.activeFocus)
        keyClick(Qt.Key_Space)
        verify(window.combo.popup.visible)
        var listView = window.combo.popup.contentItem.children[0]
        verify(listView)
        var child = listView.contentItem.children[0]
        verify(child)
        compare(window.Material.theme, Material.Light)
        compare(window.combo.Material.theme, Material.Dark)
        compare(child.Material.theme, Material.Dark)
        compare(window.Material.accent, Material.color(Material.Red))
        compare(window.combo.Material.accent, Material.color(Material.Red))
        compare(child.Material.accent, Material.color(Material.Red))
        window.destroy()
    }

    function test_colors() {
        var control = button.createObject(testCase)
        verify(control)

        // Material.Accent - enum
        control.Material.accent = Material.Red
        compare(control.Material.accent, "#f44336")

        // Material.Accent - string
        control.Material.accent = "BlueGrey"
        compare(control.Material.accent, "#607d8b")

        // SVG named color
        control.Material.accent = "tomato"
        compare(control.Material.accent, "#ff6347")

        // #rrggbb
        control.Material.accent = "#123456"
        compare(control.Material.accent, "#123456")

        // #aarrggbb
        control.Material.accent = "#12345678"
        compare(control.Material.accent, "#12345678")

        // Qt.rgba() - no alpha
        control.Material.accent = Qt.rgba(0.5, 0.5, 0.5)
        compare(control.Material.accent, "#808080")

        // Qt.rgba() - with alpha
        control.Material.accent = Qt.rgba(0.5, 0.5, 0.5, 0.5)
        compare(control.Material.accent, "#80808080")

        // unknown
        ignoreWarning(Qt.resolvedUrl("tst_material.qml") + ":57:9: QML Button: unknown Material.accent value: 123")
        control.Material.accent = 123
        ignoreWarning(Qt.resolvedUrl("tst_material.qml") + ":57:9: QML Button: unknown Material.accent value: foo")
        control.Material.accent = "foo"
        ignoreWarning(Qt.resolvedUrl("tst_material.qml") + ":57:9: QML Button: unknown Material.accent value: #1")
        control.Material.accent = "#1"

        control.destroy()
    }
}
