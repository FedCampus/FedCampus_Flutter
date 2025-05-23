# Developer Guide

The backend Django server for federated analytics follows the Model-View-Controller (MVC) approach. Here is an overview of the components involved:

## Architecture

### Model (api/models.py)

- Customer: `faculty`, `student`, and `male` is used to filter different groups in Statistics page of the Flutter application. `version` records the Flutter application version, and `credit` records users' contribution, user loses one credit if they do not send health data for at least 9 days in 14 days.

- RecordDP: This model represents health data records with added noise.

### View/Controller (api/views.py)

Provides REST Api endpoints.

- Register: This endpoint is used for user registration.
- Login: Token-based authentication provided by Django REST Framework is used for user login. You can refer to the [TokenAuthentication documentation](https://www.django-rest-framework.org/api-guide/authentication/#tokenauthentication) for more details.
- The server performs calculations such as calculating the average of a health data type and percentile ranking based on the noised data using Django ORM manipulation.

#### Serializers (api/serializers.py)

- `LoginSerializer`: The login authentication logic is implemented in the `validate` function of this serializer.
- `RegisterSerializer`: This serializer includes field checks and validations in the `validate` function.

## Local setup

- Install Python 3.8, 3.9, 3.10, 3.11, or 3.12; install Python package virtualenv.
- Enter the `fa_backend` directory, then create and active the virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate # For Unix-like operating systems
.venv\bin\activate.bat    # For Windows
```
- Next, do an editable install with pip that includes all the development dependencies (with linter and code formatter):
```bash
pip install -e '.[dev]'
```
- Or, if you prefer not to include these dependencies (e.g. in a release environment):
```bash
pip install -e .
```

## Testing

- To run tests, execute:
```bash
./manage.py test [app_to_test]
```
- To get code coverage, first run the tests with:
```bash
coverage run --source='.' manage.py [app_to_test]
```
- Then get the coverage report:
```bash
coverage report
```
- Or, generate a detailed HTML report you can open in the browser that shows which lines are covered:
```bash
coverage html
```

## Others

### Email notification

- The current implementation sends mass email notifications through SMTP. The email notifications are sent every day to users who have not sent health data. The code for sending email notifications can be found in `notification.py`.

## Deployment

- Production server is deployed through Nginx. The uWSGI configuration is in `fa_backend_uwsgi.ini`. Refer to [Setting up Django and your web server with uWSGI and nginx](https://uwsgi-docs.readthedocs.io/en/latest/tutorials/Django_and_nginx.html) for more information.
