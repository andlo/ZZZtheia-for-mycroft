#!/bin/sh
# This script was generated using Makeself 2.4.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="2618048150"
MD5="b191bafea8a7d3be9b4cec42a5673f12"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="THEIA IDE for Mycroft"
script="./auto_run.sh"
scriptargs=""
licensetxt=""
helpheader=''
targetdir="."
filesizes="2740"
keep="y"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    echo "$licensetxt" | more
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd $@
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet		Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n 588 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" = x"$crc"; then
				test x"$verb" = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 32 KB
	echo Compression: gzip
	echo Date of packaging: Sat Nov 17 22:54:49 UTC 2018
	echo Built with Makeself version 2.4.0 on 
	echo Build command was: "../makeself-2.4.0/makeself.sh \\
    \"--current\" \\
    \"./theia-for-mycroft\" \\
    \"theia-for-mycroft.sh\" \\
    \"THEIA IDE for Mycroft\" \\
    \"./auto_run.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"y" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\".\"
	echo KEEP=y
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=32
	echo OLDSKIP=589
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 588 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 588 "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n 588 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 32 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
	MS_Printf "Uncompressing $label"
	
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = xy; then
	    echo
	fi
fi
res=3
if test x"$keep" = xn; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf "$tmpdir"; eval $finish; exit 15' 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 32; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (32 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test x"$keep" = xn; then
    cd "$TMPROOT"
    /bin/rm -rf "$tmpdir"
