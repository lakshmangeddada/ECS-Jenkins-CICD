FROM 123456789.dkr.ecr.us-east-1.amazonaws.com/my-base-image:latest
USER root
RUN pip install --upgrade pip
RUN apk update
RUN apk add make automake gcc g++ subversion python3-dev
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8080
CMD [ "python3", "-m", "flask", "--app", "app", "run", "--host=0.0.0.0", "--port=8080" ]

