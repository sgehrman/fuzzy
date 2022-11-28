import 'package:fuzzy/bitap/bitap_pattern_alphabet.dart' as pa;
import 'package:fuzzy/bitap/bitap_regex_search.dart';
import 'package:fuzzy/bitap/bitap_search.dart';
import 'package:fuzzy/bitap/data/match_index.dart';
import 'package:fuzzy/bitap/data/match_score.dart';
import 'package:fuzzy/data/fuzzy_options.dart';
import 'package:normalizer/normalizer.dart';

/// The bitap algorithm (also known as the shift-or, shift-and or
/// Baeza-Yates–Gonnet algorithm) is an approximate string matching algorithm.
/// The algorithm tells whether a given text contains a substring which is
/// "approximately equal" to a given pattern, where approximate equality is
/// defined in terms of Levenshtein distance – if the substring and pattern are
/// within a given distance k of each other, then the algorithm considers them
/// equal. The algorithm begins by precomputing a set of bitmasks containing
/// one bit for each element of the pattern. Then it is able to do most of the
/// work with bitwise operations, which are extremely fast.
class Bitap {
  /// Instantiates a bitap, given options
  Bitap(String pattern, {required this.options}) {
    this.pattern = options.isCaseSensitive ? pattern : pattern.toLowerCase();
    this.pattern =
        options.shouldNormalize ? this.pattern.normalize() : this.pattern;
    if (pattern.length <= options.maxPatternLength) {
      patternAlphabet = pa.patternAlphabet(this.pattern);
    }
  }

  /// Configuration options
  final FuzzyOptions<dynamic> options;

  /// The pattern to search for
  late String pattern;

  /// The laphabet derived from the pattern
  Map<String, int> patternAlphabet = {};

  /// Executes a search, given a search string
  MatchScore search(String query) {
    String text = query;

    if (!options.isCaseSensitive) {
      text = text.toLowerCase();
    }
    if (options.shouldNormalize) {
      text = text.normalize();
    }

    // Exact match
    if (pattern == text) {
      return MatchScore(
        isMatch: true,
        score: 0,
        matchedIndices: [MatchIndex(0, text.length - 1)],
      );
    }

    // When pattern length is greater than the machine word length, just do a a regex comparison
    if (pattern.length > options.maxPatternLength) {
      return bitapRegexSearch(text, pattern, options.tokenSeparator);
    }

    // Otherwise, use Bitap algorithm
    return bitapSearch(
      text,
      pattern,
      patternAlphabet,
      location: options.location,
      distance: options.distance,
      threshold: options.threshold,
      findAllMatches: options.findAllMatches,
      minMatchCharLength: options.minMatchCharLength,
    );
  }

  @override
  String toString() => 'Bitap: $pattern, $patternAlphabet\noptions: $options';
}