fi
eval $finish; exit $res
‹ 9œğ[íZësÛ6÷gş8%×&™%Ùê(ÇÌ¹šøÆí´½ú<Š„$Ä$Á@=œæ¿]"¡øûƒ“»+7ë‡ÅîâÉå.Çİztjõ··ñ×ëo·Íß5myİn¿×Şîïì ¿ßî¶·ÈöÖW \ª@²•±»å¾Tÿ?JËR˜8väì­½XÏÛîw@ÎóÚ½-ÒnÖÿÑéÉ_Ü1Kİq g–Fäé³ˆ‰4H(i=m·[Ö“'doFÃK2á‚L¥2BJ‚4"lBhÊóé~BAI‰\Ù„ÅˆØµjy-OˆCş Áâ’|tâû™`©"O{®×î>}ÿÜ»çäéÇJù¯Î‹OäµOzäâQ3šZHÒˆØŒØĞSéîı4:ıu÷çÓıß‡¾×n_ã€ıq©
İ(›­¤]ö”j[šÏR¦œè³j"Ï¾,eMÌ9NÉa .Gö”L˜ xºHJi$‰âdL	Ïh£´'ÄÍ¥p%.B>YlŒP28Á
0Â° <¹_¡%üÉ¸P¤É
³¢OHù\£9Ø,‚5“$—TŒYÚ,Î^%Xšl=wµä¨öÅâÃÂªb½%UyÅœ…Ô¢áŒ“ó÷0!ä5qc6våJ*šDå¯[µìlè¼¡2,SŒ§şŠı7CòúõLìN~’ÇŠÙ8$`JyHGÎO‹ÒÅõÎVõ%K2Xú‡i—4<ÅÍâoL¹ÈS˜î‡MÁ	Õ»Îç©Œq<Hû=”|Xù)Ó9<Mhª~‚m¿1-MÓùÃ,ï›íâaj¿©¢Ñ«wÀıìXá,áÙéõî¹~EE¨b4Y4æAdğiŒaGÜ¥ª—ì	|ĞxJ’ÚqÌ©ğ€>!S¦Ó¾ƒÇÑK"¹v&Xy’¡ÿÑÎ¸|ÜSº€Gœ§Tû€Ii³ô©ÏĞ–m¯ÿæPŒZ¤¨®¹,;Xö“ıt7<ÒÃ­t´Ï»æØ‚LÙ¸`öªêz4³ƒ\qACN¬J˜‹¸gOÓ\ÅÒèyt™ÊÓ%PWt©{µ®–2FX5ƒ]c˜D×…¿Î%).¦n–ÃÒ‡	²uü¯Támh“à’ì›æ‚VlÇ­x0'™ ¶ôÑ§o(nZ)¬™à­Ñaë}İ:{7ÜßÕîß¶‡«Pğ‰^üR–×üEÊÒ©Ó*Õ¦wÃL©FøôÙŒK…¯ğçıfÀWER)õÆã-ËŒÿà{L©óAòôñâ?xĞn‹ÿ¼^·§ã¿î×ñúŒÿº^§‰ÿ¾}„MØ‚0l/ùÖ€(‘Ó—ÈŠ()×1*ÿQïÕ–‚7_ñò^+©Z/‹º¿k·æŞC$ælÀƒ~»*–ñ­\K©=gtq«>ŒTÀôn–Ià¹€İ» ¸€[ë0ø³%D8»½ğ¿à(ïêäƒá±Ÿ1*°‘ÕÃ€·Ÿ(f¡º½µ¢³6Kí—:º¾UÂ+´T	TØS$0Æ;¸R³;AÜŠ¾éÖz1Ø)…m‘[Ç¹=|oTÃÈ|*·óüÍ;z=Ë1ûLÍúdmı	ÈÙA¿Işïu;^™ÿ·ÛÛíÿñü§ñÿ_7ÿ¿%ı×!‹Äø¦ŒDÑu@øaA(†‰ÇÁñŞîÁèíşÙèÍşÉpïìøäŸ~# ÖZë†¿÷F?ï½+êtĞöÀg	ÚÒí@Z‘«3‡,‹ûHMu T§Ê3P7cnRDFZÙÕzA¨ô‹lóœ€ç"¤÷ÖÅhìzäŒóL¹(.7M|±á{è­sö"ÃÆs’Î“õırˆÓë·¾;>ºTµ,è—„…*ë\àÁ3Ü"ä»ïÈ¿œjÈr6ƒDëR›ÿÌîƒ¦1Åüü&[×D®%Ÿ‰è¡ƒ©kˆ²XæDz–Êùqå%‹cI Ö•yf+–Pi…Ìu|KÚş‡q÷úäOá´Áÿ?æ)ğıÿ÷<¯Ó‡wAÓ€æü÷¿Áÿ?Ñ<<æi\4¸h< 6·u®-!ÙÁÏfù¡ JU0E¸>ÄÑù±%z_H$Lñ±…üAŠC÷ÿÌõ1ÎVšÕ%{JĞÙ[Úå›~œ³8²¬õ„g,«tŠ”ÁƒtšCrfã10ıX—Çfb@ÊI3yVó*¸¿ÿ_ß~‹ópÿkç?;ıÆÿ:8íŸœúBúíAÄü¶÷ªÛÄ©;ƒdæ·ÛƒŒù½ö«nw ¹æo¢5GEÕ«¶7Ì…Æâ„¡™ûİş«7S¿Û~ÕëÂ@o t@TZ¸7 KİPgğÏø5öO¯*ˆĞÀj™ –‰gA¯z8©…T\+«¥¯xû5ÿŠe5®ĞïŠj¦ÑõXØ„u#FÛW0+u?ŒÂøªcàZfwåº_t\a‘%ş`LöÂÀÔÀÒÀÂÀ1” ¤uÿy=¬0cuÁ˜GcBÂ îÚ‡lZn8Ä´.$fM²Q5e“
“¬ÂÙ8©ñÔÀYÕ4¨ğÒ_š2†}Àu!KëNÈù¾ªûjeá²æóyÍ±mŒºc]ÖxA¾rclIÖ«qÏlÁ(Ìù¸ÂÿVLs£¤Æ¬‡,Îk3“8¬åçÌà›¸¶9+ÕpÖ--Q…WFÏBc´4™³07p=ÏA =k£œWpü¤Ô˜E&fuáÒÊº®ñé´Â¢_sC¤æó,—UAfË
/e6)ÖÁîÑ[Ÿ¦£·?:ïÏ~²°ŞŸOüŒYùëhÚ:şvöæøpwÿÈ?`i¾´Ş=´ xà»ó@@dÊb;}7< V•œOı%ÄÛíÇ\€ÌÁ/~Ç:8~{´m€š>Ò©"wĞÇ;<b}­Á,WÅºBƒ¢ø™ğÒY0J¸ÑÊÉÔX#mØÅ<¥‰ñîÿÌ˜ùÛ|ÿëô¼*şëtzÿõ¼í&şû*ù?êõß+ò(Èò‚•ğhª×ÀæxËIñÌN¸T›Úú>•à\_IDÉ÷ÛR­bŠWğ£$È˜I°.šF,
9Şª°qşâÂîˆOFZÂ'ñÄ‚ì
5šà‡ÁÑZ·nè0PáŒë;!x5-•mŞAÃ«©¾²r¥“sP;¥ŠDt€	gTAóÎÇòe¶úta•<h(Wğ± Ò#Å6†Ÿ“JC ’­.¬‚5*Æër“]!¯‡&Î‚±©N¥\ß˜²	£Ñsëü0¸¤8ˆkfU0F#û†“'ğ’^Àú§$‡z—"HÄaVÖ9»¿€JŞ«³sfñú ]¡*§–ÂÔâu2ãÖ%àE/U[çÍÚ—FÕ§{¶ß¸èGöÿxåæQ?ÿ}ñş··]æÿı¾×i£ÿïxMşÿÕÏ‹ËDGåå²1á5@´;‡¢¾â[ßğ¥ú½v+TRé8N«¸_jŞ-oNãj¨¡†j¨¡†j¨¡†j¨¡†j¨¡†j¨¡†j¨¡†jèñè?©Wş\ P  