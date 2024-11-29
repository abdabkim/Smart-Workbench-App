import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TwoJsVisualization extends StatefulWidget {
  const TwoJsVisualization({super.key});

  @override
  State<TwoJsVisualization> createState() => _TwoJsVisualizationState();
}

class _TwoJsVisualizationState extends State<TwoJsVisualization> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html>
        <head>
            <title>Two.js Layout Designer</title>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/two.js/0.8.10/two.min.js"></script>
            <style>
                body { margin: 0; padding: 0; overflow: hidden; background: #f5f5f5; }
                #drawing-area { width: 100vw; height: 100vh; }
                #toolbar {
                    position: fixed;
                    bottom: 20px;
                    left: 50%;
                    transform: translateX(-50%);
                    background: white;
                    padding: 10px;
                    border-radius: 8px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    display: flex;
                    gap: 10px;
                    z-index: 1000;
                }
                button {
                    padding: 8px 16px;
                    border: none;
                    border-radius: 4px;
                    background: #2196F3;
                    color: white;
                    cursor: pointer;
                }
                button:active {
                    background: #1976D2;
                }
            </style>
        </head>
        <body>
            <div id="drawing-area"></div>
            <div id="toolbar">
                <button onclick="addWorkbench()">Add Workbench</button>
                <button onclick="addToolCabinet()">Add Tool Cabinet</button>
                <button onclick="addStorageShelf()">Add Storage Shelf</button>
                <button onclick="clearCanvas()">Clear</button>
            </div>
            <script>
                var elem = document.getElementById('drawing-area');
                var params = { 
                    fullscreen: true,
                    autostart: true
                };
                var two = new Two(params).appendTo(elem);

                // Create grid
                function createGrid() {
                    var gridGroup = two.makeGroup();
                    for (var x = 0; x < two.width; x += 30) {
                        var line = two.makeLine(x, 0, x, two.height);
                        line.stroke = '#e0e0e0';
                        line.linewidth = 1;
                        gridGroup.add(line);
                    }
                    for (var y = 0; y < two.height; y += 30) {
                        var line = two.makeLine(0, y, two.width, y);
                        line.stroke = '#e0e0e0';
                        line.linewidth = 1;
                        gridGroup.add(line);
                    }
                    return gridGroup;
                }

                // Create furniture functions
                function addWorkbench() {
                    var group = two.makeGroup();
                    
                    // Table top
                    var top = two.makeRectangle(two.width/4, two.height/3, 160, 80);
                    top.fill = '#8B4513';
                    top.stroke = '#654321';
                    
                    // Legs
                    var leg1 = two.makeRectangle(two.width/4 - 70, two.height/3 + 45, 20, 30);
                    var leg2 = two.makeRectangle(two.width/4 + 70, two.height/3 + 45, 20, 30);
                    leg1.fill = '#8B4513';
                    leg2.fill = '#8B4513';
                    
                    group.add(top, leg1, leg2);
                    makeDraggable(group);
                    two.update();
                }

                function addToolCabinet() {
                    var group = two.makeGroup();
                    
                    // Cabinet body
                    var cabinet = two.makeRectangle(two.width/4, two.height/3, 100, 150);
                    cabinet.fill = '#4A4A4A';
                    cabinet.stroke = '#333333';
                    
                    // Drawers
                    for(let i = 0; i < 3; i++) {
                        var drawer = two.makeRectangle(two.width/4, two.height/3 - 40 + (i * 50), 90, 40);
                        drawer.fill = '#5A5A5A';
                        drawer.stroke = '#333333';
                        group.add(drawer);
                    }
                    
                    group.add(cabinet);
                    makeDraggable(group);
                    two.update();
                }

                function addStorageShelf() {
                    var group = two.makeGroup();
                    
                    // Main shelf
                    var shelf = two.makeRectangle(two.width/4, two.height/3, 120, 180);
                    shelf.fill = '#D2B48C';
                    shelf.stroke = '#8B4513';
                    
                    // Shelves
                    for(let i = 0; i < 4; i++) {
                        var level = two.makeRectangle(two.width/4, two.height/3 - 60 + (i * 50), 120, 5);
                        level.fill = '#8B4513';
                        group.add(level);
                    }
                    
                    group.add(shelf);
                    makeDraggable(group);
                    two.update();
                }

                // Make items draggable
                function makeDraggable(group) {
                    var isDragging = false;
                    var offset = { x: 0, y: 0 };

                    elem.addEventListener('mousedown', function(e) {
                        var rect = elem.getBoundingClientRect();
                        var x = e.clientX - rect.left;
                        var y = e.clientY - rect.top;

                        // Check if click is within the group bounds
                        if (x >= group.translation.x - 80 && x <= group.translation.x + 80 &&
                            y >= group.translation.y - 80 && y <= group.translation.y + 80) {
                            isDragging = true;
                            offset.x = x - group.translation.x;
                            offset.y = y - group.translation.y;
                        }
                    });

                    elem.addEventListener('mousemove', function(e) {
                        if (isDragging) {
                            var rect = elem.getBoundingClientRect();
                            group.translation.x = e.clientX - rect.left - offset.x;
                            group.translation.y = e.clientY - rect.top - offset.y;
                            two.update();
                        }
                    });

                    elem.addEventListener('mouseup', function() {
                        isDragging = false;
                    });

                    // Touch events for mobile
                    elem.addEventListener('touchstart', function(e) {
                        var touch = e.touches[0];
                        var rect = elem.getBoundingClientRect();
                        var x = touch.clientX - rect.left;
                        var y = touch.clientY - rect.top;

                        if (x >= group.translation.x - 80 && x <= group.translation.x + 80 &&
                            y >= group.translation.y - 80 && y <= group.translation.y + 80) {
                            isDragging = true;
                            offset.x = x - group.translation.x;
                            offset.y = y - group.translation.y;
                        }
                    });

                    elem.addEventListener('touchmove', function(e) {
                        if (isDragging) {
                            var touch = e.touches[0];
                            var rect = elem.getBoundingClientRect();
                            group.translation.x = touch.clientX - rect.left - offset.x;
                            group.translation.y = touch.clientY - rect.top - offset.y;
                            two.update();
                        }
                    });

                    elem.addEventListener('touchend', function() {
                        isDragging = false;
                    });
                }

                function clearCanvas() {
                    two.clear();
                    createGrid();
                    two.update();
                }

                // Initialize grid
                createGrid();
                two.update();
            </script>
        </body>
        </html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Furniture Layout'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}