=begin comment

# each vowel-group indicates a syllable, except for:
#  final (silent) e
#  'ia' ind two syl 

# @AddSyl and @SubSyl list regexps to massage the basic count.
# Each match from @AddSyl adds 1 to the basic count, each @SubSyl match -1
# Keep in mind that when the regexps are checked, any final 'e' will have
# been removed, and all '\'' will have been removed.

=end comment

module Lingua::EN::Syllable;

my @SubSyl =
    / 'cial' /,
    / 'tia' /,
    / 'cius' /,
    / 'cious' /,
    / 'giu' /,              # belgium!
    / 'ion' /,
    / 'iou' /,
    / 'sia' $ /,
    / . 'ely' $ / ,             # absolutely! (but not ely!)
;

my @AddSyl =
    / 'ia' /,
    / 'riet' /,
    / 'dien' /,
    / 'iu' /,
    / 'io' /,
    / 'ii' /,
    / <[aeiouym]> 'bl' $/,     # -Vble, plus -mble
    / <[aeiou]> ** 3/,       # agreeable
    /^ 'mc' /,
    / 'ism' $ /,             # -isms
    / (<-[aeiouy]>) $0 'l' $/,  # middle twiddle battle bottle, etc.
    / <-[l]> lien/,         # alien, salient [1]
    / ^ 'coa' <[dglx]> . / ,      # [2]
    / <![gq]> 'ua' <![auieo]>/,  # i think this fixes more than it breaks
    / 'dnt' $/,           # couldn't
;


# (comments refer to titan's /usr/dict/words)
# [1] alien, salient, but not lien or ebbullient...
#     (those are the only 2 exceptions i found, there may be others)
# [2] exception for 7 words:
#     coadjutor coagulable coagulate coalesce coalescent coalition coaxial

sub syllable($word is copy) is export {
    my @scrugg;  # syllable chunks
    my $syl = 0; # syllable count

    $word = $word.lc;
    $word = $word.subst("'", "");       # fold contractions
    $word = $word.subst(/ 'e' $/ , ""); # remove trailing e

    @scrugg = $word.comb(/<[aeiouy]>+/);

    # special cases
    for @SubSyl -> $re {
        $syl-- if $word ~~ $re;
    }
    for @AddSyl -> $re {
        $syl++ if $word ~~ $re;
    }
    $syl++ if $word.chars==1;	# 'x'
    # count vowel groupings
    $syl += +@scrugg;
    $syl=1 if $syl==0; # got no vowels? ("the", "crwth")
    return $syl;
}
