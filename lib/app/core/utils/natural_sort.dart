
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

/// Ordena una lista de elementos utilizando un orden natural basado en los números dentro de los nombres de archivo.
List<T> naturalSort<T>(List<T> list) {
  final sortedList = List<T>.from(list);
  final regExp = RegExp(r'(\d+|\D+)');

  sortedList.sort((a, b) {
    final nameA = a.toString().split('/').last;
    final nameB = b.toString().split('/').last;

    final matchesA = regExp.allMatches(nameA).map((m) => m.group(0)!).toList();
    final matchesB = regExp.allMatches(nameB).map((m) => m.group(0)!).toList();

    final minLength = matchesA.length < matchesB.length ? matchesA.length : matchesB.length;

    for (var i = 0; i < minLength; i++) {
      final partA = matchesA[i];
      final partB = matchesB[i];

      if (partA != partB) {
        final numA = int.tryParse(partA);
        final numB = int.tryParse(partB);

        if (numA != null && numB != null) {
          return numA.compareTo(numB);
        }
        return partA.compareTo(partB);
      }
    }

    return matchesA.length.compareTo(matchesB.length);
  });

  return sortedList;
}