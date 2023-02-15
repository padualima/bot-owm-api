## **OWM-API**

Authenticate your account do Twitter and create Tweets with weather information for a particular region provided by OpenWeatherMap.

## **Getting Started!**

### **Docker (recommended)**

Make sure you have Docker and Docker-Compose installed on your machine!

> But, if you haven't installed it yet, I recommend the links below for installation using Ubuntu 20.04:
>
>  * Install Docker: [Click here!](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-pt)
>
>  * Install Docker-compose: [Click here!](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04-pt)

Inside the project directory:

**Copy the `.env` and configure with database credentials and your Twitter and OpenWeatherMap API keys:**
```
cp .env.sample .env
```

**Run to build the docker image and install dependences:**
```
make build
```

**Now, whenever you want to go up to the API, run the command:**
```
make up
```

**If you want to run the tests**:
```
make run_tests
```

*Depending on the OS, there may be difficulties in executing the commands, if it happens, check the desired tag in the Makefile file and execute it manually!*

## **Who to use**
Then go up Application, now with the request below authenticate your twitter account:
##### GET /authorize
```
curl --location 'http://localhost:3000/authorize'
```

With the token in hand, create Tweets based on weather information for a given region, passing latitude and longitude or region name as parameters:
##### POST /tweets
```
curl --location 'http://localhost:3000/tweets?token=YOUR_TOKEN' \
--header 'Content-Type: application/json' \
--data '{
    "location": {
        "lat": -5.09
        "lon": -42.80
        // "name": "City Name"
    }
}'
```

## **License**

MIT

**Free Software, Hell Yeah!**
