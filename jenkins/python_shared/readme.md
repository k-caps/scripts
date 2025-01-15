# Shared module which allows using python files as Jenkinsfile
TODO: Make a list here of each file in the module and what it used for along with a minimal usage example



### vaultwrapper.py
##### Requirements:
```
pip install ansible-core 
```
This component abstracts read-only access to Ansible Vault, with a single predefined vault file and vault password file.   
This mimics the behavior and expeirnce of working with the Jenkins credentials store.

# To get a single secret:

```python
with Vault({"secret_id": "admin_password", "var": "mypass"}) as vault:
    print(f"Secret value: {vault.mypass}"
```
To use multiple secrets:

```python
with Vault([
    {"secret_id": "test_file", "var": "file_contents"},
    {"secret_id": "admin_password", "var": "passw"}
]) as vault:
    api_password = vault.passw
    file_contents = vault.file_contents.secret
```
When using the variable in `print()`, `str()`, or `format()`, the value is masked as *****.   
This allows you to securley print commands including passwords to the console while debugging.  
You can access the var's `.secret` property to work with the value as clear text, or you can cast the var itself to str, for example to write to a file. (VERY insecure, but sometimes necessary - like for generating an SSH key into a workspace.)   
```python
with open("test.txt", "w") as file:
    file.write(str(file_contents))
```

To add new values to the vault, or to otherwise modify it, use the `ansible-vault` CLI:
```bash
file_contents="
line1
line 2
"
ansible-vault encrypt_string --vault-pass-file vaultpass.txt $file_contents --name test_file >> vault.yml

ansible-vault encrypt_string --vault-pass-file vaultpass.txt '1234' --name admin_password >> vault.yml
```

To view values run ansible CLI:
```bash
ansible localhost -m ansible.builtin.debug -a var="admin_password" -e "@vault.yml" --vault-pass-file vaultpass.txt
localhost | SUCCESS => {
    "admin_password": "1234"
}

ansible localhost -m ansible.builtin.debug -a var="test_file" -e "@vault.yml" --vault-pass-file vaultpass.txt
localhost | SUCCESS => {
    "test_file": "\nline1\nline 2\n"
}

# If you want to print multiline strings as actual multilines, you can use something like this:
echo -e $(ansible localhost -m ansible.builtin.debug -a var="test_file" -e "@vault.yml" --vault-pass-file vaultpass.txt | grep ':' | awk -F '": '" '{print $2}') | sed \$d
"
line1
line 2
"
```
