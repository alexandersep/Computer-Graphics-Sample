file(WRITE ${OUTPUT} "")
string(REPLACE " " ";" RESOURCES ${RESOURCES}) # seperate paths with semi-colons
file(APPEND ${OUTPUT} "#ifndef __RES_H__\n#define __RES_H__\n") # Create header
foreach(file ${RESOURCES}) # Loop through files
    string(REGEX REPLACE "\\/|\\.| |-" "_" name ${file}) # repace /,., ,- with _
    file(APPEND ${OUTPUT} "extern const char ${name}[];\n") # extern string array
    file(APPEND ${OUTPUT} "extern const int ${name}_len;\n") # extern size of array
endforeach()
file(APPEND ${OUTPUT} "#endif\n") # end header
