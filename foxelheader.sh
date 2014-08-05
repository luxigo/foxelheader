#!/bin/bash

if [ $# -eq 0 -o $# -lt 4 ] ; then
  echo "Usage: $(basename $0) <project> <years> <author> [<author> ...] <file>"
  exit 1
fi

PROJECT=$1
shift
YEARS=$1
shift

header() {

cat << EOF
/*
 * $PROJECT
 *
 * Copyright (c) $YEARS FOXEL SA - http://foxel.ch
 * Please read <http://foxel.ch/license> for more information.
 *
 *
 * Author(s):
 *
EOF

}

footer() {

cat << EOF
 *
 *
 * This file is part of the FOXEL project <http://foxel.ch>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * Additional Terms:
 *
 *      You are required to preserve legal notices and author attributions in
 *      that material or in the Appropriate Legal Notices displayed by works
 *      containing it.
 *
 *      You are required to attribute the work as explained in the "Usage and
 *      Attribution" section of <http://foxel.ch/license>.
 */
EOF

}

TMPFILE=/tmp/header.$$.tmp
OUTFILE=/tmp/header.$$.out.tmp
header $@ > $TMPFILE

while [[ "$1" =~ "@" ]] ; do
  echo " *      $1" >> $TMPFILE
  shift
done

footer >> $TMPFILE

for f in $@ ; do 
  if head -n 3 $f | grep -q -e '/\*' ; then
    cat $TMPFILE > $OUTFILE
    comment=0
    nextline=1
    cat $f | while read line ; do
      ((++nextline))
      case $comment in
      0)
        if echo "$line" | grep -q -e '^ */\*' ; then
          comment=1
        else
          echo "$line" >> $OUTFILE
        fi
        ;;
      1)
        if echo "$line" | grep -q -e '^ *\*/' ; then
          tail -n +$nextline $f >> $OUTFILE
          break
        fi
        ;;
      esac
    done
  else
    echo >> $OUTFILE
    cat $f >> $OUTFILE
  fi
  diff -u $f $OUTFILE 
  echo -n "replace ? y/[n] "
  read reply
  [ "$reply" == "y" ] && cat $OUTFILE > $f
done



