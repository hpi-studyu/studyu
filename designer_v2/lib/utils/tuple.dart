import 'package:equatable/equatable.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

class Tuple<T1, T2> extends Equatable {
  final T1 first;
  final T2 second;

  const Tuple(this.first, this.second);

  @override
  List<Object?> get props => [first, second];

  JsonMap toJson() => {
        "_tuple.0": first,
        "_tuple.1": second,
      };

  static Tuple fromJson(JsonMap json) => Tuple(
        json["_tuple.0"],
        json["_tuple.1"],
      );

  Tuple<T1, T2> copy() {
    return copyWith();
  }

  Tuple<T1, T2> copyWith({T1? first, T2? second}) {
    return Tuple(
      first ?? this.first,
      second ?? this.second,
    );
  }
}
