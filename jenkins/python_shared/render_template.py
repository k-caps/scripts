import os
import argparse
from jinja2 import Environment, FileSystemLoader

VARS_FILE = '/python/vars.env'

def get_external_vars(vars_file):
    ext_vars = {}
    if os.path.exists(vars_file):
        with open(vars_file) as f:
            for line in f:
                key, value = line.strip().split('=', 1)
                ext_vars[key] = value
    return ext_vars


def parse_cli_args():
    parser = argparse.ArgumentParser(description="Generic Jinja2 template renderer.")
    parser.add_argument("--template-path", required=True, help="Path to the Jinja2 template file.")
    parser.add_argument("--output-path", required=True, help="Path to save the rendered template.")
    parser.add_argument("--vars", nargs='*', help="Key-value pairs to render the template, e.g., key=value.")
    return parser.parse_args()


def get_template_vars(args):
    cli_vars = {}
    ext_vars = {}
    all_vars = {}

    if args.vars:
       cli_vars = dict(var.split("=", 1) for var in args.vars)

    ext_vars = get_external_vars(VARS_FILE)
    all_vars = {**cli_vars, **ext_vars}
    return all_vars


def main():
    args = parse_cli_args()
    all_vars = get_template_vars(args)

    # Load and render the Jinja2 template
    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template(args.template_path)

    # Render the template with any vars
    rendered_content = template.render(**all_vars)

    # Write the rendered content to the output file
    with open(args.output_path, "w") as f:
        f.write(rendered_content)

    print(f"Template rendered successfully to {args.output_path}")

if __name__ == "__main__":
    main()
