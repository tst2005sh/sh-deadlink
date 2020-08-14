#!/bin/sh

deadlink() {
	local NO_ABS=false
	local NO_REL=false
	while [ $# -gt 0 ]; do
		case "$1" in
		('-h'|'--help')
			echo "Usage: $0 [--na|--no-absolute]|[--nr|--no-relative] [--] <directory>";
			exit 0;
		;;
		('--na'|'--no-abs'*) shift; NO_ABS=true ;;
		('--nr'|'--no-rel'*) shift ; NO_REL=true ;;
		('--') shift; break ;;
		('-'*) echo >&2 "Bad option $1"; exit 1 ;;
		*) break;
		esac
	done
	local file="" from="" link=""
	if [ $# -eq 0 ]; then
		set -- .
	fi
	while [ $# -gt 0 ]; do
		find "$1" -type l -printf 'p %P\nl %l\n' | {
		while read -r type line; do
			case "$type" in
			(p)
				file="$line"
				from="$(dirname "$file")"
			;;
			(l)
				link="$line"
				if case "$link" in
					('/'*) false;;
					(*) true;;
				esac; then
					${NO_REL:-false} && continue
					link="$1/$from/$link"
				else
					${NO_ABS:-false} && continue
				fi
				[ ! -e "$link" ] && echo "!! $1/$file -> $link"
			;;
			esac
		done
		}
		shift;
	done
}
deadlink "$@"
