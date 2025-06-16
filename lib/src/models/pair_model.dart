class PairModel {
  final String code;
  final String value;

  PairModel(this.code, this.value);

  @override
  List<Object> get props => [code, value];

  factory PairModel.fromJson(Map<String, dynamic> json) {
    return PairModel(json['code'] as String, json['value'] as String);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['value'] = value;
    return data;
  }
}
