file(WRITE ${OUTPUT} "")
string(REPLACE " " ";" RESOURCES ${RESOURCES}) # seperate paths with semi-colons
foreach(file ${RESOURCES}) # Loop through files
    string(REGEX REPLACE "\\/|\\.| |-" "_" name ${file}) # repace /,., ,- with _
    file(READ ${file} data HEX) # read file as hex
    string(REGEX REPLACE "([0-9a-f][0-9a-f])" "0x\\1," data ${data}) # hex to C style array 
    file(APPEND ${OUTPUT} "const char ${name}[]={${data}0x0};\n") # string array
    file(APPEND ${OUTPUT} "const int ${name}_len=sizeof ${name};\n") # size of array
endforeach()
