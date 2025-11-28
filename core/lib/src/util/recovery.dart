import 'package:studyu_core/src/util/wordlists.dart';

class EncodingConfig {
  final int bitsPerWord;
  final bool useChecksum;

  const EncodingConfig({this.bitsPerWord = 11, this.useChecksum = true});

  int wordsNeeded(int bitCount) {
    return (bitCount / bitsPerWord).ceil();
  }
}

List<int> encodeIdToIndices(
  BigInt participantId,
  int bitCount,
  EncodingConfig config,
) {
  if (participantId < BigInt.zero ||
      participantId >= (BigInt.one << bitCount)) {
    throw ArgumentError('ID must fit within $bitCount bits');
  }

  final numWords = config.wordsNeeded(bitCount);
  final mask = (1 << config.bitsPerWord) - 1;
  final indices = <int>[];

  BigInt remaining = participantId;
  for (int i = 0; i < numWords; i++) {
    final index = (remaining & BigInt.from(mask)).toInt();
    indices.insert(0, index);
    remaining = remaining >> config.bitsPerWord;
  }

  return indices;
}

BigInt decodeFromWords(
  List<String> words,
  List<String> wordlist,
  EncodingConfig config,
) {
  BigInt participantId = BigInt.zero;

  for (final word in words) {
    final index = wordlist.indexOf(word);
    if (index == -1) {
      throw ArgumentError('Invalid word: $word');
    }
    participantId = (participantId << config.bitsPerWord) | BigInt.from(index);
  }

  return participantId;
}

int computeChecksum(List<int> indices, int wordlistSize) {
  if (indices.isEmpty) {
    throw ArgumentError('Need at least one word index');
  }

  const primes = [31, 37, 41, 43, 47, 53];

  int hash = 0;
  for (int i = 0; i < indices.length; i++) {
    final prime = primes[i % primes.length];
    hash ^= indices[i] * prime;
  }

  return hash % wordlistSize;
}

List<String> encode(
  BigInt participantId, {
  List<String>? wordlist,
  int bitCount = 64,
  EncodingConfig config = const EncodingConfig(),
}) {
  final effectiveWordlist = wordlist ?? WORDLIST_EN;

  if (effectiveWordlist.length < (1 << config.bitsPerWord)) {
    throw ArgumentError(
      'Wordlist must have at least ${1 << config.bitsPerWord} words',
    );
  }

  final indices = encodeIdToIndices(participantId, bitCount, config);

  if (config.useChecksum) {
    final checksumIndex = computeChecksum(indices, effectiveWordlist.length);
    indices.add(checksumIndex);
  }

  return indices.map((i) => effectiveWordlist[i]).toList();
}

BigInt decode(
  List<String> words, {
  List<String>? wordlist,
  EncodingConfig config = const EncodingConfig(),
}) {
  if (words.isEmpty) {
    throw ArgumentError('Must provide at least one word');
  }

  final effectiveWordlist = wordlist ?? WORDLIST_EN;

  List<String> dataWords = words;

  if (config.useChecksum) {
    if (words.length < 2) {
      throw ArgumentError('Need at least 2 words when using checksum');
    }

    dataWords = words.sublist(0, words.length - 1);
    final indices = dataWords.map((w) {
      final idx = effectiveWordlist.indexOf(w);
      if (idx == -1) throw ArgumentError('Invalid word: $w');
      return idx;
    }).toList();

    final expectedChecksum = computeChecksum(indices, effectiveWordlist.length);
    final actualChecksum = effectiveWordlist.indexOf(words.last);

    if (actualChecksum == -1) {
      throw ArgumentError('Invalid checksum word: ${words.last}');
    }

    if (expectedChecksum != actualChecksum) {
      throw ArgumentError(
        'Checksum mismatch: expected ${effectiveWordlist[expectedChecksum]}, '
        'got ${words.last}',
      );
    }
  }

  return decodeFromWords(dataWords, effectiveWordlist, config);
}
