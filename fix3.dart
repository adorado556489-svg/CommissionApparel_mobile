import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var code = file.readAsStringSync();
  
  // Fix finalizeDirectOrders onPressed
  code = code.replaceFirst("onPressed: () {\n                final error = await OrderService.finalizeDirectOrders", "onPressed: () async {\n                final error = await OrderService.finalizeDirectOrders");
  
  // Fix archiveDirectOrderBatch onPressed
  code = code.replaceFirst("onPressed: () {\n                          await OrderService.archiveDirectOrderBatch", "onPressed: () async {\n                          await OrderService.archiveDirectOrderBatch");
  
  // Fix setState
  code = code.replaceAll("setState(() {});", "await _loadData();");
  
  // Replace ButtonBar with OverflowBar to fix deprecation warning
  code = code.replaceAll("ButtonBar(", "OverflowBar(");

  // Delete the extra brackets before _buildOrderRow
  var badStr = "      }\n    );\n  }\n\n  Widget _buildOrderRow";
  var badStr2 = "      }\n    );\n  }\r\n\r\n  Widget _buildOrderRow";
  var badStr3 = "    );\n  }\n      }\n    );\n  }\n\n  Widget _buildOrderRow";
  
  var idx = code.indexOf("  Widget _buildOrderRow");
  if (idx != -1) {
    var before = code.substring(0, idx);
    var after = code.substring(idx);
    
    // Actually, let's just strip everything after "      ],\n    );\n  }\n" and before "  Widget _buildOrderRow"
    // We know it should just end `_buildDirectOrdersTab` with `      ];\n    });\n  }\n\n  Widget _buildOrderRow`
    
    // Let's find "      ],\n    );\n  }"
    var pattern = RegExp(r"      \],\s*\n    \);\s*\n  \}\s*\}\s*\);\s*\}\s*Widget _buildOrderRow");
    if (pattern.hasMatch(code)) {
      code = code.replaceFirst(pattern, "      ],\n    );\n  });\n  }\n\n  Widget _buildOrderRow");
    } else {
       print("Pattern not found for buildDirectOrdersTab ending");
    }
  }

  file.writeAsStringSync(code);
}
