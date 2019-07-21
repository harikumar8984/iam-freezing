# IAM-FREEZING

## Installation

### Prerequisite

** Ruby 2.5.3 **

** Rails 5 **

** Git **


### Clone
- Clone this repo to your local machine  
```
git clone git@github.com:harikumar8984/iam-freezing.git
```

### Development Setup

#### Gems
```
bundle install
```
#### Database
```
rake db:create
rake db:seed
```
#### TestCase

```
rspec
```

#### Services
##### Redis
##### Sidekiq
```
redis-server
redis-server --port 6380
bundle exec sidekiq

```

### Start Server
```
rails s
```
#### API endpoints

```
POST http://#{request.host}/api/thermostats/:thermostat_id/readings                                   
GET  http://#{request.host}/api/thermostats/:thermostat_id/readings/:tracking_number
GET  http://#{request.host}/api/thermostats/:id

```

- Server will up & run in the port *localhost:3000*
- Request header should contain authentication token #auth_token