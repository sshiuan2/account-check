#!/bin/bash
FB_files(){
case $1 in
"lsd")
  echo "fb.lsd"
  ;;
"m_r_xml")
  echo "fb.mobile.xml"
  ;;
"error_code")
  echo "fb.error_code.log"
  ;;
"cookie")
echo "fb.cookie"
;;
"log")
echo "fb.log"
;;
"lastpost")
echo "fb.last_post.log"
;;
"result")
echo "fb.last_result.xml"
;;
"true")
echo "fb.found.txt"
;;
"false")
echo "fb.notfound.txt"
;;
*)
  echo "wrong file, sorry"
  exit 2
;;
esac
}
FB_register_gen_lsd(){
local url=$(FB_register_url "mobile")
local xml=$(FB_files m_r_xml)
if [ ! -f $xml ];then
curl -L $url > $xml
fi
local f=$(FB_files lsd)
if [ ! -f $f ];then
#<input type="hidden" name="lsd" value="AVrH7ixR" autocomplete="off">
local lsdnode=$(grep -E -o "(<input[^>]+name=\"lsd\"[^>]+>)" < $xml)
echo $lsdnode|sed "s/.*value=\"\([^\"]\+\)\".*/\1/g" > $f
fi
}
FB_register_get_lsd(){
if [ ! -f $(FB_files lsd) ];then
FB_register_gen_lsd
fi
echo $(<$(FB_files lsd))
}
FB_register_build_data(){
local email=$(echo -n $1 |sed -rn "s/([^@]+)@(.*)/\1%40\2/p")
local name=$(echo -n $email | sed -rn "s/([^@]+)@.*/\1/p")
local method=$2
local firstname=$name
local lastname=$name
#if there is no noscript=1 in cookie, random a value...
#local n=$RANDOM
#local gender=$n #1 or 2...
#let gender=(gender%=2)+1
#local year=$n
#let year=(year%=20)+1970
#local month=$n
#let month%=12
#local day=$n
#let day%=30
local pw="1" #if noscript, set to 1 let bot signup always fail, so we can see no captcha
local lsd=`FB_register_get_lsd`
if [ "$lsd" == "" ];then
FB_register_gen_lsd
fi
local datas
if [ "$method" == "mobile" ];then
datas=(
lsd=$lsd
submission_request=true
firstname="$firstname"
lastname="$lastname"
email="$email"
pass="$pw"
#gender=$gender
#month=$month
#day=$day
#year=$year
#no use
#charset_test=%E2%82%AC%2C%C2%B4%2C%E2%82%AC%2C%C2%B4%2C%E6%B0%B4%2C%D0%94%2C%D0%84
#reg_instance=jd5AU4KgRQRLT5g1WRncjK5c
#cred_label=email_or_phone
#submit=Sign+Up
)
else
datas=(
lsd=$lsd
lastname="1" #1 ok
firstname="1" #1 ok
reg_email__="$email"
reg_passwd__="$pw"
__a="1" #origin is 1, but can "" or numbers?
#probobaly no use (max bytes of fb result increased)
#__req="7"
#__dyn="7wiXwNAwsUKEkzoynFw"
#following are confirmed by fiddler
#reg_email_confirmation__="$1"
#birthday_year="1970"
#birthday_month="1"
#birthday_day="1"
#sex="2"
#referrer=""
#asked_to_login="0"
#terms="on"
#contactpoint_label="email_only"
#ab_test_data="PAAfA/fvAPfvAAAAAAAAAAAAAAAAAAAPAAAAAAAAAOw/dAEAEAJFAE"
#reg_instance="I8tAUwW-4tcvz5j-UGE3vXZX"
#captcha_persist_data="AZmYRofYBz59zidVl-B4YDyyNE6Pi6deR8_Zgq9hB_h0azLl2di0sZIhU9yVc5pOp26maBnGzQH5gJo10_UIqs_-XX5m54G91PNPQMbqd-6Upv1XLIJe2zRZkZk4b59e85UZaICyxYPrtpgkSiUn8QDdX7CuA6GC4jo_6wANHHOviYWc1tYFsO7lpY6zKAnpIp2pT1kgwzcTfYJen737HJ8ZCaqXxKqJv8MDWeN_mRt4hQ31Z2BWCZlivN2qxdk2ESdRCzIo1QgSIioHPif9ygJoPJNxEl-HkSP2wayYsVUKo-RMdmN6z-rNnURpe41syRNVc7hR4OS-Awzyaodcf2V9owqrOIEYDinevwPs27m1zA"
#captcha_session="Ik7zkGpTtrVv_n99F0Nlmg"
#abtest_registration_group="1"
#locale="zh_TW"
#extra_challenge_params="authp%3Dnonce.tt.time.new_audio_default%26psig%3DNg06TP8G8sjH1aMibO3RIA1bmCU%26nonce%3DhIarDG9rxJkS71vY3OHgtA%26tt%3DdakHouVGC7dzSnB5NSnuxorsjNk%26time%3D1396760588%26new_audio_default%3D1"
#recaptcha_type="password"
#captcha_response=""
#ignore="captcha"
#__user="0"
#__rev="1193322"
)
fi
echo $(IFS="&";echo "${datas[*]}")
}
FB_register_url(){
local method
if [ "$1" == "" ];then
local method="mobile"
else
local method=$1
fi
local lang=$2 #zh-tw
local url
case $method in
"mobile")
  url="https://m.facebook.com/r.php"
  ;;
