// The admin panel's search scheme (src/search.js): lowercase words of 2 or
// more letters or digits, cut to 15. "Sit-Up" -> sit, up
const _minWord = 2;
const _maxWord = 15;

List<String> searchWords(String text) => text
    .toLowerCase()
    .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
    .where((w) => w.length >= _minWord)
    .map((w) => w.length > _maxWord ? w.substring(0, _maxWord) : w)
    .toList();
