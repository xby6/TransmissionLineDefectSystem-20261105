"""Create private Docker settings without overwriting existing credentials."""
import argparse
import os
from pathlib import Path
import secrets


def create_config(destination: Path, http_port: int = 80):
    if not 1 <= http_port <= 65535:
        raise ValueError('HTTP port must be between 1 and 65535')
    content = (
        '# Private deployment settings. Do not commit or share this file.\n'
        'POSTGRES_USER=elyw\n'
        'POSTGRES_DB=elyw_algo\n'
        f'POSTGRES_PASSWORD={secrets.token_urlsafe(32)}\n'
        f'JWT_SECRET_KEY={secrets.token_hex(32)}\n'
        f'ADMIN_PASSWORD={secrets.token_urlsafe(18)}\n'
        f'HTTP_PORT={http_port}\n'
    )
    descriptor = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(descriptor, 'w', encoding='utf-8', newline='\n') as output:
        output.write(content)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path,
                        default=Path(__file__).resolve().parents[1] / '.env.docker')
    parser.add_argument('--http-port', type=int, default=80)
    args = parser.parse_args()
    try:
        create_config(args.output, args.http_port)
    except (FileExistsError, ValueError) as error:
        parser.exit(1, f'Configuration not written: {error}\n')
    print(f'Created {args.output}. Login account: admin.')
    print('Read ADMIN_PASSWORD in that private file for the initial login password.')


if __name__ == '__main__':
    main()
