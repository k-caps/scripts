import os
import sys
import runpy
import argparse

def parse_cli_args():
    parser = argparse.ArgumentParser(description="Get Jenkins paramaters and run specified python script")
    parser.add_argument("--file", required=True)
    parser.add_argument("--params", required=False)
    return parser.parse_args()


def params_string_to_dict(params_string):
    return {param_name.strip(): (True if param_value.lower() == 'true' else False if param_value.lower() == 'false' else param_value or None)
        for param_name, param_value in (pair.split('=', 1) for pair in params_string.strip('{}').split(','))
        if param_name.strip()}  # Drops empty keys


def add_script_to_path(file_path):
    script_dir = os.path.dirname(os.path.abspath(file_path))
    sys.path.append(script_dir)


def run(file_path, params_dict):
    add_script_to_path(file_path)
    params = params_dict
    runpy.run_path(file_path, run_name="__main__", init_globals={"params": params})


def main():
    args = parse_cli_args()
    params_dict = params_string_to_dict(args.params)
    run(args.file, params_dict)


if __name__ == "__main__":
    main()
