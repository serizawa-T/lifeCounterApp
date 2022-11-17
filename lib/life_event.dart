import 'package:objectbox/objectbox.dart';

@Entity()
class LifeEvent {
  int id = 0;
  String title;
  int count;

  LifeEvent({
    required this.title,
    required this.count,
  });
}
