#!/bin/bash
gen_files(){
case $1 in
"out")
echo "merged.txt"
;;
*)
echo "$1 not a core file."
exit 2;
;;
esac
}
gen_head(){
local f_out=$1
cat >$f_out <<EOL
#email,facebook,twitter
#status 1=found,0=notfound,empty=unknow
EOL
}
gen_row(){
local type=$1
local mail=$2
local status=$3
if [ "$type" == "fb" ];then
echo "$mail,$status,"
elif [ "$type" == "twi" ];then
echo "$mail,,$status"
else
echo "type error"
exit 2;
fi
}
append(){
echo $1 >> $2
}
merge(){
local type=$1
local mail=$2
local status=$3
local f_out=$4
if [ "$type" == "fb" ];then
sed -i "s/^\($mail\),\([^,]*\),\([^,]*\)$/\1,$status,\3/" $f_out
elif [ "$type" == "twi" ];then
sed -i "s/^\($mail\),\([^,]*\),\([^,]*\)$/\1,\2,$status/" $f_out
fi
}
gen_dispatcher(){
local d_in=$1
local f_out=$2
local status

for f in $d_in/*;do
local fname=`basename $f`
local type=${fname%%.*}
local mail=""
local sub=`echo $fname|sed -n "s/^$type.//p"`
local status=${sub%%.*}
if [ "$status" == "found" ];then
status=1
elif [ "$status" == "notfound" ];then
status=0
else
status=""
fi
#~% echo "${FILE%%.*}"
#example
#~% echo "${FILE%.*}"
#example.tar
#~% echo "${FILE#*.}"
#tar.gz
#~% echo "${FILE##*.}"
#gz
if [ "$type" == "fb" ] || [[ "$type" == "twi" ]];then
while read line;do
if check_mail $line;then
mail=$line
if [ -z "$(grep $mail $f_out)" ];then
append "$(gen_row $type $mail $status)" $f_out
else
merge $type $mail $status $f_out
fi
fi
done <$f
else
echo "$f filename unknow. pass."
fi
done
}
check_mail(){
local mail=$1
if [[ $mail =~ ^[^@]+@[^@]+$ ]];then
return 0
else
return 1
fi
}
gen_main(){
local d_in=`echo $1|sed 's/\/$//'`
if [ -z $2 ];then
local f_out="$d_in/$(gen_files out)"
else
local f_out=$2
fi
touch $f_out
if [ ! -f $f_out ];then
echo "$f_out not a file."
exit 2;
fi
if [ ! -s $f_out ];then
gen_head $f_out
fi
gen_dispatcher $d_in $f_out
}

case $1 in
"")
param1="folder_in"
param2="[file_out default=folder_in/$(gen_files out)]"
echo "usage: ${BASH_SOURCE[0]} $param1 $param2"
echo "files in folder must have right filaname."
echo "filename: type.status.txt"
echo "types: fb, twi"
echo "status: found, notfound"
echo "example: fb.found.txt"
;;
*)
gen_main $@
;;
esac
