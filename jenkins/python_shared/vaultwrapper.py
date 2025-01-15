import os
from ansible.constants import DEFAULT_VAULT_ID_MATCH
from ansible.parsing.vault import VaultLib, VaultSecret
import yaml

# Constants for default paths
DEFAULT_VAULT_FILE = "vault.yml"
DEFAULT_VAULT_PASS_FILE = 'vaultpass.txt'


class SecretWrapper:
    """Wrapper to mask secrets when printed."""

    def __init__(self, secret: str):
        self._secret = secret

    @property
    def secret(self):
        """Access the actual secret value."""
        return self._secret

    def __repr__(self):
        """Return a masked representation."""
        return "*****"

    def __str__(self):
        """Return a masked string."""
        return "*****"
        


# Define a custom loader to handle `!vault` tags
class VaultLoader(yaml.SafeLoader):
    pass


def vault_constructor(loader, node):
    """Custom YAML constructor for `!vault` tags."""
    return loader.construct_scalar(node)


# Register the custom constructor
VaultLoader.add_constructor("!vault", vault_constructor)


class Vault:
    """
    Context manager for decrypting Ansible Vault secrets.
    
    Accepts:
    - A dictionary with `secret_id` and `var` for a single secret.
    - A list of such dictionaries for multiple secrets.
    """

    def __init__(self, secrets, vault_file: str = DEFAULT_VAULT_FILE, password_file: str = DEFAULT_VAULT_PASS_FILE):
        if isinstance(secrets, dict):  # Single secret case
            secrets = [secrets]
        if not isinstance(secrets, list):
            raise ValueError("Secrets must be a dictionary or a list of dictionaries.")
        self.secrets = secrets
        self.vault_file = vault_file
        self.password_file = password_file
        self.vault = None
        self.decrypted_data = {}

    def __enter__(self):
        """Decrypt vaulted strings and make them accessible."""
        vault_pass = self._read_password_file()
        self.vault = VaultLib([(DEFAULT_VAULT_ID_MATCH, VaultSecret(vault_pass))])

        # Parse the YAML file
        yaml_data = self._read_vault_file()
        parsed_data = yaml.load(yaml_data, Loader=VaultLoader)

        # Decrypt and map secrets
        for mapping in self.secrets:
            secret_id = mapping.get("secret_id")
            var = mapping.get("var")
            if secret_id in parsed_data and isinstance(parsed_data[secret_id], str) and parsed_data[secret_id].startswith("$ANSIBLE_VAULT"):
                self.decrypted_data[var] = SecretWrapper(self._decrypt_value(parsed_data[secret_id]))
            else:
                raise ValueError(f"Key '{secret_id}' not found or not vaulted in the file.")

        return self

    def __exit__(self, exc_type, exc_value, traceback):
        """Clear the decrypted secrets from memory when exiting the context."""
        self.vault = None
        self.decrypted_data = {}

    def __getattr__(self, name):
        """Allow dynamic access to secrets."""
        if name in self.decrypted_data:
            return self.decrypted_data[name]
        raise AttributeError(f"Secret '{name}' not found.")

    def _read_password_file(self) -> bytes:
        """Read the password file."""
        with open(self.password_file, "rb") as f:
            return f.read().strip()

    def _read_vault_file(self) -> str:
        """Read the vaulted YAML data file."""
        with open(self.vault_file, "r") as f:
            return f.read()

    def _decrypt_value(self, encrypted_value: str) -> str:
        """Decrypt a vaulted string."""
        return self.vault.decrypt(encrypted_value).decode("utf-8")
