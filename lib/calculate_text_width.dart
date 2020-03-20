import 'dart:ui' as ui;

double CalculateTextWidth(String text){
  var builder = ui.ParagraphBuilder(ui.ParagraphStyle());
  builder.pushStyle(ui.TextStyle());
  builder.addText(text);
  var paragraph = builder.build();
  paragraph.layout(ui.ParagraphConstraints(width: 0));
  return paragraph.maxIntrinsicWidth;
}