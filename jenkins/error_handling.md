# Catch-all error handling use shared library:
1. Wrap each stage in a try/catch block:
```groovy
try {
  // any code goes here
}
catch(Exception ex) {
    env.error_message = ex.toString()
    error('<Stage> failed.')
}
```
2. Add a post step that uses the raised exception:
```groovy
  post {
    always {
      script {
        post_actions.always()
        post_actions.shutdown(env.error_message)
      }
    }
  } 
```

3. The shared library should be stored in the vars directory as `post_actions.groovy`:
```groovy
#!/usr/bin/env groovy
import groovy.transform.Field

@Field MATCHER_ERRORS_LIST = ".*fatal.*|.*failed.*|.*ERROR.*|.*FAILED.*|.*UNREACHABLE.*"
@Field MATCHER_ABORTED_LIST = "'.*Aborted by .*'"


def always() {
    cleanWs()
}

def success() {
    script {
        println '\033[0;32mFinished Successfully\033[0m'
    }
}   

def aborted(String matcher, String error_message){
    echo 'This job has been aborted.'
    //If aborted by user
    if (matcher && matcher != 'null' ) {
        matcher_aborted = matcher.split('lastmatch=')[1].split('0m')[1].split(']')[0]
        println "\033[0;31mAborted by User: '${matcher_aborted}' \033[0m"
    }
    else {
        //If there is an error message
        if (error_message && error_message != 'null') { 
            println "\033[0;31mfatal | ERROR | ABORTED | ${error_message} \033[0m"
        }
        else {
            println '\033[0;31mDEBUG: error_message either null or undefined'
        }
    }
}

def failure(String matcher, String error_message) {
    //if there is error
    if (matcher && matcher != 'null' ) {
        matcher_error = matcher.split('lastmatch=')[1].replace(']', '')
        matcher_error = matcher_error.substring(matcher_error.indexOf(' ') + 1)
        println('This job has failed. Exception error:')
        sh "#!/bin/sh -e\n " + "echo '${matcher_error}'"
    }
    else {
        //if Aborted By Another Jenkins Job
        if (error_message.toString().contains('FlowInterruptedException')) {
            currentBuild.result = 'ABORTED'
            echo 'This job was aborted.'
            println("\033[0;31m'FlowInterruptedException' - Aborted by another Jenkins job. Result is ABORTED\033[0m")
        }
        else {
            echo 'This job has been aborted.'
            echo 'Exception error:'
            println '\033[0;31mfatal | ERROR | ' + error_message + '\033[0m'
        }
    }
}

def shutdown(String error_message) {
    switch (currentBuild.result) {
        case 'SUCCESS':
            success()
            break
        case 'FAILURE':
            matcher = manager.getLogMatcher(MATCHER_ERRORS_LIST).toString()
            failure(matcher, error_message)           
            break
        case 'ABORTED':
            matcher = manager.getLogMatcher(MATCHER_ABORTED_LIST).toString()
            aborted(matcher, error_message)  
            break          
    }
}
```
