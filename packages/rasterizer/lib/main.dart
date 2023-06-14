import 'dart:io';
import 'dart:ui';

import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;

Future<void> generate(
  File svgFile,
  File outputFile, {
  Size desiredSize = const Size(64, 64),
}) async {
  final pr = PictureRecorder();
  final canvas = Canvas(pr);

  final svgFileLoader = SvgFileLoader(svgFile);

  final pic = await vg.loadPicture(svgFileLoader, null);

  canvas.scale(
    desiredSize.width / pic.size.width,
    desiredSize.height / pic.size.height,
  );
  canvas.drawPicture(pic.picture);

  final picture = pr.endRecording();
  final image = await picture.toImage(
    desiredSize.width.floor(),
    desiredSize.width.floor(),
  );

  final bytes = await image
      .toByteData(format: ImageByteFormat.png)
      .then((value) => value?.buffer.asUint8List());

  return outputFile
      .create(recursive: true)
      .then((value) => value.writeAsBytes(bytes!));
}

Future<void> main(List<String> args) async {
  const outputPath = '../../docs/icons';
  const svgPath = '../../modules/MaterialDesign-SVG/svg';

  final generationFutures = MdiIcons.values.map(
    (icon) => generate(
      File(path.join(svgPath, '${icon.metadata.name}.svg')),
      File(
        path.join(
          outputPath,
          icon.metadata.name,
          icon.metadata.version,
          '64.png',
        ),
      ),
    ),
  );

  await Future.wait(generationFutures);

  exit(0);
}
