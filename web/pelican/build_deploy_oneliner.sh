source enter_venv.sh pelican
cd books
pelican content && sed -i '/Published/d ; /Smashing/d ; /href="\/author\/kobi.html/d ; /href="\/category\/series.html/d' output/pages/*.html output/index.html && sed 's/<table/<table id="datatable"/' -i output/pages/suggestions.html && sed -i '4 i <script>window.location = "/pages/main-list.html"</script>'  output/index.html  && pelican --listen -p 8001
