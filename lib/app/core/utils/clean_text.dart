
/// Limpia un texto eliminando mayúsculas, espacios al inicio y al final, guiones bajos al inicio y espacios internos.
/// Ejemplo:
/// cleanText("  _Hello World  ") -> "helloworld"
String cleanText(String text) {
  // Se pasa el string a lowercase
  text = text.toLowerCase();
  // Se eliminan los espacios en blanco al inicio y al final
  text = text.trim();
  // Se eliminan los guiones bajos al inicio del string
  text = text.replaceFirst(RegExp(r'^_+'), '');
  // Se eliminan los espacios
  text = text.replaceAll(' ', '');
  return text;
}