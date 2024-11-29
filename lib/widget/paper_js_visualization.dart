import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaperJsVisualization extends StatefulWidget {
  const PaperJsVisualization({super.key});

  @override
  State<PaperJsVisualization> createState() => _PaperJsVisualizationState();
}

class _PaperJsVisualizationState extends State<PaperJsVisualization> {
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
            </style>
        </head>
        <body>
            <canvas id="myCanvas" resize></canvas>
            <div id="toolbar">
                <button onclick="addTable()">Add Table</button>
                <button onclick="addChair()">Add Chair</button>
                <button onclick="addStorage()">Add Storage</button>
                <button onclick="clearCanvas()">Clear</button>
            </div>
            <script type="text/javascript">
                // Initialize Paper.js
                paper.setup('myCanvas');
                
                // Create grid
                function createGrid(size = 20) {
                    var grid = new paper.Group();
                    
                    for (var x = 0; x < paper.view.size.width; x += size) {
                        var line = new paper.Path.Line(
                            new paper.Point(x, 0),
                            new paper.Point(x, paper.view.size.height)
                        );
                        line.strokeColor = '#e0e0e0';
                        grid.addChild(line);
                    }
                    
                    for (var y = 0; y < paper.view.size.height; y += size) {
                        var line = new paper.Path.Line(
                            new paper.Point(0, y),
                            new paper.Point(paper.view.size.width, y)
                        );
                        line.strokeColor = '#e0e0e0';
                        grid.addChild(line);
                    }
                    
                    grid.sendToBack();
                }

                // Create furniture items
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
                    item.onMouseDrag = function(event) {
                        this.position = this.position.add(event.delta);
                    }
                }

                function clearCanvas() {
                    paper.project.activeLayer.removeChildren();
                    createGrid();
                }

                // Initialize grid
                createGrid();
                
                // Draw view
                paper.view.draw();
            </script>
        </body>
        </html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blueprint Designer'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}