#!/bin/sh
# This script was generated using Makeself 2.4.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="633753675"
MD5="ee5934b391c223486de6046a31ea7d02"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="THEIA IDE for Mycroft"
script="./auto_run.sh"
scriptargs=""
licensetxt=""
helpheader=''
targetdir="."
filesizes="2970"
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
	echo Date of packaging: Sun Nov 18 20:34:50 UTC 2018
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
‹ ëÌñ[íksÛ6ÒŸù+P9×&™Põ°;Ê1s®ã^|cÇ™Ø}\}E‚b’`P§ùï·R$[~Ì]’vÂõŒ½ v‹Årà¶³õÉ¡°;à_wwĞ1ÿ®`Ëíõvû½şNw°õ»^o‹¶>äRù‚­ŒİNwWû_ÚKÁqÜ–Ó/4ÿƒ~wg5ÿƒİ¾»ÕqİN¿¿E:ÍürØşÆ³Ôûrj!yô8d"õJZ:­'–Eƒ)×¿Hë°p–NÈÙ«ƒÃ=røò€D\ãe x¤Z%İÙ”I2gqL”I‰OæSSâˆâ¤×!	KÛ$¤MC”ÅS²ä¹ S_„s_Ğ69å$‹©/)S’ùŠÑ„[ÛÛdJƒKİg$(•™€ü4$,"4åùd
¡YåÜÏ"#Æ®h©ÚAÑŠİb;¶ /STíd‚_@Ëª;ğĞ*i“?ˆ?¿$ß½~ëyİ÷™`©"úÛé¿>|÷ÄaçäÑûŠùoí§ÈôÉÅs¢¦4µ€¤!±±ÁÊÒÙ?yıãèô—½7§‡¿xn§s­ä·ˆCUà„Ùt)írhTËÒõ,eª~ÔL¤âyá„tæ¤9LG·Æïfõ…ÚÄ1˜r’’c_\\‰˜ s0I)µ-aî8Îqa;"N.…#ÑÛòh¾f„b‚N€g'ãĞ}‚ai%æ…´*™‡œ $hásp€/,±küSKÈ‡:d…âÛ¤ŒxØ?óm‚I’K*HÆnğu¤"@¥İB÷Šs—18F6Ÿ8ZĞ¨¤…¯‚§©Â=%Uy¿ÅŒ+WÔÍ(¿Ò¢]è~4ÑùO09äqb6väR*š„å_ç_Áó’Ê@°L1z…êø™¾xñ {‘¢ÂKòX1ÍÒg˜Pp‡)r~Z”.Èw¶Ì¨'Y!àœœ¢ãzkó"òæäa&xKõàñÔöÇèIâş	J¸Ç}™¶õÓ<M ÚıßàÚ 49MgÓã¼tã‹‡±ıâ§Š†?,otûÉ±‚iÂC²Óïßs‹†@Å$ôif4æ~hÔÓÔƒKlĞ¹¥'~ó÷TË)BÛ*Ã7kQRÇ´>#Â#2©–‡Ïˆä:Îa9àI†S/Ce`Ié‚	O©6Q)³\£,Û^	ÿ#È¡¶HbdÖ˜²ÜÆ²û„üçï¤·,.¥«¥¸î†˜»Wê[w²® ¿çTĞğ›ÖG,FxÔyÀ¨Ôf^‘ù™²Ñ_ìee”pjû¹â‚<8E‹¸oOÒ\ÅÒ†ÅëèÖ{W—€]Ñ…ÂÚ«U³”±FoYÔj%÷c®×Ìšn8¸ Ú(bCÇÁöK*R·¹˜8Yî$X­›üş`ãTw¯ã&Ü¡Ø$ô.ám§&µíLĞˆ-<\KïbÔİÜËRÆtŞ¨ëj
ï6C»]•DBlQÙ–Şrõİ‡­]šg´{ø¢ŒÑX¼¾–[Ğ÷è©%=|’ø‚4œùÕ2ÚšpüR§Je0İO¹T¸Ç}2ÔûÜ0•Rô ¼em}5Ğv`›zéOhûäé§Ëÿ`%Ø”ÿ¹÷éü¯·ãvİİ.æ=·ÛäŸŞÃ×Ù‚\f{ÕÖ(‘ÓgXUägEd‡ú÷ú#n)Ø›ÛK¨kÅÀ#UëYÑöıå:÷ Iı›ø°lBd‰~¼‘€Ã¢ÁRjÏo$ÂX	ËWè!ÜL“ÀwŞ¿™ ØÆ6L•lI}L7w k?,¬·)yë kSFv²¼e°=³q¡ˆY 6÷V(k³Ôsq©SÔ´n™¡…J Á?1Ş2À¥šŞ"²3Œ½ÛiÈÀSŠ%°E6ÒX{,øvs†( ùPºóìå½²rÌ>b³>X_Gü7“¤/rşçö!Øëó¿îÎ ëêó¿^¯9ÿûSœÿÁ†Mo%n?Ë´ Cl¯,Ø¬cj|t²¿w4úçáÙèåáÛƒı³“·ÿöZ¸Am­(°íà×ƒıÑ›½³WE›Î
AÄ,A‹Ã=È{!iÏ ÍÅâaD2¦7xõ	Ò”'ÔÉ˜“;?Íìh=
?Pz![?lã¹è½y5O©w¡î£W'ÇH3,°5ºéZ¸¿½î¡Ö<Sö#¯±Ş®ñ=øV›êâ„	÷¾˜5“t–¬lÿúçcœ—Õ0ÚĞÔ²@/	3\¶9P‹\o¿%ÿißĞB¶‰>ÖEéR‹ÿH:Ğsá˜âÑÓM²®‘\J>"ÑCƒÈTgëÖÒe±Läµ•Jû8ò’Å±$'éÆ<³K(Ç\Ø…ÊÕÆŸtÚúó©Õ1áW´ç¿)şÊ[ ;â×íÖïÿÜ.Ô5ñÿOÿ·uC6!ú	Ñ×ÎY0°â9‚›ÛútBGøs<ršæc<w…}¯£·!&:¾1à)[`X†ÄBÂd×·ä?7ÒüŸ„›{ù4ëÄ=ûº¾|¬Ì®äÊì¼¼ÇAòÕ±Ö÷›L¶6kš—Ÿ‚?«ùí¢~³áµ˜r‡Õµr—±Ğ‘óé†k½Ñ	9òÓI©-Á{ÈŠ¬•‡f,«T/’3;.im©i7ödxñU^L˜™)É¬³¾Ò%õ¯¸ş¯î—¾Äù_2À2ÿ@¡£ó¿A³ş8:íŸ¼=õ„ô:Ãy÷y¯?ŒSì“©×é3æõ;Ï{½¡äº~0WÈ8,šwÜa`à\hÜE<a(Dæ^o÷yßÊ‰×ë<ï÷†¯w¨æé9 }D¤ÒÄı!]èºÃ§x	©qñÉU…û"0ğw5_ÓÄS¿Æ¯ú>5ğ¤&RqÍ¬~Åk|·®¿bYWØoÖ•†ê±0p­;1ú¾«Ôz…ñU×Àkšu¼k0×zÑq…‹,©ğw†±çN\¸0pßŠĞZ^+ÈX]0ìh$ğkÕŞe“Òá§u!1[’µ¦	‹*|œd“ŸxVãjâWøÂ _˜4†|ÀëB–ÖJÈÙ~UëjeÁ¢®ç³7Ç¶6ê®AtYãsjèÊ±%Y¿ÆûfFaÆÇş»ªĞ47:HjÜ—õEb ³ZL5ıŒõ&^ËœÄÖè"¨{ZÌÃ
_šÆhiV˜xmgßÍ:ã Ï+4Šú¤ï×8MœÕ…Kƒ(ëx-ˆO&.jò¹?3Hêzå²*ÈlQá™EeÁ:;øõìåÉñŞákïˆ¥ùÂ~³wl¾:8:òê¤îìàí±·À»;Ø	xÌĞı|äu­‘¾GÖ´˜Ñ5»¡¯qÿgnÙ¿Ìıo·ïV÷¿İn÷}wĞìÿ>Ëù9Ğó¿_¤qNûs*yB‡Õ‰„I€/dğñ§â™p©Ö¹õ£TÁ¹"¾IFÊŸR¶°¥ZÆŸá¥->VSâ¯Ê¤|L!ó\2ÎŸ^XP;âÑHSx$,ÈY©P£/†G+Şº£c_S®­áãA”Tö5ø¥ú‰SÊ•>J¶SªHH#¸H0õ…¤
ºo¿'ŸeËVYå*²¿Çú¤xÌğ:±,ÙòÂ*ªFÅx½‚®ªÄ×Æé£ˆ3l²“Ç)×ï”ƒ,b4|bû—qM¬òÇ(äĞÀÁxŸ²âÃÌìÿuJrhølŠ„LĞ æiiã½ËSØBÉ{)Û5-‹ÏcèÂTiZ
¦ÅG³Æ½·•€…^¶—Il¿7[ŸMîÙ¢?qü7Ş_m}ºøÛÿÿ¸ƒâş··»³ëvuşßuw›øÿ¹Ïÿ‹“Ä×åÃÖ1` :œCQÿcEıT ×·Ëò¨~&oşoQsØ@4Ğ@4Ğ@4Ğ@4Ğ@4Ğ@4ğyà¿£Ó
y P  