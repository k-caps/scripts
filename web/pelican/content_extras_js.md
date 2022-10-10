```javascript
<script>
        const URL = 'https://sheets.googleapis.com/v4/spreadsheets/1vT5NnI-hGCCmRzmINbh39mNirVVGeuIwq1v2HLNnwNQ/values/data?key=AIzaSyB8m59VTa0d8ldU1UMi8wD-M5KUh6CEz7o';

        async function getDataFromApi(URL) {
                const response = await fetch(URL);
                var data = await response.json();
                return data;
        }

        function addNewRow(bookArray) {
                const table = document.getElementById("datatable");
                const row = table.insertRow();

                // Create a new row in the table, per column, from the array we get
                bookArray.forEach((bookValue, index) => {
                        const currValue = bookValue || "";
                        const cell = row.insertCell(index);
                        cell.textContent = currValue;
                        //cell.innerHTML = currValue;
                        //document.getElementById("one").firstChild.data = "two";

                })
        }

        function handleSheet(jsonSheet) {
                const newBooks = jsonSheet.values.slice(1);
                newBooks.forEach(addNewRow);
        }

        getDataFromApi(URL).then(handleSheet);
</script>
```
```html
----
## If you know a book you think I'd like, please click on the link below to add it to the suggestions list!
<details>
        <summary style="color:#0000EE;">Click here to add a recommendation</summary>

<iframe src="https://docs.google.com/forms/d/e/1FAIpQLScQQaI4fZWfNPykmWDMqdGKJ3yWvUrZ08DjUfvyFzc2gSb5cg/viewform?embedded=true" width="700" height="800" frameborder="0" marginheight="0" marginwidth="0">Loading…</iframe>
</details>
```

```html
<script>window.location = "/pages/main-list.html"</script>
```
