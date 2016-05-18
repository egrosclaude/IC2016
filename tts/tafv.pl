#!/usr/bin/perl -w

# basado en Copyright 1997 Alistair Conkie, publicado en mbrola
# modificado 2004 Manuel Rodriguez Hourcadette
# See the readme.txt

# Usage: un programa para realizar conversión texto a voz, basado en base de datos vz1

# Change the paths here !!!
#$mbrola_cmd = "| /home/staff/amoret/docs/docs/mrodriguez/mbrola-linux-i386 /home/staff/amoret/docs/docs/mrodriguez/es1/es1 - | play -";
#$mbrola_cmd = "| /home/staff/amoret/docs/docs/mrodriguez/mbrola-linux-i386 /home/staff/amoret/docs/docs/mrodriguez/es1/es1 - test.wav";
$mbrola_cmd = ">test.pho";

%char_corrs = (
        "\341", "'a",
        "\351", "'e",
        "\355", "'i",
        "\363", "'o",
        "\372", "'u",
        "\374", '"u',
        "\361", "~n",
        "\301", "'A",
        "\311", "'E",
        "\315", "'I",
        "\323", "'O",
        "\332", "'U",
	"\321", "~N",

        ##### THERE ARE SEVERAL MISSING
        ## inverted ? 277
        ## inverted ! 241
);

# palabras que no llevan acento.
%fw = (
        'a', 'fw',
        'al', 'fw',
        'aun', 'fw',
        'vos', 'fw',
        'de', 'fw',
#        'dos', 'fw',
        'del', 'fw',
        'e', 'fw',
        'el', 'fw',
        'en', 'fw',
        'quien', 'fw',
        'con', 'fw',
        'cual', 'fw',
        'cuan', 'fw',
        'la', 'fw',
        'las', 'fw',
        'los', 'fw',
        'le', 'fw',
        'les', 'fw',
        'lo', 'fw',
        'mas', 'fw',
        'me', 'fw',
        'mi', 'fw',
        'mis', 'fw',
        'ni', 'fw',
        'no', 'fw',
        'nos', 'fw',
        'o', 'fw',
        'os', 'fw',
        'por', 'fw',
        'pos', 'fw',
        'pues', 'fw',
        'que', 'fw',
        'quien', 'fw',
        'se', 'fw',
        'si', 'fw',
        'sin', 'fw',
        'so', 'fw',
        'su', 'fw',
        'sus', 'fw',
        'te', 'fw',
        'tan', 'fw',
        'tu', 'fw',
        'tras', 'fw',
        'tus', 'fw',
        'u', 'fw',
        'un', 'fw',
        'y', 'fw',

        'ante', 'fw',
        'aunque', 'fw',
        'bajo', 'fw',
        'cabe', 'fw',
        'casi', 'fw',
        'cerca', 'fw',
        'como', 'fw',
        'contra', 'fw',
        'cuando', 'fw',
        'cuanto', 'fw',
        'desde', 'fw',
        'donde', 'fw',
        'entre', 'fw',
        'excepto', 'fw',
        'frente', 'fw',
        'hace', 'fw',
        'hacia', 'fw',
        'hasta', 'fw',
        'menos', 'fw',
        'mientras', 'fw',
        'para', 'fw',
        'pero', 'fw',
        'porque', 'fw',
        'puesto', 'fw',
        'que', 'fw',
        'salvo', 'fw',
        'segun', 'fw',
        'sino', 'fw',
        'sobre', 'fw',
        'una', 'fw',

);

%tosampa = (
        '#', '_',
        'a', 'a',
        'e', 'e',
        'i', 'i',
        'o', 'o',
        'u', 'u',
        'a:', 'a1',
        'e:', 'e1',
        'i:', 'i1',
        'o:', 'o1',
        'u:', 'u1',
        'j', 'j',
        'W', 'w',
        'w', 'w',
        'y', 'L',
        'c', 'tS',
        's', 's',
        's2', 's2',
        'z', 's',
        'p', 'p',
        'b', 'B',
        'B', 'b',
        'f', 'f',
        't', 't',
        'd', 'D',
        'D', 'd',
        'S', 'T',
        'k', 'k',
        'g', 'G',
        'G', 'g',
        'x', 'x',
        'm', 'm',
        'n', 'n',
        '~', 'J',
        'N', 'n',
        'M', 'm',
        'l', 'l',
        'L', 'L',
        'r', 'r',
        'R', 'rr',
);

