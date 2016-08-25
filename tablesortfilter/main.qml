/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
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
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.XmlListModel 2.0
import SortFilterProxyModel 0.1
import QtQuick.Controls.Styles  1.0

ApplicationWindow {
    id: window

    width: 640
    height: 360
    visible: true

    property var g_model

    function getIndex(row) {
        return g_model.mapToSource(g_model.index(row, 0));
    }

    XmlListModel {
        id: sourceModel

        source: "https://rss.sciencedaily.com/all.xml"
        query: "/rss/channel/item"

        XmlRole { name: "title";  query: "title/string()" }
    }

    TableView {
        id: tableView
        anchors.fill: parent

        width: parent.width / 2
        frameVisible: false
        sortIndicatorVisible: true
        currentRow: rowCount ? 0 : -1

        TableViewColumn { role: "title"; title: qsTr("Title") }

        onDoubleClicked: Qt.openUrlExternally(proxyModel.get(tableView.currentRow).link)

        property var _proxyModel: SortFilterProxyModel {
            id: proxyModel
            source: sourceModel.count > 0 ? sourceModel : null

            sortOrder: tableView.sortIndicatorOrder
            sortCaseSensitivity: Qt.CaseInsensitive
            sortRole: sourceModel.count > 0 ? tableView.getColumn(tableView.sortIndicatorColumn).role : ""
        }
        model: {
            g_model = _proxyModel;
            return _proxyModel;
        }

        style: TableViewStyle{

            function getShader(styleData) {
                var _backGroundShader =  "
                        varying highp vec2 qt_TexCoord0;
                        uniform sampler2D source;
                        uniform lowp float qt_Opacity;
                        void main() {
                            gl_FragColor = texture2D(source, qt_TexCoord0) * vec4(%1, %2, %3, 1.0) * qt_Opacity;
                        }";
                var red    = _backGroundShader.arg("1.00").arg("0.83").arg("0.83");
                var _index = getIndex(styleData.row);
                console.log("index: ", _index.row);
                console.log("indexProxy: ", styleData.row);
                console.log(sourceModel.get(_index.row).title);
                console.log(g_model.get(styleData.row).title);
                if (sourceModel.get(_index.row).title[0] === "W") {
                    console.log("!!!!!!!!!!!!!!!!!");
                    return red;
                }
                return "";
            }

            rowDelegate: Rectangle {
                color: getShader(styleData) ? "red" : "white"
                layer.enabled: true
                layer.effect: ShaderEffect {
                    anchors.fill: parent
                    fragmentShader: getShader(styleData)
                }
            }
        }

    }

}
