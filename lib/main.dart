import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/bootstrap.dart';

Future<void> main(List<String> args) async {
  await bootstrap(
    (weatherRepository) => App(weatherRepository: weatherRepository),
  );
}
