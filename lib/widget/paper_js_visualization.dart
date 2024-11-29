import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaperJsVisualization extends StatefulWidget {
  const PaperJsVisualization({super.key});

  @override
  State<PaperJsVisualization> createState() => _PaperJsVisualizationState();
}

class _PaperJsVisualizationState extends State<PaperJsVisualization> {
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
          title: const Text('Room Dimensions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _widthController,
                decoration: const InputDecoration(
                  labelText: 'Width (in meters)',
                  hintText: 'Enter room width',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: 'Length (in meters)',
                  hintText: 'Enter room length',
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
                  'updateRoomDimensions(${_widthController.text}, ${_lengthController.text})'
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
            <title>Blueprint Designer</title>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/paper.js/0.12.17/paper-full.min.js"></script>
            <style>
                body { margin: 0; padding: 0; overflow: hidden; background: #f0f0f0; }
                canvas { width: 100vw; height: 100vh; }
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
                #dimensions {
                    position: fixed;
                    top: 20px;
                    left: 20px;
                    background: white;
                    padding: 10px;
                    border-radius: 4px;
                    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
                }
            </style>
        </head>
        <body>
            <canvas id="myCanvas" resize></canvas>
            <div id="dimensions">Room: 0m × 0m</div>
            <div id="toolbar">
                <button onclick="addTable()">Add Table</button>
                <button onclick="addChair()">Add Chair</button>
                <button onclick="addStorage()">Add Storage</button>
                <button onclick="clearCanvas()">Clear</button>
            </div>
            <script type="text/javascript">
                var roomWidth = 0;
                var roomLength = 0;
                var pixelsPerMeter = 100;

                // Initialize Paper.js
                paper.setup('myCanvas');
                
                function updateRoomDimensions(width, length) {
                    roomWidth = parseFloat(width);
                    roomLength = parseFloat(length);
                    document.getElementById('dimensions').textContent = 
                        `Room: \${roomWidth}m × \${roomLength}m`;
                    clearCanvas();
                }

                function createRoom() {
                    var room = new paper.Path.Rectangle({
                        point: [50, 50],
                        size: [roomWidth * pixelsPerMeter, roomLength * pixelsPerMeter],
                        strokeColor: '#1976d2',
                        strokeWidth: 2
                    });
                    room.sendToBack();
                }

                function createGrid(size = 20) {
                    if (roomWidth === 0 || roomLength === 0) return;
                    
                    var grid = new paper.Group();
                    var roomRect = new paper.Rectangle(50, 50, 
                        roomWidth * pixelsPerMeter, 
                        roomLength * pixelsPerMeter);

                    for (var x = roomRect.left; x <= roomRect.right; x += size) {
                        var line = new paper.Path.Line(
                            new paper.Point(x, roomRect.top),
                            new paper.Point(x, roomRect.bottom)
                        );
                        line.strokeColor = '#e0e0e0';
                        grid.addChild(line);
                    }
                    
                    for (var y = roomRect.top; y <= roomRect.bottom; y += size) {
                        var line = new paper.Path.Line(
                            new paper.Point(roomRect.left, y),
                            new paper.Point(roomRect.right, y)
                        );
                        line.strokeColor = '#e0e0e0';
                        grid.addChild(line);
                    }
                    
                    grid.sendToBack();
                }

                function isInsideRoom(item) {
                    if (roomWidth === 0 || roomLength === 0) return true;
                    
                    var roomBounds = new paper.Rectangle(50, 50, 
                        roomWidth * pixelsPerMeter, 
                        roomLength * pixelsPerMeter);
                    return roomBounds.contains(item.bounds);
                }

                function addTable() {
                    var table = new paper.Group();
                    var top = new paper.Path.Rectangle({
                        point: [100, 100],
                        size: [120, 60],
                        radius: 5
                    });
                    top.fillColor = '#90caf9';
                    top.strokeColor = '#1976d2';
                    table.addChild(top);
                    makeDraggable(table);
                }

                function addChair() {
                    var chair = new paper.Group();
                    var seat = new paper.Path.Rectangle({
                        point: [100, 100],
                        size: [40, 40],
                        radius: 3
                    });
                    seat.fillColor = '#80cbc4';
                    seat.strokeColor = '#00796b';
                    
                    var back = new paper.Path.Rectangle({
                        point: [100, 85],
                        size: [40, 15],
                        radius: 2
                    });
                    back.fillColor = '#80cbc4';
                    back.strokeColor = '#00796b';
                    
                    chair.addChildren([seat, back]);
                    makeDraggable(chair);
                }

                function addStorage() {
                    var storage = new paper.Group();
                    var cabinet = new paper.Path.Rectangle({
                        point: [100, 100],
                        size: [80, 120],
                        radius: 5
                    });
                    cabinet.fillColor = '#a5d6a7';
                    cabinet.strokeColor = '#388e3c';
                    storage.addChild(cabinet);
                    makeDraggable(storage);
                }

                function makeDraggable(item) {
                    var originalPosition;
                    
                    item.onMouseDown = function(event) {
                        originalPosition = item.position;
                    }
                    
                    item.onMouseDrag = function(event) {
                        this.position = this.position.add(event.delta);
                    }
                    
                    item.onMouseUp = function(event) {
                        if (!isInsideRoom(item)) {
                            item.position = originalPosition;
                        }
                    }
                }

                function clearCanvas() {
                    paper.project.activeLayer.removeChildren();
                    createRoom();
                    createGrid();
                }

                // Draw view
                paper.view.draw();
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
        title: const Text('Blueprint Designer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showDimensionsDialog,
            tooltip: 'Edit Room Dimensions',
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
