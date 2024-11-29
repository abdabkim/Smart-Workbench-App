import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TwoJsVisualization extends StatefulWidget {
  const TwoJsVisualization({super.key});

  @override
  State<TwoJsVisualization> createState() => _TwoJsVisualizationState();
}

class _TwoJsVisualizationState extends State<TwoJsVisualization> {
  late final WebViewController _controller;
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();

  @override
  void dispose() {
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  void _showDimensionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Workshop Dimensions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _widthController,
                decoration: const InputDecoration(
                  labelText: 'Width (in meters)',
                  hintText: 'Enter workshop width',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: 'Length (in meters)',
                  hintText: 'Enter workshop length',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.runJavaScript(
                  'updateWorkshopDimensions(${_widthController.text}, ${_lengthController.text})'
                );
                Navigator.pop(context);
              },
              child: const Text('Set Dimensions'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html>
        <head>
            <title>Workshop Layout Designer</title>
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
                #dimensions {
                    position: fixed;
                    top: 20px;
                    left: 20px;
                    background: white;
                    padding: 10px;
                    border-radius: 4px;
                    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
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
            <div id="dimensions">Workshop: 0m × 0m</div>
            <div id="toolbar">
                <button onclick="addWorkbench()">Add Workbench</button>
                <button onclick="addToolCabinet()">Add Tool Cabinet</button>
                <button onclick="addStorageShelf()">Add Storage Shelf</button>
                <button onclick="clearCanvas()">Clear</button>
            </div>
            <script>
                var workshopWidth = 0;
                var workshopLength = 0;
                var pixelsPerMeter = 100;
                var two;
                var workshopBoundary;
                var allItems = [];

                function initCanvas() {
                    var elem = document.getElementById('drawing-area');
                    two = new Two({
                        fullscreen: true,
                        autostart: true
                    }).appendTo(elem);
                }

                function updateWorkshopDimensions(width, length) {
                    workshopWidth = parseFloat(width);
                    workshopLength = parseFloat(length);
                    document.getElementById('dimensions').textContent = 
                        `Workshop: \${workshopWidth}m × \${workshopLength}m`;
                    clearCanvas();
                }

                function createWorkshop() {
                    if (workshopWidth === 0 || workshopLength === 0) return;

                    workshopBoundary = two.makeRectangle(
                        50 + (workshopWidth * pixelsPerMeter) / 2,
                        50 + (workshopLength * pixelsPerMeter) / 2,
                        workshopWidth * pixelsPerMeter,
                        workshopLength * pixelsPerMeter
                    );
                    workshopBoundary.stroke = '#1976d2';
                    workshopBoundary.linewidth = 2;
                    workshopBoundary.noFill();
                }

                function createGrid() {
                    if (workshopWidth === 0 || workshopLength === 0) return;
                    
                    var gridGroup = two.makeGroup();
                    var startX = 50;
                    var startY = 50;
                    var endX = 50 + workshopWidth * pixelsPerMeter;
                    var endY = 50 + workshopLength * pixelsPerMeter;

                    for (var x = startX; x <= endX; x += 30) {
                        var line = two.makeLine(x, startY, x, endY);
                        line.stroke = '#e0e0e0';
                        gridGroup.add(line);
                    }

                    for (var y = startY; y <= endY; y += 30) {
                        var line = two.makeLine(startX, y, endX, y);
                        line.stroke = '#e0e0e0';
                        gridGroup.add(line);
                    }
                }

                function isInsideWorkshop(item) {
                    if (workshopWidth === 0 || workshopLength === 0) return true;
                    
                    var itemBounds = item.getBoundingClientRect();
                    var workshopBounds = {
                        left: 50,
                        top: 50,
                        right: 50 + workshopWidth * pixelsPerMeter,
                        bottom: 50 + workshopLength * pixelsPerMeter
                    };

                    return itemBounds.left >= workshopBounds.left &&
                           itemBounds.right <= workshopBounds.right &&
                           itemBounds.top >= workshopBounds.top &&
                           itemBounds.bottom <= workshopBounds.bottom;
                }

                function addWorkbench() {
                    if (workshopWidth === 0 || workshopLength === 0) return;

                    var group = two.makeGroup();
                    var top = two.makeRectangle(100, 100, 160, 80);
                    top.fill = '#8B4513';
                    top.stroke = '#654321';
                    
                    var leg1 = two.makeRectangle(100 - 70, 100 + 45, 20, 30);
                    var leg2 = two.makeRectangle(100 + 70, 100 + 45, 20, 30);
                    leg1.fill = '#8B4513';
                    leg2.fill = '#8B4513';
                    
                    group.add(top, leg1, leg2);
                    allItems.push(group);
                    makeDraggable(group);
                    two.update();
                }

                function addToolCabinet() {
                    if (workshopWidth === 0 || workshopLength === 0) return;

                    var group = two.makeGroup();
                    var cabinet = two.makeRectangle(100, 100, 100, 150);
                    cabinet.fill = '#4A4A4A';
                    cabinet.stroke = '#333333';
                    
                    for(let i = 0; i < 3; i++) {
                        var drawer = two.makeRectangle(100, 100 - 40 + (i * 50), 90, 40);
                        drawer.fill = '#5A5A5A';
                        drawer.stroke = '#333333';
                        group.add(drawer);
                    }
                    
                    group.add(cabinet);
                    allItems.push(group);
                    makeDraggable(group);
                    two.update();
                }

                function addStorageShelf() {
                    if (workshopWidth === 0 || workshopLength === 0) return;

                    var group = two.makeGroup();
                    var shelf = two.makeRectangle(100, 100, 120, 180);
                    shelf.fill = '#D2B48C';
                    shelf.stroke = '#8B4513';
                    
                    for(let i = 0; i < 4; i++) {
                        var level = two.makeRectangle(100, 100 - 60 + (i * 50), 120, 5);
                        level.fill = '#8B4513';
                        group.add(level);
                    }
                    
                    group.add(shelf);
                    allItems.push(group);
                    makeDraggable(group);
                    two.update();
                }

                function makeDraggable(group) {
                    var isDragging = false;
                    var offset = { x: 0, y: 0 };
                    var originalPosition = { x: 0, y: 0 };

                    function onStart(x, y) {
                        var groupBounds = group.getBoundingClientRect();
                        if (x >= group.translation.x - groupBounds.width/2 && 
                            x <= group.translation.x + groupBounds.width/2 &&
                            y >= group.translation.y - groupBounds.height/2 && 
                            y <= group.translation.y + groupBounds.height/2) {
                            isDragging = true;
                            originalPosition = { 
                                x: group.translation.x, 
                                y: group.translation.y 
                            };
                            offset = {
                                x: x - group.translation.x,
                                y: y - group.translation.y
                            };
                        }
                    }

                    function onMove(x, y) {
                        if (isDragging) {
                            group.translation.x = x - offset.x;
                            group.translation.y = y - offset.y;
                            if (!isInsideWorkshop(group)) {
                                group.translation.x = originalPosition.x;
                                group.translation.y = originalPosition.y;
                            }
                            two.update();
                        }
                    }

                    function onEnd() {
                        isDragging = false;
                    }

                    // Mouse events
                    document.addEventListener('mousedown', function(e) {
                        var rect = two.renderer.domElement.getBoundingClientRect();
                        onStart(e.clientX - rect.left, e.clientY - rect.top);
                    });

                    document.addEventListener('mousemove', function(e) {
                        var rect = two.renderer.domElement.getBoundingClientRect();
                        onMove(e.clientX - rect.left, e.clientY - rect.top);
                    });

                    document.addEventListener('mouseup', onEnd);

                    // Touch events
                    document.addEventListener('touchstart', function(e) {
                        var touch = e.touches[0];
                        var rect = two.renderer.domElement.getBoundingClientRect();
                        onStart(touch.clientX - rect.left, touch.clientY - rect.top);
                    });

                    document.addEventListener('touchmove', function(e) {
                        var touch = e.touches[0];
                        var rect = two.renderer.domElement.getBoundingClientRect();
                        onMove(touch.clientX - rect.left, touch.clientY - rect.top);
                    });

                    document.addEventListener('touchend', onEnd);
                }

                function clearCanvas() {
                    two.clear();
                    allItems = [];
                    createWorkshop();
                    createGrid();
                    two.update();
                }

                // Initialize
                initCanvas();
                two.update();
            </script>
        </body>
        </html>
      ''');

    Future.delayed(Duration.zero, _showDimensionsDialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Layout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showDimensionsDialog,
            tooltip: 'Edit Workshop Dimensions',
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
