
MIRROR_LOG="${WORK}/${1:-mirror_ibm-watsonx-ai-ifm.log}"

[[ ! -f $MIRROR_LOG ]] && echo "File not found! $MIRROR_LOG" && exit

awk '
function unit_MiG( value, unit) {
	switch (unit) {
		case "KiB": value = value / 1024; break;
		case "MiB": break;
		case "GiB": value = value * 1024; break;
		default:    print "Unkown unit", unit; break;
	}
	return value;
}
/uploading/{
	value = unit_MiG( ($NF +0), substr($NF,length($NF)-2) );
	uploading[$2] += value;
	upTot += value;
}
/mounted/{
	value = unit_MiG( ($NF +0), substr($NF,length($NF)-2) );
	mounted[$2] += value;
	mtTot += value;
}
END{
	for (image in uploading)
		printf "%-65s: up=%11.3f MiB, mt=%11.3f MiB\n",
			image, uploading[image], mounted[image];
	printf "Total uploaded: %11.3f MiB, Total mounted: %11.3f MiB\n",
		upTot, mtTot;
}' ${MIRROR_LOG} | sort

