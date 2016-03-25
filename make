for i in src/*.slides
do
	h="${i/src\//}"
	cat reveal-header "$i" reveal-trailer > "${h/slides/html}"
done
