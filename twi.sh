#!/bin/bash
twitter_files(){
case $1 in
"log")
echo "twi.log"
;;
"last")
echo "twi.lastresult.json"
;;
"true")
echo "twi.found.txt"
;;
"false")
echo "twi.notfound.txt"
;;
"invalid")
echo "twi.invalid.txt"
;;
*)
echo "The file $1 not exist."
exit 2;
;;
esac
}
twitter_register_build_data(){
#[=%5B
#]=%5D
#method for twitter.com
local datas=(
authenticity_token=ac7b47e834317bdf5d00d6b2db38f4f1af1b5b00
user[name]=micheal
user[email]=micheal@gmail.com
#user[user_password]=1
user[screen_name]=micheal
asked_cookie_personalization_setting=1
#context
#ad_id
#ad_ref
#submit_button=Create my account
#user[discoverable_by_email]=1
#user[send_email_newsletter]=1

#method for mobile.twitter.com
)
echo $(IFS="&";echo "${datas[*]}")
}
twitter_build_query(){
local datas=(
email=$1
)
echo $(IFS="&";echo "${datas[*]}")
}
twitter_api(){
local type="users"
local method="email_available"
local url="https://twitter.com/$type/$method"
local query=$(twitter_build_query $1)
local log=$2
echo curl --get --data "$query" $url >> $log
echo $(curl --get --data "$query" $url)
}
append_mail(){
local mail=$1
local f=$2
if [ -z "$(sed -n "0,/^$mail$/{/^$mail$/p}" $f)" ];then
echo $mail >> $f
else
echo "$mail exist in $f"
fi
}
remove_mail(){
local mail=$1
local f=$2
sed -i "/^$mail$/d" $f
}
twitter_mail_filter(){
local mail=$1
local data=$2
local f_in=$3
local d_out=$4
if [ -z $f_in ];then
echo "$mail test done."
return 0;
fi
if [ -z $d_out ];then
d_out="./$f_in"
fi
mkdir -p $d_out
local f_found="$d_out/$(twitter_files true)"
local f_notfound="$d_out/$(twitter_files false)"
local f_invalid="$d_out/$(twitter_files invalid)"
touch $f_found
touch $f_notfound
touch $f_invalid
if [ ! -f $f_found ] || [ ! -f $f_notfound ] || [ ! -f $f_invalid ];then
echo "output file $f_found , $f_notfound error"
exit 2;
fi
local keyword_t="already been taken"
local keyword_f="Available"
local keyword_invalid="This email is invalid"
if [[ "$data" == *"$keyword_t"* ]];then
echo "$mail registed"
append_mail $mail $f_found
remove_mail $mail $f_in
elif [[ "$data" == *"$keyword_f"* ]];then
echo "$mail notfound"
append_mail $mail $f_notfound
remove_mail $mail $f_in
elif [[ "$data" == *"$keyword_invalid"* ]];then
echo "$mail is not mail"
append_mail $mail $f_invalid
remove_mail $mail $f_in
elif [ -z "$data" ];then
echo "twitter return nothing."
exit 2;
else
echo "unknow error"
exit 2;
fi
}
clean_CR(){
sed -i 's/\r//' $1
echo "All CR in file $1 are cleared"
}
twitter_main(){
local f_in=$1
local d_out=$2
local delay=$3
local log=$(twitter_files log)
if [ -z $delay ];then
delay=0
fi
local mail
if [ -f $f_in ];then
while read mail;do
if [ ! -z "$mail" ];
twitter_mail_filter $mail "$(twitter_api $mail $log)" $f_in $d_out
sleep $delay
fi
done <$f_in
elif [ ! -z "$f_in" ];then
local lastresult=$(twitter_files last)
twitter_api $f_in $log >> $lastresult
twitter_mail_filter $f_in $(<$lastresult)
else
exit 2;
fi
}

case $1 in
"")
param1="email|file"
param2="[output-folder]"
#param3="[delay]"
echo "usage: ${BASH_SOURCE[0]} $param1 $param2 $param3"
;;
*)
if [ -f $1 ];then
clean_CR $1
twitter_main $1 $2 $3
elif [ ! -z $1 ];then
twitter_main $1
fi
;;
esac