"desktop")
if [ "$lang" = "" ];then
url="www.facebook.com/ajax/register.php"
else
url="$lang.facebook.com/ajax/register.php"
fi
  ;;
*)
echo error
exit 2;
;;
esac
echo $url
}
FB_purge(){
rm -f $(FB_files lsd)
rm -f $(FB_files cookie)
rm -f $(FB_files m_r_xml)
}
FB_register(){
local email=$1
local method=$2
local url=`FB_register_url $page`
local cookie=`FB_files cookie`
local userAgent="\"User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; MALN; rv:11.0) like Gecko\""
local raw_lsd=$(FB_files m_r_xml)

FB_purge
#set noscript
local noscript=1
echo -e ".facebook.com\tTRUE\t/\tFALSE\t0\tnoscript\t$noscript" >> $cookie

#get new lsd and cookie
curl --user-agent "$userAgent" --cookie $cookie --cookie-jar $cookie $url --output $raw_lsd

#build data & summit
local POST=`FB_register_build_data $email $method`
echo $POST > $(FB_files lastpost)
echo $(curl --data $POST --user-agent "$userAgent" $url --cookie "$cookie")
}
FB_mail_filter(){
local email=$1
local method=$2
local data=$3
local f=$4
local todir=$5
if [ "$f" == "" ];then
echo "test done."
return 2;
fi

if [ "$todir" == "" ];then
todir="./$f"
fi
mkdir -p $todir

local f_true=$todir/$(FB_files true)
touch $f_true
if [ ! -f "$f_true" ];then
echo "output file $f_true is not a file"
exit 2;
fi

local f_false=$todir/$(FB_files false)
touch $f_false
if [ ! -f "$f_true" ];then
echo "output file $f_false is not a file"
exit 2;
fi

if [ "$method" == "mobile" ];then
local error_exist="existing account associated"
local error_70="browser has cookies"
	if [[ "$data" == *"${error_exist}"* ]];then
echo "$email registed"
		if [[ "$(sed -n "0,/^$email$/{/^$email$/p}" $f_true)" != "$email" ]];then
echo $email >> $f_true
		fi
sed -i "/^$email$/d" $f
	elif [[ "$data" == *"${error_70}"* ]];then
echo "$email got error 70 stop job..."
exit 2;
	else
echo "$email not found"
echo $email >> $f_false
sed -i "/^$email$/d" $f
	fi
#sed '/^$/d' filename.txt
else #todo desktop method
local code_exist=25
local code_70=70
fi
}
FB_main(){
local f=$1
local todir=$2
local method="mobile"
local delay=$3
if [ "$delay" == "" ];then
delay=0
fi
local test_result=`FB_files result`
local mail
if [ -f $f ];then
while read mail;do
if [ -z $mail ];then
FB_mail_filter $mail $method "$(FB_register $mail $method)" $f $todir
sleep $delay
fi
done <$f
elif [ "$1" != "" ];then #for test
FB_register $f $method > $test_result
FB_mail_filter $f $method "$(<$test_result)"
else
echo "error parameters? \$1: $1"
exit 2;
fi
echo "$f done."
}
clean_CR(){
sed -i 's/\r//' $1
echo "All CR in file $1 are cleaned"
}
case $1 in
"")
script1="input-file"
script2="output-folder"
script3="[delay second default=0]"
echo "Need cd to file's pwd then exec."
echo "usage: ${BASH_SOURCE[0]} $script1 $script2 $script3"
echo "usage: ${BASH_SOURCE[0]} single-email"
echo "output-ok: $script2/$(FB_files true)"
echo "output-fail: $script2/$(FB_files false)"
echo "output-last-xml: $(FB_files result)"
;;
*)
clean_CR $1 #fix ms \r text...wtf
FB_main $1 $2 $3
;;
esac
