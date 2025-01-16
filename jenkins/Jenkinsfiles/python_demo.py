#!/usr/bin/python3
import sys ; sys.path.append('/Users/k-caps/git/scripts/jenkins')
from python_shared.vaultwrapper import Vault
# Optional - get jenkins job params where necessary:
params = globals().get('params') or None # if it's in globals, it came from runpy vi run.py .


def demonstrate_with_credentials():
    
    # Use a single secret:
    with Vault({"secret_id": "admin_password", "var": "mypass"}) as vault:
        print(f"Secret value: {vault.mypass}")
    
    # Use multiple secrets:
    with Vault([
        {"secret_id": "test_file", "var": "file_contents"},
        {"secret_id": "admin_password", "var": "passw"}
    ]) as vault:
        api_password = vault.passw
        file_contents = vault.file_contents.secret    


def write_secret_to_file(secret_id: str, filename: str):
    with Vault({"secret_id": "test_file_cred_id", "var": "file_contents"}) as vault:
        with open(filename, "w") as file:
            file.write(str(file_contents))


def main():
    demonstrate_with_credentials()
    write_secret_to_file(params.SECRET_ID_TO_PRINT, 'test.txt')
    

if __name__ == "__main__":
    main()
