enum AlcoholType {
  alcoholic,
  nonAlcoholic,
  optional;

  static AlcoholType fromApi(String? value) {
    switch (value) {
      case 'Alcoholic':
        return AlcoholType.alcoholic;
      case 'Non alcoholic':
        return AlcoholType.nonAlcoholic;
      default:
        return AlcoholType.optional;
    }
  }

  String get label {
    switch (this) {
      case AlcoholType.alcoholic:
        return 'alcoholic';
      case AlcoholType.nonAlcoholic:
        return 'non-alcoholic';
      case AlcoholType.optional:
        return 'optional';
    }
  }
}
