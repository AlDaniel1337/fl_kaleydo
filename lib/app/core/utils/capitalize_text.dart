
/// Capitaliza la primera letra de un texto.
String capitalizeText(String text) {
  if (text.isEmpty) return text;

  // Recorrer el texto y capitalizar la primera letra al comienzo del texto y después de cada espacio.

  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}