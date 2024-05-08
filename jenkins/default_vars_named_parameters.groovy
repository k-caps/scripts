//Jenkinsfile
shared_library_name.functionName(parameterOne: "value", paramThree: "val")


// vars/shared_library_name.groovy
def functionName(Map params = [:]){
    params.parameterOne = params.parameterOne ?: "defaultValue"
    params.secondParameter = pramas.secondParameter ?: "defaultValue"
    params.paramThree = pramas.paramThree ?: "defaultValue"
    // if using groovy >= 3.0 
    params.paramFour ?= "defaultValue"
}
