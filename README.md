## **BOT-OWM**
<a href="https://github.com/padualima/bot-owm-api/actions/workflows/run_specs.yml">
    <img alt="Build Status" src="https://github.com/padualima/bot-owm-api/actions/workflows/rubyonrails.yml/badge.svg">
</a>

Authenticate your account do Twitter and create Tweets with weather information for a particular region provided by OpenWeatherMap.

## **Getting Started!**

### **Premises**

#### **Twitter Authentication Settings**


In the twitter authentication settings, remember to configure the callback route as in the example below:
<img width="695" alt="Captura de Tela 2023-02-16 às 12 48 14" src="https://user-images.githubusercontent.com/31924649/219417624-b952d690-2ec3-4487-8c97-aa208035f3a9.png">

#### **Configure the Envs**
Inside the project directory:

**Copy the `.env` to configure with database credentials and your Twitter and OpenWeatherMap API keys:**
```
cp .env.sample .env
```

### **Docker (recommended)**

Make sure you have Docker and Docker-Compose installed on your machine!

> But, if you haven't installed it yet, I recommend the links below for installation using Ubuntu 20.04:
>
>  * Install Docker: [Click here!](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-pt)
>
>  * Install Docker-compose: [Click here!](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04-pt)

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
curl --location 'http://localhost:3000/authorize' \
--header 'Accept: application/vnd.owm-bot-api.v1'
```

With the token in hand, create Tweets based on weather information for a given region, passing latitude and longitude or region name as parameters:
##### POST /tweets
```
curl --location 'http://localhost:3000/tweets?token=YOUR_TOKEN' \
--header 'Accept: application/vnd.owm-bot-api.v1' \
--header 'Content-Type: application/json' \
--data '{
    "location": {
        "lat": -5.09
        "lon": -42.80
        // "name": "City Name"
    }
}'
```

Or if you prefer, access the Swagger UI with http://localhost:3000/api-docs and make the requests
<img width="1438" alt="Captura de Tela 2023-02-20 às 13 21 35" src="https://user-images.githubusercontent.com/31924649/220158537-a5c0816d-3e9b-4285-8962-aefc9a8a51bf.png">

## **License**

MIT

**Free Software, Hell Yeah!**
