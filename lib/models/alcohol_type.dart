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
}