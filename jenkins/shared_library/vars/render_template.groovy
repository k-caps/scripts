/**********************************************************************************************************/

/**
    Renders a Jinja2 template using a Dockerized Python environment.

    ### How to Use
    ```groovy
    String inputTemplate = 'roles/render_template/path/to/jinja_template.yaml.j2'
    String outputFile = './values.yaml' // File will be added to the workspace root, inside the docker the volume is at /python, which is added automatically

    def templateArgs = [
        my_arg_in_the_template: 'my_arg_value',
        my_arg_from_variable: params.USERNAME.toLowerCase(),
    ]

    generalFunctions.renderJinjaTemplate(inputTemplate, outputFile, templateArgs)


    If the templateArgs includes 'removeEmptyLines: true', the final template will not include any empty lines.


    Besides the variables passed to this function, the renderer will also look for a variables file at the root of the workspace, named `vars.env`.
    You can prepopulate this file using Bash, Groovy, or another Python script. 
    The resulting file should contain one `key=value` pair per line.

    ### Example: Prepopulating `vars.env` with Python
    ```python
    vars_dict = {
        'is_permanent': 'no',
    }
    def write_vars_to_workspace(vars_dict):
        with open('/python/vars.env', 'w') as f:
            for key, value in vars_dict.items():
                f.write(f'{key}={value}\n')

    write_vars_to_workspace(vars_dict)
    ```
    
    ```
 */
def call(String inputTemplate, String outputFile, Map args) {
    boolean removeEmptyLines = args.get('removeEmptyLines', false)

    def vars = args.collect { key, value ->
        "${key}=\"${value}\""
    }.join(' ')

    sh(returnStdout: true, script: """\
        #!/bin/bash
        docker run --rm -dt -v ${WORKSPACE}:/python -w /python ${PYTHON_DOCKER_IMAGE} \
            python3 ./python_shared/render_template.py \
                --template-path=${inputTemplate} \
                --output-path=/python/${outputFile} \
                --vars ${vars}
        """
    )

    if (removeEmptyLines) {
        sh("sed -i '/^\$/d' ${outputFile}")
    }
}
