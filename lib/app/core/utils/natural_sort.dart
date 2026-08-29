
/// Compara dos cadenas de texto utilizando un orden natural.
// Esto significa que los números dentro de las cadenas se comparan
// numéricamente en lugar de lexicográficamente.
int naturalSortCompare(String a, String b) {
  final regExp = RegExp(r'(\d+)|(\D+)');
  final matchesA = regExp.allMatches(a).toList();
  final matchesB = regExp.allMatches(b).toList();

  for (int i = 0; i < matchesA.length && i < matchesB.length; i++) {
    final String tokenA = matchesA[i].group(0)!;
    final String tokenB = matchesB[i].group(0)!;

    final int? numA = int.tryParse(tokenA);
    final int? numB = int.tryParse(tokenB);

    if (numA != null && numB != null) {
      final int comp = numA.compareTo(numB);
      if (comp != 0) return comp;
    } else {
      final int comp = tokenA.toLowerCase().compareTo(tokenB.toLowerCase());
      if (comp != 0) return comp;
    }
  }

  return matchesA.length.compareTo(matchesB.length);
}