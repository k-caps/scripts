#!/Users/kobi/Dev/python_home/venvs/vaultwrapper/bin/python3

from vaultwrapper import Vault

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


with open("test.txt", "w") as file:
    file.write(str(file_contents))

print(api_password) # pretend i use the password to login to an api
