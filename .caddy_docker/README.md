# Caddy Docker Project

This project sets up a web server using Caddy with SSL certificate support for the domain `monsite.fr`. Caddy automatically manages SSL certificates through Let's Encrypt, making it easy to secure your website.

## Project Structure

```
caddy-docker-project
├── Caddyfile
├── docker-compose.yml
└── README.md
```

## Setup Instructions

1. **Clone the Repository**: 
   Clone this repository to your local machine.

   ```bash
   git clone <repository-url>
   cd caddy-docker-project
   ```

2. **Configure the Caddyfile**: 
   Ensure that the `Caddyfile` is correctly configured for your domain. The default configuration is set for `monsite.fr`.

3. **Build and Run the Docker Containers**: 
   Use Docker Compose to build and run the containers.

   ```bash
   docker-compose up -d
   ```

4. **Access Your Website**: 
   Once the containers are running, you can access your website at `http://monsite.fr`. Caddy will automatically handle SSL certificate issuance and renewal.

## Usage

- To stop the containers, run:

  ```bash
  docker-compose down
  ```

- To view logs, use:

  ```bash
  docker-compose logs
  ```

## Additional Information

- Ensure that your DNS records are correctly set up to point to the server where this project is hosted.
- For more information on Caddy and its features, visit the [Caddy Documentation](https://caddyserver.com/docs/).