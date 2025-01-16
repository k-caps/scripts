def runPython(String pythonFile, Map jobParams) {
  sh("""\
      docker run --rm -i \
      -v ${WORKSPACE}:/python \
      -w /python \
      ${globals.PYTHON_DOCKER_IMAGE} \
          python python_shared/run.py \
              --file $pythonFile \
              --params ${jobParams}
  """)
}
