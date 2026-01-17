# Use a light version of Python
FROM python:3.9-slim

# Install the PostgreSQL driver needed for Python to talk to the DB
RUN apt-get update && apt-get install -y libpq-dev gcc && \
    pip install flask psycopg2-binary && \
    apt-get clean

# Set the working directory inside the container
WORKDIR /app

# Copy your verified app.py into the container
COPY app.py .

# Tell Docker the app runs on 5555
EXPOSE 5555

# The command to start the app
CMD ["python", "app.py"]