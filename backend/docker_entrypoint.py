"""Initialize credentials once on a NEW Docker database, then start the API.

An imported database without docker_bootstrap keeps its existing passwords.
This entrypoint is used only by the Docker image, never by start-system.ps1.
"""
import os
import sys
from contextlib import closing

import bcrypt
import psycopg2


def bootstrap_database(connection, admin_password):
    with connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT to_regclass('public.docker_bootstrap')")
            if cursor.fetchone()[0] is not None:
                cursor.execute(
                    "SELECT admin_password_pending FROM docker_bootstrap "
                    "WHERE id=1 FOR UPDATE"
                )
                row = cursor.fetchone()
                if row and row[0]:
                    encoded = admin_password.encode('utf-8')
                    if not 8 <= len(encoded) <= 72:
                        raise ValueError('ADMIN_PASSWORD must contain 8-72 UTF-8 bytes')
                    hashed = bcrypt.hashpw(encoded, bcrypt.gensalt()).decode('ascii')
                    cursor.execute(
                        "UPDATE sys_user SET password=%s WHERE user_name='admin'",
                        (hashed,),
                    )
                    if cursor.rowcount != 1:
                        raise RuntimeError('Expected exactly one admin account')
                    cursor.execute(
                        "UPDATE docker_bootstrap SET admin_password_pending=false WHERE id=1"
                    )

            # A Windows backup may still point at localhost. Other platforms are untouched.
            cursor.execute(
                "UPDATE container SET url='http://algo-server:8000' "
                "WHERE url IN ('http://127.0.0.1:8000', 'http://localhost:8000')"
            )
            cursor.execute(
                "UPDATE file SET path=replace(path, chr(92), '/') "
                "WHERE path LIKE 'upload_file%' AND position(chr(92) IN path)>0"
            )


def main():
    with closing(psycopg2.connect(
        host=os.environ['DB_HOST'],
        port=os.environ.get('DB_PORT', '5432'),
        user=os.environ['DB_USERNAME'],
        password=os.environ['DB_PASSWORD'],
        dbname=os.environ['DB_DATABASE'],
        connect_timeout=10,
    )) as connection:
        bootstrap_database(connection, os.environ['ADMIN_PASSWORD'])
    os.execv(sys.executable, [sys.executable, 'app.py', '--env=prod'])


if __name__ == '__main__':
    main()
