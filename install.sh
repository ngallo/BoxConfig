#!/bin/bash
set -u -e

# reads a file of links to set up relative to a source and dest folder
# the filenames are relative to the source and dest folders  (to make it possible
# to test it without trashing the real files). If unspecified the dest is $HOME
# and the source is the same folder that the script is in
# existing files will get backed up to $dest/backups

# default the source to be the same as the script
readonly thisdir=$( cd `dirname $0` && pwd )
srcdir="$thisdir"
# default dest to be home
destdir="$HOME"
config="install.cfg"
dryRun=
copyMode="link"
readonly backupname=$(date +"backups/%Y%m%d-%H%M%S")
verbose=
host=$( hostname -s 2> /dev/null || hostname )
os=$( uname )

function usage()
{
	cat <<-END

	Usage:     $0 -nv -s source_dir -d dest_dir -m hostname -o os configfile

	           -n     dry run, don't make any changes
	           -s     source dirrectory. Defaults to $thisdir
	           -d     destination directory. Defaults to $HOME
	           -c     copy files instead of linking
	           -v     verbose output
	           -m     override machine hostname (defaults to $host)
	           -o     override operating system (defaults to $os)
	           -h     display this message

	       configfile is a colon seperated list of destination:source:host_pattern:os_pattern

	         .bashrc:my_bashrc.bash:satur.*:Linux|Darwin

	       will link/copy source_dir/my_bashrc.bash to dest_dir/.bashrc if the hostname
	       begins with satur (saturday, saturn etc..) and uname is either Darwin or Linux.
	       Patterns are passed to grep -E  an empty pattern will match any host/platform

	END
}

function process_args()
{
	while getopts ":s:d:o:m:nvhc" flag ; do
		case $flag in
		s) srcdir=${OPTARG%/} ;;
		d) destdir=${OPTARG%/} ;;
		n) dryRun=1 ;;
		c) copyMode='copy' ;;
		v) verbose=1 ;;
		o) os=${OPTARG} ;;
		m) host=${OPTARG} ;;
		h) usage ; exit 1 ;;
		:) echo "ERROR: missing argument to flag [-$OPTARG]" ; usage ; exit 5 ;;
		\?) echo "ERROR: Invalid Option [-$OPTARG]" ; usage ; exit 5 ;;
		esac
	done

	shift $((OPTIND-1))
	[[ -z ${1:-} ]] && { echo "ERROR: missing config file" ; usage ; exit 5 ; }
	config="$1"
}

function linker()
{
    local src="$1"
    local dest="$2"
    if [[ $copyMode == copy ]] ; then
        echo COPY: "$@"
        [[ $dryRun ]] || cp -R "$src" "$dest"
    elif echo "$os" | grep -qE "MINGW" ; then
        mingw_linker "$@"
    else
        posix_linker "$@"
    fi
}

function posix_linker()
{
    local src="$1"
    local dest="$2"
    echo LINK: "$@"
    [[ $dryRun ]] || { remove "$dest" && ln -s "$src" "$dest" ; }
}

function mingw_linker()
{
    local src="$1"
    local dest="$2"
    local wdest=$( cmd.exe //c echo "$dest" | sed 's,/,\\,g' )
    local wsrc=$( cmd.exe //c echo "$src" | sed 's,/,\\,g' )
    if [[ -d "$src" ]] ; then
        echo JUNC: "$wsrc" "$wdest"
        [[ $dryRun ]] || { remove "$dest" &&  cmd.exe //c mklink //j "$wdest" "$wsrc" ; }
    else
        echo HRDL: "$src" "$dest"
        [[ $dryRun ]] || { remove "$dest" &&  cmd.exe //c mklink //h "$wdest" "$wsrc" ; }
    fi
}

function remove()
{
    if [[ -L "$@" ]] ; then
        log "REMOVE LINK: $@"
        [[ $dryRun ]] || rm "$@"
    elif [[ -e "$@" ]] ; then
        log "BACKUP: $@"
        [[ $dryRun ]] || { mkdir -p "$destdir/$backupname" ; mv -f "$@" "$destdir/$backupname/" ; }
    fi
}

function log()
{
	if [[ $verbose ]] ; then
		 echo "$*"
	fi
}

function createdir()
{
	# dont print anything during dryrun or we get repeated messages about the same dir
	if [[ ! -d "$@" ]] ; then
		[[ $dryRun ]] || { log "CREATE: $@" ; mkdir -p "$@" ; }
	fi
}

function main() {
	log "destdir:     $destdir"
	log "srcdir:      $srcdir"
	log "config:      $config"
	log "dryRun:      $dryRun"
	log "link:        $copyMode"
	log "os:          $os "
	log "host:        $host"

	[[ -r "$config" ]]  || { echo "ERROR: cannot read config: $config"    ; exit 6 ; }
	[[ -d "$srcdir" ]]  || { echo "ERROR: source dir not a dir?: $srcdir" ; exit 7 ; }
	[[ -d "$destdir" ]] || { echo "ERROR: dest dir not a dir?: $destdir"  ; exit 7 ; }

	IFS=':'
	grep -v '^#' "$config" | while read dest src hostpattern ospattern; do
		[[ $dryRun ]] || log "========================"
		[[ ! -z "$src" && ! -z "$dest" ]] || continue
		echo "$host" | grep -qE "$hostpattern" || { log "SKIP: $src -> $dest no match for $host =~ $hostpattern"   ; continue; }
		echo "$os" | grep -qE "$ospattern"     || { log "SKIP: $src -> $dest no match for $os =~ $ospattern"       ; continue; }
		local srcfile="$srcdir/$src"
        if [[ "$dest" = /* ]] ; then
            local destfile="$dest"
        else
            local destfile="$destdir/$dest"
        fi
		[[ -r "$srcfile" ]] || { echo "ERROR: $src -> $dest sourcefile $srcfile is not readable" ; continue ; }
		if [[ -e "$destfile" || -L "$destfile" ]] ; then
			if [[ "$srcfile" -ef "$destfile" ]] ; then
				log "SKIP: $src -> $dest dest $destfile is already linked to sourcefile: $srcfile"
				continue
			fi
		else
			local dir="${destfile%/*}"
			createdir "$dir"
		fi
        [[ $verbose ]] && { echo diff "$srcfile" "$destfile" ; diff "$destfile" "$srcfile" || true ; }
		linker "$srcfile" "$destfile"
	done
}

process_args "$@"
main "$@"
