for style in ./styles/*; do

	name=`basename ${style}`
	dir=./src/generated/${name}

	[[ -d ${dir} ]] && rm -r ${dir}
	! [[ -d ./src/generated ]] && mkdir ./src/generated
	cp -rf ./src/Theme/RayTheme/Default ${dir}

	while IFS=, read -r key color; do
		sed -i "s/${color}/${key}/g" ${dir}/RayGui.tres
	done < default_map.csv

	while read line; do
		! [[ "$line" =~ ^f ]] && continue
		fontsize=$(echo $line | awk '{print $2}')
		font=$(echo $line | awk '{$1=$2=$3=""; print $0}')
		font=$(echo ${font##*( )} | tr '[:upper:]' '[:lower:]')
		font="${font%.*}_dynamicfont.res"
		fontfile=${font// /_}

        	sed -i "s/new_dynamicfont.res/${fontfile}/g" ${dir}/RayGui.tres

		echo "Manually update ${fontfile} to have size $fontsize."
	done < ${style}

	while read line; do
		! [[ "$line" =~ ^p ]] && continue
		key=$(echo $line | awk '{print $5}')
		value=$(echo $line | awk '{print $4}')

		# Convert hex to rgba. From https://stackoverflow.com/a/7253786 by Florin Ghita
		hexinput=$(echo $value | tr '[:lower:]' '[:upper:]')
		a=$(echo $hexinput | cut -c3-4)
		b=$(echo $hexinput | cut -c5-6)
		c=$(echo $hexinput | cut -c7-8)
		d=$(echo $hexinput | cut -c9-10)

		r=$(echo "ibase=16;scale=17; $a/FF" | bc)
		g=$(echo "ibase=16;scale=17; $b/FF" | bc)
		b=$(echo "ibase=16;scale=17; $c/FF" | bc)
		a=$(echo "ibase=16;scale=17; $d/FF" | bc)

		sed -i "s/${key}/Color(0$r, 0$g, 0$b, 0$a)/g" ${dir}/RayGui.tres
	done < ${style}

        sed -i "s/RayTheme\/Default/RayTheme\/${name}/g" ${dir}/RayGui.tres
done
