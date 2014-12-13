file=$1

png=${file/%.svg/_p.svg}

if [ -f "$png" ]; then
    :
else
    inkscape $file -z -b "#ffffff" -d 150 -l $png
fi

# inkscape $file -z -A $pdf
