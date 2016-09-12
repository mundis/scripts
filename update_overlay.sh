URL=https://github.com/mundis/overlay/tree/master



cat > README.md << "EOF"
Adding the overlay
------------------
To add this overlay to your system:  
uncomment in: `/etc/layman/layman.cfg` the line  
`# overlay_defs : /etc/layman/overlays` to  
`overlay_defs : /etc/layman/overlays`  
and use the following commands  
`wget -P /etc/layman/overlays/ https://raw.github.com/mundis/overlay/master/mundis.xml`  
`layman -L`  
`layman -a mundis`

##### All ebuilds into the overlay:  

EOF
dirname `find -name *.ebuild | sed 's/\.\///g'` | uniq > ../ebuild_list.txt
count=1;while read line; do EBUILD[count]=$line;count=$[count+1]; done < ../ebuild_list.txt
grep -h DESCRIPTION= `find -name *.ebuild` | sed 's/DESCRIPTION=//g' | sed 's/"//g' | uniq > ../description_list.txt
count=1;while read line; do DESCRIPTION[count]=$line;count=$[count+1]; done < ../description_list.txt



echo "<table>" >> README.md
for i in $(seq 1 ${#EBUILD[*]});do
	echo "<tr><td>" >> README.md
	echo "<a href=${URL}/${EBUILD[i]}>${EBUILD[i]%%.ebuild}</a>" >> README.md
	echo "</td><td>" >> README.md
	echo "${DESCRIPTION[i]}" >> README.md
	echo "</td></tr>" >> README.md
done
echo "</table>" >> README.md

git add *
git commit -a
git push origin master
