import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  // Fix the extra closing brace
  content = content.replaceFirst(
"""      ],
    );
  }
      }
    );
  }""",
"""      ],
    );
      }
    );
  }""");

  // Fix the async onPressed for finalize
  content = content.replaceFirst(
"""            child: ElevatedButton(
              onPressed: () {
                final error = await OrderService.finalizeDirectOrders""",
"""            child: ElevatedButton(
              onPressed: () async {
                final error = await OrderService.finalizeDirectOrders""");

  // Fix the async onPressed for archive
  content = content.replaceFirst(
"""                        label: const Text('Archive Batch'),
                        onPressed: () {
                          await OrderService.archiveDirectOrderBatch""",
"""                        label: const Text('Archive Batch'),
                        onPressed: () async {
                          await OrderService.archiveDirectOrderBatch""");

  file.writeAsStringSync(content);
}
