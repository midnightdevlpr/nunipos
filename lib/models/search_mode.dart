enum SearchMode { all, barcode, code, name }

extension SearchModeHint on SearchMode {
  String get hintText {
    switch (this) {
      case SearchMode.all:
        return 'Search products by name, code or barcode';
      case SearchMode.barcode:
        return 'Search products by barcode';
      case SearchMode.code:
        return 'Search products by code';
      case SearchMode.name:
        return 'Search products by name';
    }
  }
}
