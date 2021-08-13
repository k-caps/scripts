sudo apt install imagemagick jpegoptim
cd images_to_prepare
jpegoptim --size=800k *
mogrify -resize 50% *
