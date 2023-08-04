# Test Server for the Flutter App

## Setup

1. `cd test_fa_backend`
2. (optional) create virtual environment
   `python -m venv .venv`
3. `source .venv/bin/activate` (macOS/Linux)

   `.venv\bin\Activate.ps1` (Windows PowerShell)
4. `pip install -r requirement.txt`
5. ```shell
   cd test_fa_backend
   python manage.py makemigrations
   python manage.py migrate
   python manage.py runserver 0.0.0.0:9999
   ```
   you need to allow a port in your operating system's network settings

## Flutter part

1. change your IP address (or port) in `utility/test_api.dart`
2. connect the phone to the same network as the server