# Duraciones básicas

%dur0 = (
        'a', '90',
        'e', '90',
        'i', '80',
        'o', '90',
        'u', '80',
        'a:', '108',
        'e:', '108',
        'i:', '96',
        'o:', '108',
        'u:', '96',
        'j', '60',
        'W', '60',
        'w', '45',
        'y', '90',
        'c', '135',
        's', '110',
        's2', '110',
        'z', '60',
        'p', '100',
        'b', '60',
        'B', '65',
        'f', '100',
        't', '85',
        'd', '60',
        'D', '65',
        'S', '100',
        'k', '100',
        'g', '50',
        'G', '80',
        'x', '130',
        'm', '70',
        'n', '80',
        '~', '110',
        'N', '50',
        'M', '50',
        'l', '80',
        'L', '105',
        'r', '50',
        'R', '80',
);

# Preparación - transformando algunas consonantes

open(RULES1,"venezuelan_rules1");
while(<RULES1>) {
        chop;
        if(($_ =~ /^\#/) || ($_ eq '')) {
                next;
        }
        @cons = split(' ',$_);
        if(@cons>1) {
                $svn{$cons[1]} = $cons[0];
        }
}
close(RULES1);

# Preparación - leyendo las reglas de fonetización

open(RULES2,"venezuelan_rules2");
while(<RULES2>) {
        chop;
        if(($_ =~ /^\#/) || ($_ eq '')) {
                next;
        }
        @bits = split(' ',$_);
        if(@bits>1) {
                $ts{$bits[1]} = $bits[0];
        }
}
close(RULES2);

# Se agregan acentos prosódicos y se separan sílabas

sub transcribe_word {
        local($i) = $_[0];
        local($t);
        local($w);
        ($tv,$rn,$w,$t) = find_cons('',$i);
	$i = $t;
       ($tv,$rn,$w,$t) = find_match('',$i);

        $t =~ s/_/ /g;

        # Efectos contextuales

        $t =~ s/^r/R/;
        $t =~ s/(\.|n|l|s) r/$1 R/;
        $t =~ s/i a /j a /;     #
        $t =~ s/i a$/j a/;
        $t =~ s/L[ ]?$/l/;      # 

        return($t);
}

sub find_cons {
        local($preword,$word) = @_;

        local($key,$newpreword,$newword,$w,$t,$tv);
        if($word eq '') {       # 
                return((1,'','',''));
        } else {
                foreach $key (reverse(sort(keys(%svn)))) {
                        if($word =~/^($key)(.*)/) {    
                                $newpreword ="$preword$1";
                                $newword = $2;
                                ($tv,$rn,$w,$t) = find_cons($newpreword,$newword);
                                if($tv eq 1) {
                                        $w = "$key$w";
                                        $t = "$svn{$key}$t";
                                        return(($tv,$rn,$w,$t));
                                }
                        }
                }
                return((0,'','',''));
        }
}

sub find_match {
        local($preword,$word) = @_;

        local($key,$newpreword,$newword,$w,$t,$tv);
        if($word eq '') {       # 
                return((1,'','',''));
        } else {
                foreach $key (reverse(sort(keys(%ts)))) {
                        if($word =~/^($key)(.*)/) {    
                                $newpreword ="$preword$1";
                                $newword = $2;
                                ($tv,$rn,$w,$t) = find_match($newpreword,$newword);
                                if($tv eq 1) {
                                        $w = "$key $w";
                                        $t = "$ts{$key} $t";
                                        return(($tv,$rn,$w,$t));
                                }
                        }
                }
                return((0,'','',''));
        }
}


sub use_synth {

        print MBROLA $_[0];
        if($FIN) {
	    close(MBROLA);
        }        
}


sub add_missing_stresses {
        local($phons) = $_[0];;

        @bits = split(/\|/,$phons);
        $found_stress = 0;

        foreach $bitphons (@bits) {

                if($bitphons =~ /:/) {
                        @phonlist = split(' ',$bitphons);
                        $found_stress = 1;
                }

                # first case   penultimate
                elsif($bitphons =~ /[aeiousn][ ]?$/) {
                        # it's much simpler to split
                        @phonlist = split(' ',$bitphons);

                        for($e=0;$e<=$#phonlist;$e++) {
                                if($phonlist[$e] =~ /^[aeiou]$/) {
                                        $remember = $e;  # a reference
                                        if(($e<=$#phonlist-2) && ($phonlist[$e+1] =~ /^[iu]$/)) {
                                                $look = $e+2;
                                        } elsif($e<=$#phonlist-1) {
                                                $look = $e+1;
                                        }
                                        while(($look<=$#phonlist) && ($phonlist[$look] !~ /^[aeiou]$/)) {
                                                $look++;
                                        }
                                        if(($look==$#phonlist) && ($phonlist[$look] =~ /^[aeiou]$/)) {
                                                $found_stress = 1;
                                                last;
                                        }
                                        elsif(($look==($#phonlist-1)) && ($phonlist[$look] =~ /^[aeiou]$/) && ($phonlist[$look+1] =~ /^[sn]$/
)) {
                                                $found_stress = 1;
                                                last;
                                        }
                                        elsif(($look==($#phonlist-2)) && ($phonlist[$look] =~ /^[aeiou]$/) && ($phonlist[$look+1] =~ /^i$/) && ($phonlist[$look+2] =~ /^s$/)) {
                                                $found_stress = 1;
                                                last;
                                        }
                                }
                        }
                        if($found_stress == 1) {
                                $phonlist[$remember] .= ":",
                        }

                # second case  final syll
                } 
                if($found_stress == 0) {
                        # it's much simpler to split
                        @phonlist = split(' ',$bitphons);
                        $e = $#phonlist;

                        if($e>=1) {
                                if(($phonlist[$e-1] =~ /[aeiou]/) && ($phonlist[$e] =~ /[aeiou]/)) {
                                        $phonlist[$e-1] .= ":",
                                }
                                elsif(($phonlist[$e-1] =~ /[aeioujW]/) && ($phonlist[$e] !~ /[aeiou]/)) {
                                        $phonlist[$e-1] .= ":",
                                }
                                elsif($e>=2) {
                                        if(($phonlist[$e-2] =~ /[aeiou]/) && ($phonlist[$e-1] !~ /[aeiou]/) && ($phonlist[$e] !~ /[aeiou]/)) 
{
                                                $phonlist[$e-2] .= ":",
                                        }
                                        elsif(($phonlist[$e-2] =~ /[aeiou]/) && ($phonlist[$e-1] =~ /[iu]/) && ($phonlist[$e] !~ /[aeiour]/))
 {
                                                $phonlist[$e-2] .= ":",
                                        }
                                }
                        }
                }
                $bitphons = join(' ',@phonlist);

        }

        $phons = join(" . ",@bits);

        return($phons);
}

### The start of the program itself ###
 
print STDERR "FreeSpeech-Venezolano (C) 1995 Alistair Conkie, 2004 Manuel Rodriguez H.\n";
print STDERR "There is ABSOLUTELY NO WARRANTY with this program.\n";
$FIN = 0;
$first = 1;
open(MBROLA,"$mbrola_cmd");
$buffer = '';           # assume has had \n->space
@sentencelist = ();
while($line = <>) {

        if($line eq "\n") {
                if($buffer !~ /^[ \t\n]*$/) {
                        push(@sentencelist,"$buffer");
                        $buffer = '';
                }
                print "@sentencelist";
		process_and_send_to_synth(@sentencelist);
                
                @sentencelist = ();
        } else {
#                chop($line);
		$line .= " ";
                @line = split(//,$line);
                foreach $i (@line) {
                        if($i =~ /[?\.!]/) {
                                # suspect a sentence
                                $buffer .= " $i";
                                $poss_sent = 1;
                        } elsif (($i eq "(") || ($i eq "{") || ($i eq "[")) {
                                $buffer .= " $i ";
                        } elsif (($i eq ")") || ($i eq "}") || ($i eq "]")) {
                                $buffer .= " $i ";
                        } elsif (($i =~ /[\241]/) || ($i =~ /[\277]/)) {   # inverted ! and ? resp
                                $buffer .= " $i ";
                        } elsif (($i eq ":") || ($i eq ";") || ($i eq ",")) {
                                $buffer .= " $i ";
                        } elsif (($i eq "\n") || ($i eq "\t") || ($i eq " ")) {
                                if($poss_sent eq 1) {
                                        if($buffer !~ /^[ \t\n]*$/) {
                                                push(@sentencelist,"$buffer");
                                                $buffer = '';
                                        }
                                        process_and_send_to_synth(@sentencelist);
                                        @sentencelist = ();
                                } else {
                                        $poss_sent = 0;
                                        $buffer .= ' ';
                                }
                        } elsif(defined($char_corrs{$i})) {
                                $buffer .= $char_corrs{$i};
                                $poss_sent = 0;
                        } else {
                                $buffer .= $i;
                                $poss_sent = 0;
                        }
                }
        }
}
# tidy up for EOF
if($buffer ne '') {
        push(@sentencelist,"$buffer");
}
$FIN = 1;
process_and_send_to_synth(@sentencelist);

sub process_and_send_to_synth {
        local(@sentences) = @_;
        local($xxxx_str);

        $xxxx_str = "";

        foreach $sent (@sentences) {
                @xxxx_data = process_sentence($sent);
                if($first) {
                        $xxxx_str .= join("\n",@xxxx_data);
                        $first = 0;
                } else {
                        $xxxx_str .= "\n" . join("\n",@xxxx_data);
                }
        }
        $LISTEN = 1;
        if($LISTEN) {
                use_synth($xxxx_str);
        }
}

sub process_sentence {
        local(@tokens) = split(' ',$_[0]);

        @tokens0 = treat(@tokens);
        @tokens1 = add_tags(@tokens0);
        @tokens2 = phrases(@tokens1);
        @tokens3 = transcribe(@tokens2);
        @tokens4 = conv(@tokens3);
        @tokens5 = massage(@tokens4);
        @tokens6 = prosody(@tokens5);
        @tokens7 = change_phonemes(@tokens6);
#	$DB::single=2;
        return(@tokens7);
}

sub token_type {
        local($look) = $_[0];

        if($look =~ /[A-Za-z0-9]/) {
                return('word');
        }
        return('punct');
}

sub add_tags {
        local(@data) = @_;
        local($out) = '';
        local(@out) = ();
        local($n) = 0;

        foreach $i (@data) {
                if((token_type($i)) eq 'word') {
                        if((function_word($i)) eq 'yes') {
                                $out = "$i/FW";
                        }else {
                                $out = "$i/CW";
                        }
                } else {
                        $out = "$i/PUNCT";
                }
                $out[$n++] = $out;
        }
        return(@out);
}

sub phrases {
        local(@data) = @_;
        local(@out) = ();

        for($i=0,$j=0;$i<$#data;$i++) {
                if(($data[$i] =~ /\/CW$/) && ($data[$i+1] =~ /\/FW$/)) {
                        $out[$j++] = $data[$i];
                        $out[$j++] = '/PUNCT';
                } else {
                        $out[$j++] = $data[$i];
                }
        }
        $out[$j++] = $data[$i];
        return(@out);
}

sub function_word {
        local($word) = $_[0];

        if(defined($fw{$word})) {
                return('yes');
        } else {
                return('no');
        }
}

sub transcribe {
        local(@input) = @_;
        local($word);
        local(@out) = ();
        local($trans);
        local($j) = 0;

        foreach $chunk (@input) {
                if($chunk =~ /(.*)\/CW/) {
                        $word = $1;
                        $trans = transcribe_word($word);
                        $trans = add_missing_stresses($trans);
                        $trans = syllabify($trans);
                        $out[$j++] = "$trans/CW";
                }
                elsif($chunk =~ /(.*)\/FW/) {
                        $word = $1;
                        $trans = transcribe_word($word);
                        $trans = syllabify($trans);

                        $out[$j++] = "$trans/FW";
                }
                else {
                        $out[$j++] = "$chunk";
                }
        }
        return(@out);
}

sub conv {
        local(@inlist) = @_;

        local(@outlist) = ();
        local($word) = '';
        local($j) = 0;
        local($syll_num) = 0;
        local($stress) = '';
	
	$outlist[$j++] = '# 50 H[<1.0>';
        foreach $word (@inlist) {
                if($word =~ /(.*)\/PUNCT/) {
                        $notes = $1;
                        $k = & last_vowel(@outlist);
                        if($notes eq '') {              # minor phrase boundary
                                $outlist[$k] .= "L-H]<0.2>";
                                # zero duration...
                        } else {                                # major phrase boundary
                                if($notes eq '-') {
                                        $outlist[$k] .= "L-H]<0.7>";
                                        $duration = 50;
                                }
                                elsif(($notes eq ':') || ($notes eq '-')) {
                                        $outlist[$k] .= "L-H]<0.7>";
                                        $duration = 250; #
                                }
                                elsif($notes eq ';') {
                                        $outlist[$k] .= "L-L]<0.7>";
                                        $duration = 250; #
                                }
                                elsif($notes eq '.') {
                                        $outlist[$k] .= "L-L]<1.0>";
                                        $duration = 250; #
                                }
                                elsif($notes eq '!') {          # not right
                                        $outlist[$k] .= "L-L]<1.0>";
                                        $duration = 250; #
                                }
                                elsif($notes eq '?') {          # not right
                                        $outlist[$k] .= "L-L]<1.0>";
                                        $duration = 250; #
                                }
                                elsif (($notes eq ',') || ($notes eq '(') || ($notes eq '[') ||
                                       ($notes eq '{') || ($notes eq ')') || ($notes eq ']') ||
                                       ($notes eq '}') || ($notes eq '"')) {
                                        $outlist[$k] .= "L-H]<0.7>";
                                        $duration = 200;
                                }
                                $outlist[$j++] = "# $duration";
                        }
                        next;
                }
                elsif($word =~ /(.*)\/CW/) {
                        $phonemes = $1;
                        $wordtype = 'CW';
                }
                elsif($word =~ /(.*)\/FW/) {
                        $phonemes = $1;
                        $wordtype = 'FW';
                }
                @phonemes = split(' ',$phonemes);
                foreach $ph (@phonemes) {
                        if($ph =~ /\-/) {
                                next;
                        }
                        if(defined($dur0{$ph})) {               # true phoneme
                                if($ph =~ /:$/) {
                                        $stress = "H*<0.5>";
                                }
                                $outlist[$j++] = "$ph $syll_num $stress";       # and maybe a sentence stress
                                $stress = '';
                        } elsif (($ph eq '+') || ($ph eq '-') || ($ph eq '.') || ($ph eq '|')) {
                                $syll_num += 1;
                        } else {
                                print "Something unknown: $j\n";
                        }
                }
                $syll_num += 1;
        }
        if(($j eq 1) || ($outlist[$j-1] !~ /^\#/)) {
                $outlist[$j] = '# 1000';
        }
        return(@outlist);
}

sub last_vowel{
        local(@phonemelist) = @_;
        local($i);
        local(@phoneme);

        for($i=$#phonemelist;$i>=0;$i--) {
                @phoneme = split(' ',$phonemelist[$i]); 
                if($phoneme[0] =~ /[aeiou]/) {
                        return($i);
                }
        }
        print "There is no vowel!!\n";
}

sub syllabify {
        local($phs) = $_[0];

        @phonlist = split(' ',$phs);
        local(@outlist) = ();


        # first van Gerwen rule
        for($e=0;$e<=$#phonlist;$e++) {
                if(($e > 0) && ($e <= $#phonlist-2)) {  # possibly wrong
                        if(($phonlist[$e] =~ /[bfgkpt]/) && ($phonlist[$e+1] eq "l")) {
                                push(@outlist,".");
                        } elsif(($phonlist[$e] =~ /[bdfgkpt]/) && ($phonlist[$e+1] eq "r")) {
                                push(@outlist,".");
                        }
                } 
                push(@outlist,$phonlist[$e]);
        }

        (@phonlist) = @outlist;
        @outlist = ();

        # second van Gerwen rule
        # paraphrasing
        #  if we have a consonant followed by a vowel, or h plus vowel AND
        #  the preceeding whatsits are not word boundary/syll boundary followed by a phoneme
        #  go for it

        for($e=0;$e<=$#phonlist;$e++) {
                $rightOK = 0;
                if(($phonlist[$e] !~  /^(a:|e:|i:|o:|u:|a|e|i|o|u|j|W|\.)$/) && defined($phonlist[$e+1])) {
                        if(($e<$#phonlist) && ($phonlist[$e+1] =~  /^(a:|e:|i:|o:|u:|a|e|i|o|u|j|W)$/)) {
                                $rightOK = 1;
                        } elsif  (defined($phonlist[$e+2])) { 
			    if (($e<$#phonlist-1) && ($phonlist[$e+1] eq "\-") && ($phonlist[$e+2] =~  /^(a:|e:|i:|o:|u:|a|e|i|o|u|j|W)$/)) {
                                $rightOK = 1;
			    }
                        }
                        if($rightOK) {
                                if(($e >= 2) && ($phonlist[$e-1] ne ".") && ($phonlist[$e-2] ne ".")) {
                                        push(@outlist,".");
                                }
                        }
                }
                push(@outlist,$phonlist[$e]);
        }


        (@phonlist) = @outlist;
        @outlist = ();

        # third van Gerwen rule
        # BE very careful about size of array
        if  (defined($phonlist[1])) { 
	        if (($phonlist[0] =~ /^(a:|e:|i:|o:|u:|a|e|i|o|u|)$/)  && ($phonlist[1] !~ /^(a:|e:|i:|o:|u:|a|e|i|o|u|)$/) && defined($phonlist[2])) {
		    if($phonlist[2] =~  /^(a:|e:|i:|o:|u:|a|e|i|o|u|j|W|)$/) {
                        $firsts = shift(@phonlist);
                        unshift(@phonlist,".");
                        unshift(@phonlist,$firsts);
                } elsif ( defined($phonlist[3])) {
                        if (($phonlist[2] eq "\-") && ($phonlist[3] =~  /^(a:|e:|i:|o:|u:|a|e|i|o|u|j|W|)$/)) {
                        $firsts = shift(@phonlist),
                        unshift(@phonlist,".");
                        unshift(@phonlist,$firsts);
		    }
		    }
                }
        }


        @outlist = ();

        # fourth van Gerwen rule
        for($e=0;$e<=$#phonlist;$e++) {
                push(@outlist,$phonlist[$e]);
                if(($phonlist[$e] =~ /[aeiou]/) && defined($phonlist[$e+1])) {
                        if($phonlist[$e+1] =~ /^(a:|e:|i:|o:|u:|a|e|o)$/) {
                                push(@outlist,".");
                        }
                }

        }

        return(join(' ',@outlist));
}

sub treat {     ## various bits of preprocessing -- everything that is in van Gerwen in the main rules
        local(@words) = @_;
        local($word);

        ### sub-, -mente, hyphens, TOlower
        ### stress additions

        foreach $word (@words) {
                $word =~ y/A-Z/a-z/;
                if($word =~ /.+\-.+/ ) {
                        $word =~ y/\-/|/;
                } elsif($word =~ /^sub(lev|lin|lun|ray|rei|rep|rog)/) {
                        $word =~ s/^sub/sub\-/;
                } elsif($word =~ /mente$/) {
                        if($word !~ /^(aumente|lamente|tormente)$/) {
                                $word =~ s/mente$/|mente/;
                        }
                } elsif($word =~ /^(va|ve|vi|da|di|fe|ha|he|no|ti|yo|ya)$/ ) {
                        $word =~ s/(.)(.)/$1\'$2/;
                } 
        }

        return(@words);
}

sub massage {
        local(@in) = @_;
        local(@out) = ();

        # now we are in a position, knowing the pauses, to do the assimilation.

        @phonss = ();
        @syllns = ();
        @pcomms = ();

        for($mi=0;$mi<=$#in;$mi++) {
                @fiddlybit = (split(' ',$in[$mi]),"");
                ($phonss[$mi],$syllns[$mi],$pcomms[$mi]) = ($fiddlybit[0],$fiddlybit[1],$fiddlybit[2]);
        }
        for($mi=0;$mi<=$#in;$mi++) {
                # lots of assimilations
                if($phonss[$mi] eq "b") {
                        if($mi==0) {
                                $phonss[$mi] = "B";
                        } elsif(($phonss[$mi-1] =~ /[mn\#]/) && ($syllns[$mi-1] != $syllns[$mi])) {
                                $phonss[$mi] = "B";
                        }
                }
                elsif($phonss[$mi] eq "g") {
                        if($mi==0) {
                                $phonss[$mi] = "G";
                        } elsif(($phonss[$mi-1] =~ /[mn\#]/) && ($syllns[$mi-1] != $syllns[$mi])) {
                                $phonss[$mi] = "G";
                        }
                }
                elsif($phonss[$mi] eq "d") {
                        if($mi==0) {
                                $phonss[$mi] = "D";
                        } elsif(($phonss[$mi-1] =~ /[mn\#]/) && ($syllns[$mi-1] != $syllns[$mi])) {
                                $phonss[$mi] = "D";
                        }
                }

        }
        for($mi=0;$mi<=$#in-2;$mi++) {
                if(($phonss[$mi] eq "k") && ($phonss[$mi+1] eq "s") && ($syllns[$mi+1] != $syllns[$mi+2])) {
                        $phonss[$mi] = "ELIMINATE";
                }
        }
#        for($mi=0;$mi<=$#in-1;$mi++) {
#                if(($phonss[$mi] eq "s") && ($phonss[$mi+1] eq "R") && ($syllns[$mi] != $syllns[$mi+1])) {
#                        $phonss[$mi] = "ELIMINATE";
#                }
#        }
        for($mi=0;$mi<=$#in-1;$mi++) {
                if(($phonss[$mi] eq $phonss[$mi+1]) && ($phonss[$mi] !~ /^(a:|e:|i:|o:|u:|a|e|i|o|u)$/)) {
                        $phonss[$mi] = "ELIMINATE";
                }
        }
#        for($mi=0;$mi<=$#in-1;$mi++) {
#                if(($phonss[$mi] eq "k") && ($syllns[$mi] != $syllns[$mi+1])) {
#                        $phonss[$mi] = "g";
#                }
#        }
#        for($mi=0;$mi<=$#in-2;$mi++) {
#                if(($phonss[$mi] eq "k") && ($phonss[$mi+1] eq "s") && ($syllns[$mi+1] != $syllns[$mi+2])) {
#                        $phonss[$mi] = "g";
#                }
#        }
#        for($mi=0;$mi<=$#in-1;$mi++) {
#                if(($phonss[$mi] eq "p") && ($syllns[$mi] != $syllns[$mi+1])) {
#                      $phonss[$mi] = "b";
#               }
#        }
        for($mi=0;$mi<=$#in-2;$mi++) {
                if(($phonss[$mi] eq "p") && ($phonss[$mi+1] eq "s") && ($syllns[$mi+1] != $syllns[$mi+2])) {
                        $phonss[$mi] = "b";
                }
        }
#        for($mi=0;$mi<=$#in-1;$mi++) {
#                if(($phonss[$mi] eq "t") && ($syllns[$mi] != $syllns[$mi+1])) {
#                        $phonss[$mi] = "d";
#                }
#       }
        for($mi=0;$mi<=$#in-2;$mi++) {
                if(($phonss[$mi] eq "t") && ($phonss[$mi+1] eq "s") && ($syllns[$mi+1] != $syllns[$mi+2])) {
                        $phonss[$mi] = "d";
                }
        }
        for($mi=0;$mi<=$#in-1;$mi++) {
                if(($phonss[$mi] eq "i")  && (($phonss[$mi-1] =~ /^(a:|e:|o:|u:|a|e|o)$/)  ||  ($phonss[$mi+1] =~ /^(a:|e:|o:|u:|a|e|o)$/))) {
                        $phonss[$mi] = "j";
                }
        }
        for($mi=0;$mi<=$#in-1;$mi++) {
                if(($phonss[$mi] eq "u")  && (($phonss[$mi-1] =~ /^(a:|e:|i:|o:|a|e|o)$/)  ||  ($phonss[$mi+1] =~ /^(a:|e:|i:|o:|a|e|o)$/))) {
                        $phonss[$mi] = "W
";
                }
        }
        for($mi=0;$mi<=$#in-1;$mi++) {
                if((($phonss[$mi] eq "s") || ($phonss[$mi] eq "S")) && ($syllns[$mi] != $syllns[$mi+1])) {
                        $phonss[$mi] = "s2";
                }
        }



        for($mi=0;$mi<=$#in;$mi++) {
                # do ELIMINATE
                if($phonss[$mi] ne "ELIMINATE") {
                        push(@out,join(' ',($phonss[$mi],$syllns[$mi],$pcomms[$mi])));
                }
        }

        return(@out);
}


sub snum {              # syllable number
        local($input) = $_[0];

        local(@input) = split(' ',$input);

        if($input[0] ne '#') {
                return($input[1]);
        } else {
                return(-1);
        }
}


sub prosody {
        local(@phonemelist) = @_;

        local(@spnlist) = ();
        local(@spnlistreserve) = ();
        local($curr_snum) = -1;         # just for starting off
        local($ref_snum) = -1;          # just for starting off

        for($i=0;$i<=$#phonemelist;$i++) {              # each time we find a symbol we make a curve
                @phoneme = split(' ',$phonemelist[$i]);
                $spnlist[$i] = "$phoneme[0]";
                $curr_snum = & snum($phonemelist[$i]);
                if($phoneme[0] ne '#') {
                        $spnlist[$i] .= "\t$dur0{$phoneme[0]}";
                } else {
                        $spnlist[$i] .= "\t$phoneme[1]";
                }
                # print STDERR "Duration: $duration[$i]\n";
                if($i eq 0) {
                        $spnlist[$i] .= "\t(0,120)";
                        next;
                }
                if($i eq $#phonemelist) {
                        $spnlist[$i] .= "\t(99,80)";
                        next;
                }
                # need to find max and min with same syllable number.
                if($curr_snum ne $ref_snum) {
                        $sos = $i;
                        $ref_snum = $curr_snum;
                }
                if($#phoneme eq 2) {
                        $fop = $i;
                        while(& snum($phonemelist[$fop]) eq $curr_snum) {
                                $fop++;
                        }
                        $fop--;         # we overshot slightly
                        if($phoneme[2] =~ /^H\*<(\d+\.\d+)>$/) {
                                $spnlist[$sos] .= "\t(0,100)";
                                $spnlist[$i] .= "\t(30,130)";
                        } elsif($phoneme[2] =~ /^H\[<(\d+\.\d+)>$/) {
                        } elsif($phoneme[2] =~ /^L-H\]<(\d+\.\d+)>$/) {
                                $spnlistreserve[$fop] .= "\t(90,100)";
                        } elsif($phoneme[2] =~ /^L-L\]<(\d+\.\d+)>$/) {
                                $spnlistreserve[$fop] .= "\t(99,80)";
                        } elsif($phoneme[2] =~ /^H\*<.\..>L-H\]<(\d+\.\d+)>$/) {
                                $spnlist[$sos] .= "\t(0,100)";
                                $spnlist[$i] .= "\t(30,130)";
                                $spnlist[$i] .= "\t(80,120)";
                                $spnlistreserve[$fop] .= "\t(99,100)";
                        } elsif($phoneme[2] =~ /^H\*<.\..>L-L\]<(\d+\.\d+)>$/) {
                                $spnlist[$sos] .= "\t(0,100)";
                                $spnlist[$i] .= "\t(30,130)";
                                $spnlist[$i] .= "\t(80,90)";
                                $spnlistreserve[$fop] .= "\t(99,80)";
                        } else {
                                print STDERR "Having a bit of trouble finding a suitable f0, mate!\n";
                        }
                }
        }

        for($i=0;$i<=$#spnlist;$i++) {
	    if (defined($spnlistreserve[$i])) {
                $spnlist[$i] .= $spnlistreserve[$i];
	    }
	}    
	    return(@spnlist);
}

sub interpolate {

        ## x1,y1,x2,y2,xx -> yy

        local($a,$b,$c,$d,$e) = @_;
        local($f);
 
        $f = ($c*$b + $d*$e - $e*$b -$a*$d)/($c-$a);
 
        return(int($f));
}


sub abs_targets {
        local(($cumdur,$index,$dur,@targs)) = @_;
        local($ta,$rval,$absx);
        local(@rval) = ();

        foreach $ta (@targs) {
                if($ta =~ /\(([0-9]+),([0-9]+)\)/) {
                        $perc = $1;
                        $absy = $2;
                } else {
                        print "Problem with target\n";
                }
                $absx =  $cumdur + int($perc*$dur/100);
                push(@rval,join(' ',$index,$absx,$absy,$perc));
        }
        return(@rval);
}

sub change_phonemes {
        local(@llist) = @_;

        foreach $l (@llist) {

                @pline = split(' ',$l);
                $pline[0] = $tosampa{$pline[0]};
                $pline[0] =~ s/1/*/;
                $pline[0] =~ s/x/h/;
                $pline[0] =~ s/T/s/;


                $l = join("\t",@pline);
                $l =~ s/\(/ /g;
                $l =~ s/\)/ /g;
                $l =~ s/,/ /g;

        }

        @llist;
}

 
