#/bin/bash

#script for syntax production.yaml.erb

incre=0
separator=(promotion: startingfrom: room:)
# hotel per line +1
hotel=14

for i in $(cat $1 );
do
	if [ "$i" != "${separator[$incre]}" ];
	then
	  echo "$i" >> result$incre
	else	
	  incre=$((incre+1))
	fi 
done

for j in {0..3};
do 
   cp result$j result$j.tmp
   cat result$j.tmp | sed '/^-/ d' | sed 's/|/\n/g' | sed 's/"//g' | sed '/routers:/ d'| sed '/promotionorderable:/ d' | sed '/regexps:/ d' | sort -u  > result$j
   rm -f result$j.tmp
done


for z in  {0..3}
do
  listhotel=()
  listline=()
  repet=0
  number=0
  echo "diff in list of hotel, paragraph $z" 
  diff result0 result$z
          if [ "$z" = "0" ];
        then
          cat <<EOF >final
---
  routers:
    promotionorderable:
      regexps:
EOF
        fi

        if [ "$z" = "1" ];
        then
          cat <<EOF >>final
    promotion:
      regexps:
EOF
        fi

        if [ "$z" = "2" ];
        then
          cat <<EOF >>final
    startingfrom:
      regexps:
EOF
        fi

        if [ "$z" = "3" ];
        then
          cat <<EOF >>final
    room:
      regexps:
EOF
        fi  

	for k in $(cat result{0..3})
	do
  	  listhotel+=( "$k")
	done
		for l in ${listhotel[@]}
		do
			if [ "$repet" = "$hotel"  ]
			then
  	  	  	  listline=("${listline[@]}" "${listhotel[$number]}")
  	  	  	  number=$((number+1))
  	  	  	  repet=0
  	   	  	  echo "${listline[@]}" | sed 's/ /|/g' | sed 's/^/\t- "/' | sed 's/$/"/' >> final
  	  	  	  listline=()
			else
  	  	  	  listline=("${listline[@]}" "${listhotel[$number]}")
       	  	  	  number=$((number+1))
  	  	  	  repet=$((repet+1))
			fi
		done
  echo "${listline[@]}" | sed 's/ /|/g' | sed 's/^/\t- "/' | sed 's/$/"/' >> final
done

rm result[0-3]
