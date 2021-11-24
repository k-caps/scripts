**To split a file into 1GB parts:**  
`split -b 1024M file.tar.gz "file.tar.gz.part."`
  
**To recombine the parts:**
`cat file.tar.gz.part.* > file.tar.gz`
